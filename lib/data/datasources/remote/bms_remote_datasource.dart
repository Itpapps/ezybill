import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../models/auth/bms_registration_response.dart';

/// Remote datasource for BMS (Business Management System) SOAP calls.
///
/// Uses raw HTTP POST with SOAP XML envelope. Does NOT use Dio (which has
/// encryption interceptors that would break SOAP).
class BmsRemoteDatasource {
  BmsRemoteDatasource({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Default BMS URL — sourced from ApiConstants so the environment toggle
  /// in api_constants.dart applies everywhere automatically.
  static String get defaultBmsUrl => ApiConstants.bmsUrl;

  static String get _defaultNamespace =>
      ApiConstants.bmsUrl.replaceAll('/validateAuthentication', '');

  /// Auto-login check: is this device already registered?
  ///
  /// Sends empty `smsCode` with the device ID. If `statusCode == 0`, the
  /// device is registered and the response contains the REST API URL.
  Future<BmsRegistrationResponse> checkRegistration({
    required String deviceId,
    String? bmsUrl,
  }) async {
    return _callSoap(
      smsCode: '',
      imei: deviceId,
      appTypeId: 2,
      imeiValidNumber: 0,
      bmsUrl: bmsUrl,
    );
  }

  /// Register a new device with MSO Key + Username.
  ///
  /// The `smsCode` is the concatenation of `msoKey` and `username`.
  Future<BmsRegistrationResponse> register({
    required String msoKey,
    required String username,
    required String deviceId,
    String? bmsUrl,
  }) async {
    final smsCode = '$msoKey$username'; // Concatenated as per server spec
    return _callSoap(
      smsCode: smsCode,
      imei: deviceId,
      appTypeId: 2,
      imeiValidNumber: 0,
      bmsUrl: bmsUrl,
    );
  }

  /// Core SOAP call to the BMS `validateUserAuthentication` method.
  Future<BmsRegistrationResponse> _callSoap({
    required String smsCode,
    required String imei,
    required int appTypeId,
    required int imeiValidNumber,
    String? bmsUrl,
  }) async {
    // The source-level constant in api_constants.dart is authoritative, as
    // NAMESPACE_BMS is in the native Android app. A persisted `bms_url` must
    // not silently outrank a comment/uncomment environment switch.
    final url = defaultBmsUrl;
    final namespace = _namespaceFromUrl(url);

    // Build SOAP XML envelope
    final soapXml = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
               xmlns:xsd="http://www.w3.org/2001/XMLSchema"
               xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <validateUserAuthentication xmlns="$namespace">
      <userInfo>
        <smsCode>$smsCode</smsCode>
        <imei>$imei</imei>
        <appTypeId>$appTypeId</appTypeId>
        <imeiValidNumber>$imeiValidNumber</imeiValidNumber>
      </userInfo>
    </validateUserAuthentication>
  </soap:Body>
</soap:Envelope>''';

    final soapAction = url; // SOAPAction matches the URL

    // On Flutter Web debug, route through the CORS proxy
    final requestUrl = (kIsWeb && kDebugMode)
        ? 'http://localhost:3199/proxy?url=${Uri.encodeComponent(url)}'
        : url;

    try {
      final response = await _client
          .post(
            Uri.parse(requestUrl),
            headers: {
              'Content-Type': 'text/xml; charset=utf-8',
              'SOAPAction': soapAction,
            },
            body: utf8.encode(soapXml),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw BmsException(
          'BMS server returned HTTP ${response.statusCode}',
        );
      }

      // Parse the SOAP XML response
      final responseBody = response.body;

      // Try structured XML first (server returns <parameters><statusCode>...</statusCode>...)
      final xmlMap = _extractParametersFromSoap(responseBody);
      if (xmlMap.isNotEmpty) {
        return BmsRegistrationResponse.fromMap(xmlMap);
      }

      // Fallback: try semicolon-separated string from <return> tag
      final resultString = _extractResultFromSoap(responseBody);
      if (resultString == null || resultString.isEmpty) {
        throw BmsException('Empty response from BMS server');
      }

      return BmsRegistrationResponse.fromSoapString(resultString);
    } on BmsException {
      rethrow;
    } catch (e) {
      throw BmsException('Failed to connect to BMS server: $e');
    }
  }

  /// Extracts the namespace from the BMS URL by stripping `/validateAuthentication`.
  String _namespaceFromUrl(String url) {
    if (url.endsWith('/validateAuthentication')) {
      return url.substring(0, url.length - '/validateAuthentication'.length);
    }
    return _defaultNamespace;
  }

  /// Extract key-value pairs from SOAP XML with structured tags.
  ///
  /// The BMS server returns:
  /// ```xml
  /// <parameters>
  ///   <statusCode>0</statusCode>
  ///   <statusMessage>Registered successfully</statusMessage>
  ///   <ipAddress>http://...</ipAddress>
  ///   ...
  /// </parameters>
  /// ```
  Map<String, String> _extractParametersFromSoap(String xml) {
    final map = <String, String>{};

    // Find <parameters>...</parameters> block
    final paramsContent = _extractTagContent(xml, 'parameters');
    if (paramsContent == null || paramsContent.isEmpty) return map;

    // Extract each known field
    for (final tag in [
      'statusCode', 'statusMessage', 'ipAddress', 'employeeId',
      'appThemeColor', 'appDashboard', 'appLogoPath',
      'registrationRequired', 'version',
    ]) {
      final value = _extractTagContent(paramsContent, tag);
      if (value != null) {
        map[tag] = value;
      }
    }

    return map;
  }

  /// Parse the SOAP XML response body and extract the semicolon-separated
  /// result string.
  ///
  /// The response looks like:
  /// ```xml
  /// <soap:Envelope ...>
  ///   <soap:Body>
  ///     <validateUserAuthenticationResponse ...>
  ///       <return>statusCode=0;statusMessage=...;ipAddress=...</return>
  ///     </validateUserAuthenticationResponse>
  ///   </soap:Body>
  /// </soap:Envelope>
  /// ```
  ///
  /// We extract the text content from `<return>...</return>` or the innermost
  /// response element.
  String? _extractResultFromSoap(String xml) {
    // Try to find <return>...</return> tag first
    var result = _extractTagContent(xml, 'return');
    if (result != null && result.isNotEmpty) return result;

    // Try <validateUserAuthenticationReturn>...</validateUserAuthenticationReturn>
    result = _extractTagContent(xml, 'validateUserAuthenticationReturn');
    if (result != null && result.isNotEmpty) return result;

    // Try <ns1:return> or <ns2:return> (namespaced)
    final nsReturnPattern =
        RegExp(r'<\w+:return[^>]*>(.*?)</\w+:return>', dotAll: true);
    final nsMatch = nsReturnPattern.firstMatch(xml);
    if (nsMatch != null) return nsMatch.group(1)?.trim();

    // Fallback: look for the semicolon-separated pattern anywhere in the body
    final semiColonPattern =
        RegExp(r'statusCode=\d+;[^<]+', dotAll: true);
    final semiMatch = semiColonPattern.firstMatch(xml);
    if (semiMatch != null) return semiMatch.group(0)?.trim();

    return null;
  }

  /// Extract text content from a simple XML tag.
  String? _extractTagContent(String xml, String tagName) {
    final pattern =
        RegExp('<$tagName[^>]*>(.*?)</$tagName>', dotAll: true);
    final match = pattern.firstMatch(xml);
    return match?.group(1)?.trim();
  }
}

/// Exception thrown when a BMS SOAP call fails.
class BmsException implements Exception {
  final String message;
  const BmsException(this.message);

  @override
  String toString() => 'BmsException: $message';
}
