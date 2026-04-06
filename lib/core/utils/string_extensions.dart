/// String extension utilities for the EzyBill app.

extension StringExtensions on String {
  /// Returns the initials of the string — first letter of each word,
  /// uppercased, max 2 characters.
  ///
  /// Examples:
  /// - `'John Doe'.initials` → `'JD'`
  /// - `'Alice'.initials` → `'A'`
  /// - `'hello world test'.initials` → `'HW'`
  /// - `''.initials` → `''`
  String get initials {
    final words = trim().split(RegExp(r'\s+'));
    if (words.isEmpty || (words.length == 1 && words.first.isEmpty)) return '';
    final letters = words
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase())
        .take(2)
        .join();
    return letters;
  }

  /// Capitalises the first letter of the string.
  ///
  /// Example: `'hello'.capitalized` → `'Hello'`
  String get capitalized {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Capitalises the first letter of every word.
  ///
  /// Example: `'john doe'.titleCase` → `'John Doe'`
  String get titleCase {
    if (isEmpty) return this;
    return split(RegExp(r'\s+'))
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  /// Removes the EzyBill complaint suffix appended by the Android/Flutter app.
  ///
  /// Strips patterns like:
  /// - `.Complaint Created from Android app`
  /// - `.Complaint Created from Flutter app`
  /// - `.Complaint Closed from Android app`
  /// - `.Complaint Closed from Flutter app`
  String stripComplaintSuffix() {
    return replaceAll(
      RegExp(r'\.\s*Complaint\s+(Created|Closed|Status Change From)\s+(from\s+)?(Android|Flutter)\s+app\s*$', caseSensitive: false),
      '',
    ).trim();
  }

  /// Appends the standard EzyBill complaint suffix.
  ///
  /// [isCreation] controls whether 'Created' or 'Closed' is used.
  String appendComplaintSuffix(bool isCreation) {
    final action = isCreation ? 'Created' : 'Closed';
    return '$this.Complaint $action from Flutter app';
  }

  /// Returns `true` if this string looks like a valid Indian mobile number.
  bool get isValidMobile => RegExp(r'^[6-9]\d{9}$').hasMatch(trim());

  /// Returns `true` if this string looks like a valid email address.
  bool get isValidEmail =>
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
          .hasMatch(trim());

  /// Truncates the string to [maxLength] characters, appending `...` if
  /// truncated.
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  /// Converts a potentially null or 'null' string to an actual null.
  /// Useful when dealing with server responses that send literal `"null"`.
  String? get nullIfEmpty {
    final trimmed = trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') return null;
    return trimmed;
  }
}

/// Extension on nullable strings for safe access.
extension NullableStringExtensions on String? {
  /// Returns `true` if the string is null, empty, or only whitespace.
  bool get isNullOrEmpty => this == null || this!.trim().isEmpty;

  /// Returns the string or a fallback if null/empty.
  String orDefault([String fallback = '']) =>
      isNullOrEmpty ? fallback : this!.trim();
}
