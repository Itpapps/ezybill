import 'package:flutter/foundation.dart';

/// Utility class for SOAP envelope construction and response parsing.
///
/// On the LIVE server, all API calls go through wsController via SOAP
/// (matching the Android app's KSoap2 behavior). The customerRestservices
/// REST controller only has a limited subset of methods.
class SoapHelper {
  SoapHelper._();

  /// Build a SOAP envelope for a method call.
  ///
  /// Format matches KSoap2 with .dotNet=true:
  /// ```xml
  /// <v:Envelope ...>
  ///   <v:Header />
  ///   <v:Body>
  ///     <methodName id="o0" c:root="1">
  ///       <params i:type=":methodName">
  ///         <key i:type="d:string">value</key>
  ///       </params>
  ///     </methodName>
  ///   </v:Body>
  /// </v:Envelope>
  /// ```
  static String buildEnvelope(String methodName, Map<String, dynamic> params) {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="utf-8"?>');
    buffer.write('<v:Envelope');
    buffer.write(' xmlns:i="http://www.w3.org/2001/XMLSchema-instance"');
    buffer.write(' xmlns:d="http://www.w3.org/2001/XMLSchema"');
    buffer.write(' xmlns:c="http://schemas.xmlsoap.org/soap/encoding/"');
    buffer.write(' xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"');
    buffer.writeln('>');
    buffer.writeln('<v:Header />');
    buffer.writeln('<v:Body>');
    buffer.writeln('<$methodName id="o0" c:root="1">');
    buffer.writeln('<params i:type=":$methodName">');

    // Map REST parameter names to SOAP parameter names
    // (Android KSoap2 uses camelCase for some fields)
    final soapParams = _mapParamNames(params);

    for (final entry in soapParams.entries) {
      final value = _xmlEscape(entry.value?.toString() ?? '');
      buffer.writeln('<${entry.key} i:type="d:string">$value</${entry.key}>');
    }

    buffer.writeln('</params>');
    buffer.writeln('</$methodName>');
    buffer.writeln('</v:Body>');
    buffer.writeln('</v:Envelope>');
    return buffer.toString();
  }

  /// Map REST-style parameter names to SOAP-style parameter names.
  /// The wsController SOAP interface uses slightly different naming than REST.
  static Map<String, dynamic> _mapParamNames(Map<String, dynamic> params) {
    const nameMapping = {
      'authtoken': 'authToken',
      // Note: dealer_id stays as dealer_id in SOAP (confirmed from Android logs)
    };

    final mapped = <String, dynamic>{};
    for (final entry in params.entries) {
      final soapName = nameMapping[entry.key] ?? entry.key;
      mapped[soapName] = entry.value;
    }
    return mapped;
  }

  /// Parse a SOAP XML response into a Map<String, dynamic>.
  ///
  /// Handles:
  /// - Simple values: <key>value</key> → "key": "value"
  /// - Nested objects: <key><child>val</child></key> → "key": {"child": "val"}
  /// - Arrays (repeated elements): multiple <key> → "key": [...]
  /// - Numeric detection: "0" → 0, "5.90" → "5.90" (keep strings for amounts)
  static Map<String, dynamic>? parseResponse(String xml) {
    // Extract content inside <parameters>...</parameters>
    final paramMatch = RegExp(
      r'<parameters[^>]*>(.*?)</parameters>',
      dotAll: true,
    ).firstMatch(xml);

    if (paramMatch == null) {
      // Try <return>...</return> (some SOAP servers use this)
      final returnMatch = RegExp(
        r'<(?:\w+:)?return[^>]*>(.*?)</(?:\w+:)?return>',
        dotAll: true,
      ).firstMatch(xml);
      if (returnMatch != null) {
        final resultStr = returnMatch.group(1)?.trim() ?? '';
        // If it's semicolon-separated (like login), convert to map
        if (resultStr.contains('=') && resultStr.contains(';')) {
          return _parseSemicolonResponse(resultStr);
        }
      }
      debugPrint('[SOAP-PARSE] No <parameters> found in response');
      return null;
    }

    final inner = paramMatch.group(1) ?? '';
    final parsed = _parseXmlChildren(inner);
    return _normalizeFieldNames(parsed);
  }

  /// Normalize SOAP field names to match what Dart models expect.
  /// SOAP uses camelCase (statusCode) but models use snake_case (status_code).
  static Map<String, dynamic> _normalizeFieldNames(Map<String, dynamic> map) {
    final result = Map<String, dynamic>.from(map);

    // Map common SOAP field names to REST-compatible names
    const fieldMapping = {
      'statusCode': 'status_code',
      'statusMessage': 'status_msg',
      'statusMsg': 'status_msg',
      'lco_deposit_amount': 'deposit_amount',
    };

    for (final entry in fieldMapping.entries) {
      if (result.containsKey(entry.key) && !result.containsKey(entry.value)) {
        result[entry.value] = result[entry.key];
      }
    }

    return result;
  }

