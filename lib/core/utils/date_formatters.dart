import 'package:intl/intl.dart';

/// Date formatting utilities for the EzyBill app.
///
/// API dates use `yyyy-MM-dd`; display dates use `dd MMM yyyy`.
/// All methods handle nulls and malformed strings gracefully.

final _apiFormat = DateFormat('yyyy-MM-dd');
final _displayDateFormat = DateFormat('dd MMM yyyy');
final _displayDateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');
final _receiptFormat = DateFormat('EEE MMM dd yyyy HH:mm:ss');

/// Formats a [DateTime] as `yyyy-MM-dd` for API payloads.
String formatApiDate(DateTime date) => _apiFormat.format(date);

/// Formats a [DateTime] as `dd MMM yyyy` for user-facing display.
/// Example: "22 Mar 2026".
String formatDisplayDate(DateTime date) => _displayDateFormat.format(date);

/// Formats a [DateTime] as `dd MMM yyyy, hh:mm a` for user-facing display.
/// Example: "22 Mar 2026, 02:30 PM".
String formatDisplayDateTime(DateTime date) =>
    _displayDateTimeFormat.format(date);

/// Formats a [DateTime] for thermal receipt printing.
/// Example: "Thu Mar 22 2026 14:30:00".
String formatReceiptDate(DateTime date) => _receiptFormat.format(date);

/// Safely parses a date string in `yyyy-MM-dd` or `yyyy-MM-ddTHH:mm:ss`
/// format. Returns `null` if the input is null, empty, or unparseable.
DateTime? parseApiDate(String? dateStr) {
  if (dateStr == null || dateStr.trim().isEmpty) return null;
  try {
    return DateTime.parse(dateStr.trim());
  } catch (_) {
    // Try the explicit API format as a fallback.
    try {
      return _apiFormat.parseStrict(dateStr.trim());
    } catch (_) {
      return null;
    }
  }
}

/// Parses a date string and formats it for display.
/// Returns [fallback] if the date cannot be parsed.
String formatApiDateForDisplay(String? dateStr, {String fallback = '--'}) {
  final dt = parseApiDate(dateStr);
  if (dt == null) return fallback;
  return formatDisplayDate(dt);
}

/// Returns the number of days from today until the given date string.
/// Positive = days remaining, negative = overdue, 0 = today.
/// Returns `0` if the date cannot be parsed.
int daysUntil(String? dateStr) {
  final target = parseApiDate(dateStr);
  if (target == null) return 0;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final targetDay = DateTime(target.year, target.month, target.day);
  return targetDay.difference(today).inDays;
}

/// Returns today's date formatted for API use.
String todayApiDate() => formatApiDate(DateTime.now());
