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

/// Safely parses a JSON array into a typed [List<T>].
///
/// [value] is expected to be a `List<dynamic>` (from `json['someArray']`).
/// Each element is cast to `Map<String, dynamic>` and passed through
/// [fromJson]. Elements that fail to parse are silently skipped.
///
/// Example:
/// ```dart
/// final customers = parseList(json['customers'], Customer.fromJson);
/// ```
List<T> parseList<T>(
  dynamic value,
  T Function(Map<String, dynamic>) fromJson,
) {
  if (value == null || value is! List) return <T>[];
  final results = <T>[];
  for (final item in value) {
    if (item is Map<String, dynamic>) {
      try {
        results.add(fromJson(item));
      } catch (_) {
        // Skip malformed entries rather than crashing the whole list.
      }
    }
  }
  return results;
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
