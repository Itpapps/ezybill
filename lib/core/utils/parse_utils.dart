import 'dart:convert';

/// Safe parsing utilities for dynamic JSON values.
///
/// These replace the many ad-hoc `_parseInt` / `_parseDouble` helpers
/// scattered across provider files. Every method handles null, wrong types,
/// and malformed strings without throwing.

/// Safely converts any [value] to an [int].
///
/// Handles `int`, `double`, `String`, and `null`. Returns [defaultValue] when
/// parsing fails.
int parseInt(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is double) return value.toInt();
  final s = value.toString().trim();
  if (s.isEmpty) return defaultValue;
  return int.tryParse(s) ?? defaultValue;
}

/// Safely converts any [value] to a [double].
double parseDouble(dynamic value, {double defaultValue = 0.0}) {
  if (value == null) return defaultValue;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  final s = value.toString().trim();
  if (s.isEmpty) return defaultValue;
  return double.tryParse(s) ?? defaultValue;
}

/// Safely converts any [value] to a [String].
///
/// Returns [defaultValue] for null or empty values.
String parseString(dynamic value, {String defaultValue = ''}) {
  if (value == null) return defaultValue;
  final s = value.toString().trim();
  return s.isEmpty ? defaultValue : s;
}

/// Safely converts any [value] to a [bool].
///
/// Treats `1`, `'1'`, `'true'`, `'yes'` (case-insensitive) as `true`.
/// Everything else is [defaultValue].
bool parseBool(dynamic value, {bool defaultValue = false}) {
  if (value == null) return defaultValue;
  if (value is bool) return value;
  if (value is int) return value == 1;
  final s = value.toString().trim().toLowerCase();
  if (s == '1' || s == 'true' || s == 'yes') return true;
  if (s == '0' || s == 'false' || s == 'no') return false;
  return defaultValue;
}

/// Safely parses a JSON array or single object into a typed [List<T>].
///
/// This handles several malformed server shapes that occur in this project:
/// - `List<Map<String, dynamic>>` (normal case)
/// - `Map<String, dynamic>` representing a single object
/// - `Map<String, dynamic>` with numeric string keys produced by PHP's
///   `json_encode` for singleton or indexed arrays.
List<T> parseList<T>(
  dynamic value,
  T Function(Map<String, dynamic>) fromJson,
) {
  final items = _normalizeToListOfMaps(value);
  final results = <T>[];
  for (final item in items) {
    try {
      results.add(fromJson(item));
    } catch (_) {
      // Skip malformed entries rather than crashing the whole list.
    }
  }
  return results;
}

/// Safely normalises dynamic JSON data into a list of maps.
///
/// Supports:
/// - actual `List` values
/// - singleton objects represented as a `Map`
/// - PHP-style numeric key maps like `{ "0": {...}, "1": {...} }`.
List<Map<String, dynamic>> parseMapList(dynamic value) {
  return _normalizeToListOfMaps(value);
}

List<Map<String, dynamic>> _normalizeToListOfMaps(dynamic value) {
  if (value is List) {
    return value
        .whereType<Map>()
        .map((item) => item.cast<String, dynamic>())
        .toList();
  }

  if (value is Map) {
    final map = value.map((key, val) => MapEntry(key.toString(), val));

    final numericKeys = map.keys.where((k) => int.tryParse(k) != null).toList();
    if (numericKeys.length == map.length && numericKeys.isNotEmpty) {
      numericKeys.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
      return numericKeys
          .map((key) => map[key])
          .whereType<Map>()
          .map((item) => item.cast<String, dynamic>())
          .toList();
    }

    return [map.cast<String, dynamic>()];
  }

  // PHP/legacy servers sometimes double-encode arrays as JSON strings
  // e.g. paymentresult = "[{...},{...}]" instead of a native JSON array.
  // Android handles this via getString() + new JSONArray(string).
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return [];
    try {
      return _normalizeToListOfMaps(jsonDecode(trimmed));
    } catch (_) {
      return [];
    }
  }

  return <Map<String, dynamic>>[];
}

/// Safely extracts a nested map from a dynamic value.
/// Returns `null` if the value is not a `Map<String, dynamic>`.
Map<String, dynamic>? parseMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((k, v) => MapEntry(k.toString(), v));
  }
  return null;
}

/// Normalises JSON keys to camelCase to handle inconsistent server responses.
///
/// Example: `'employee_id'` → `'employeeId'`, `'FIRST_NAME'` → `'firstName'`
String normaliseToCamel(String key) {
  final parts = key.toLowerCase().split('_');
  if (parts.length == 1) return parts.first;
  return parts.first +
      parts.skip(1).map((p) {
        if (p.isEmpty) return '';
        return p[0].toUpperCase() + p.substring(1);
      }).join();
}
