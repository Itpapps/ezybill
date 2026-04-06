import 'package:intl/intl.dart';

/// Currency formatting utilities for the EzyBill app.
///
/// Uses Indian numbering notation by default (1,23,456.00) and reads the
/// currency symbol from the session's `currencyCode`.

final _indianFormat = NumberFormat('#,##,##0.00', 'en_IN');
final _indianCompactFormat = NumberFormat.compact(locale: 'en_IN');

/// Formats [amount] as a currency string with the given [symbol].
///
/// Examples:
/// - `formatCurrency(1234.5)` → `'₹1,234.50'`
/// - `formatCurrency(123456.0)` → `'₹1,23,456.00'`
/// - `formatCurrency(0)` → `'₹0.00'`
String formatCurrency(double amount, {String symbol = '\u20B9'}) {
  return '$symbol${_indianFormat.format(amount)}';
}

/// Formats [amount] as a compact currency string for large values.
///
/// Examples:
/// - `formatCurrencyCompact(1200)` → `'₹1.2K'`
/// - `formatCurrencyCompact(1500000)` → `'₹15L'`
/// - `formatCurrencyCompact(50)` → `'₹50.00'` (no compaction for small amounts)
String formatCurrencyCompact(double amount, {String symbol = '\u20B9'}) {
  if (amount.abs() < 1000) {
    return formatCurrency(amount, symbol: symbol);
  }
  return '$symbol${_indianCompactFormat.format(amount)}';
}

/// Safely parses a dynamic value to double and formats it as currency.
/// Returns the formatted string, or [fallback] if the value cannot be parsed.
String formatCurrencyFromDynamic(
  dynamic value, {
  String symbol = '\u20B9',
  String fallback = '\u20B90.00',
}) {
  if (value == null) return fallback;
  if (value is double) return formatCurrency(value, symbol: symbol);
  if (value is int) return formatCurrency(value.toDouble(), symbol: symbol);
  final parsed = double.tryParse(value.toString().trim());
  if (parsed == null) return fallback;
  return formatCurrency(parsed, symbol: symbol);
}

/// Returns the currency symbol for a given currency code.
/// Defaults to `₹` for INR.
String currencySymbolFor(String? currencyCode) {
  switch (currencyCode?.toUpperCase()) {
    case 'INR':
    case null:
    case '':
      return '\u20B9';
    case 'USD':
      return '\$';
    case 'EUR':
      return '\u20AC';
    case 'GBP':
      return '\u00A3';
    default:
      return currencyCode!;
  }
}
