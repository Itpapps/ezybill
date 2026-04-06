/// Form-field validators for the EzyBill app.
///
/// Each validator returns `null` when the value is valid, or an error message
/// string when invalid — matching the Flutter `TextFormField.validator` API.

final _emailRegex = RegExp(
  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
);

final _mobileRegex = RegExp(r'^[6-9]\d{9}$');

final _pinCodeRegex = RegExp(r'^\d{6}$');

final _amountRegex = RegExp(r'^\d+(\.\d{1,2})?$');

/// Validates that [value] is not null or empty.
/// [fieldName] is used in the error message for clarity.
String? validateRequired(String? value, String fieldName) {
  if (value == null || value.trim().isEmpty) {
    return '$fieldName is required';
  }
  return null;
}

/// Validates an Indian mobile number: exactly 10 digits, starting with 6-9.
String? validateMobile(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Mobile number is required';
  }
  final trimmed = value.trim();
  if (!_mobileRegex.hasMatch(trimmed)) {
    return 'Enter a valid 10-digit mobile number';
  }
  return null;
}

/// Validates a standard email address format.
String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Email is required';
  }
  if (!_emailRegex.hasMatch(value.trim())) {
    return 'Enter a valid email address';
  }
  return null;
}

/// Validates a 6-digit Indian PIN code.
String? validatePinCode(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'PIN code is required';
  }
  if (!_pinCodeRegex.hasMatch(value.trim())) {
    return 'Enter a valid 6-digit PIN code';
  }
  return null;
}

/// Validates a positive monetary amount with at most 2 decimal places.
String? validateAmount(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Amount is required';
  }
  final trimmed = value.trim();
  if (!_amountRegex.hasMatch(trimmed)) {
    return 'Enter a valid amount (e.g., 100 or 99.50)';
  }
  final parsed = double.tryParse(trimmed);
  if (parsed == null || parsed <= 0) {
    return 'Amount must be greater than zero';
  }
  return null;
}

/// Validates minimum string length.
String? validateMinLength(String? value, int minLength, String fieldName) {
  if (value == null || value.trim().isEmpty) {
    return '$fieldName is required';
  }
  if (value.trim().length < minLength) {
    return '$fieldName must be at least $minLength characters';
  }
  return null;
}

/// Validates an STB (Set-Top Box) serial number — alphanumeric, non-empty.
String? validateStbNumber(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'STB number is required';
  }
  if (value.trim().length < 4) {
    return 'STB number is too short';
  }
  return null;
}

/// Validates a VC (Viewing Card) number — alphanumeric, non-empty.
String? validateVcNumber(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'VC number is required';
  }
  if (value.trim().length < 4) {
    return 'VC number is too short';
  }
  return null;
}

/// Validates a receipt number — non-empty alphanumeric string.
String? validateReceiptNumber(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Receipt number is required';
  }
  return null;
}