  /// Parse semicolon-separated key=value response (used by login and some methods).
  static Map<String, dynamic> _parseSemicolonResponse(String str) {
    final map = <String, dynamic>{};
    for (final pair in str.split(';')) {
      final trimmed = pair.trim();
      if (trimmed.isEmpty) continue;
      final eqIndex = trimmed.indexOf('=');
      if (eqIndex == -1) continue;
      final key = trimmed.substring(0, eqIndex).trim();
      final value = trimmed.substring(eqIndex + 1).trim();
      map[key] = _smartConvert(value);
    }
    return _normalizeFieldNames(map);
  }

  /// Parse XML children into a Map, handling repeated elements as arrays.
  static Map<String, dynamic> _parseXmlChildren(String xml) {
    final result = <String, dynamic>{};
    final elementCounts = <String, int>{};

    // Find all top-level elements (non-greedy, handles nested)
    final elements = _extractTopLevelElements(xml);

    // First pass: count occurrences of each tag name
    for (final elem in elements) {
      elementCounts[elem.name] = (elementCounts[elem.name] ?? 0) + 1;
    }

    // Second pass: build the map
    for (final elem in elements) {
      final isArray = elementCounts[elem.name]! > 1;

      dynamic value;
      if (elem.hasChildren) {
        // Nested element → parse recursively
        value = _parseXmlChildren(elem.content);
      } else {
        // Leaf element → string value (try int conversion for status codes)
        value = _smartConvert(elem.content.trim());
      }

      if (isArray) {
        // Multiple elements with same name → array
        if (!result.containsKey(elem.name)) {
          result[elem.name] = <dynamic>[];
        }
        (result[elem.name] as List).add(value);
      } else {
        result[elem.name] = value;
      }
    }

    return result;
  }

  /// Extract top-level XML elements from a string.
  /// Handles nested elements correctly by counting open/close tags.
  static List<_XmlElement> _extractTopLevelElements(String xml) {
    final elements = <_XmlElement>[];
    final tagPattern = RegExp(r'<(\w+)(?:\s[^>]*)?\/?>');
    var pos = 0;

    while (pos < xml.length) {
      final match = tagPattern.matchAsPrefix(xml, pos);
      if (match == null) {
        pos++;
        continue;
      }

      final tagName = match.group(1)!;
      final afterOpenTag = match.end;

      // Check for self-closing tag
      if (xml.substring(match.start, match.end).endsWith('/>')) {
        elements.add(_XmlElement(name: tagName, content: '', hasChildren: false));
        pos = match.end;
        continue;
      }

      // Find matching close tag, handling nesting
      final closeTag = '</$tagName>';
      var depth = 1;
      var searchPos = afterOpenTag;

      while (depth > 0 && searchPos < xml.length) {
        final nextOpen = xml.indexOf('<$tagName', searchPos);
        final nextClose = xml.indexOf(closeTag, searchPos);

        if (nextClose == -1) break; // malformed XML

        if (nextOpen != -1 && nextOpen < nextClose) {
          // Check it's actually an open tag (not just a substring match)
          final afterName = nextOpen + tagName.length + 1;
          if (afterName < xml.length &&
              (xml[afterName] == '>' || xml[afterName] == ' ')) {
            depth++;
          }
          searchPos = nextOpen + 1;
        } else {
          depth--;
          if (depth == 0) {
            final content = xml.substring(afterOpenTag, nextClose);
            final hasChildren = RegExp(r'<\w+[^>]*>').hasMatch(content);
            elements.add(_XmlElement(
              name: tagName,
              content: content,
              hasChildren: hasChildren,
            ));
            pos = nextClose + closeTag.length;
            break;
          }
          searchPos = nextClose + 1;
        }
      }

      if (depth > 0) {
        // Couldn't find matching close tag, skip this position
        pos = afterOpenTag;
      }
    }

    return elements;
  }

  /// Smart conversion: integers and doubles for numeric fields, strings otherwise.
  static dynamic _smartConvert(String value) {
    if (value.isEmpty) return '';
    // Try integer first (status codes, counts, IDs)
    final asInt = int.tryParse(value);
    if (asInt != null) return asInt;
    // Try double (amounts, shares, etc.)
    final asDouble = double.tryParse(value);
    if (asDouble != null) return asDouble;
    return value;
  }

  /// Escape XML special characters.
  static String _xmlEscape(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}

class _XmlElement {
  final String name;
  final String content;
  final bool hasChildren;

  _XmlElement({
    required this.name,
    required this.content,
    required this.hasChildren,
  });
}
