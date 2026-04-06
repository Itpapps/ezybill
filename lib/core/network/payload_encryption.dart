import 'dart:convert';
import 'dart:math';

/// Implements the server's Encryption_lib payload encryption scheme.
///
/// The server expects all POST requests to have `payload` and `hash` fields
/// instead of raw parameters. This matches the PHP Encryption_lib class from
/// `Ezybill_v2_release3/app/application/libraries/Encryption_lib.php`.
///
/// Encryption scheme (triple hex encoding):
/// 1. JSON encode the data → hex encode each byte (this is the `hash`)
/// 2. Hex encode each char of step 1 result
/// 3. Hex encode each char of step 2 result
/// 4. Prepend/append 5 random digits (this is the `payload`)
class PayloadEncryption {
  static final _random = Random();

  /// Encrypts a data Map into the `{payload, hash}` format the server expects.
  ///
  /// Mirrors PHP: `Encryption_lib::app_data_encryption($payload_array)`
  static Map<String, String> encryptPayload(Map<String, dynamic> data) {
    // Step 1: json_encode → bin2hex (PHP equivalent)
    final jsonStr = jsonEncode(data);
    final hash = _binToHex(jsonStr);

    // Step 2: encrypt(hash) → double hex encode + random padding
    final payload = _encrypt(hash);

    return {'payload': payload, 'hash': hash};
  }

  /// Converts a string to its hexadecimal representation.
  /// Equivalent to PHP's `bin2hex()` function.
  static String _binToHex(String input) {
    return utf8
        .encode(input)
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  /// Double hex-encodes a string and adds random digit padding.
  /// Mirrors PHP: `Encryption_lib::encrypt($parameter)`
  static String _encrypt(String parameter,
      {int frontAdd = 5, int backAdd = 5}) {
    // First level: bin2hex of the entire parameter string
    final firstHex = _binToHex(parameter);

    // Second level: split into individual chars, bin2hex each char
    final buffer = StringBuffer();
    for (int i = 0; i < firstHex.length; i++) {
      buffer.write(_binToHex(firstHex[i]));
    }
    final encrypted = buffer.toString();

    // Add random digit padding (matches PHP rand(pow(10,n-1), pow(10,n)-1))
    final frontNum = _randomDigits(frontAdd);
    final backNum = _randomDigits(backAdd);

    return '$frontNum$encrypted$backNum';
  }

  /// Generates a random number string with exactly [n] digits.
  static String _randomDigits(int n) {
    final min = _pow10(n - 1);
    final max = _pow10(n) - 1;
    return (_random.nextInt(max - min + 1) + min).toString();
  }

  /// Integer power of 10 (avoids dart:math pow returning double).
  static int _pow10(int exp) {
    int result = 1;
    for (int i = 0; i < exp; i++) {
      result *= 10;
    }
    return result;
  }

  /// Decrypts a payload string back to a Map.
  /// Mirrors PHP: `Encryption_lib::decrypt()`
  static Map<String, dynamic>? decryptPayload(String payload,
      {int frontStrip = 5, int backStrip = 5}) {
    try {
      // Strip random padding
      final stripped =
          payload.substring(frontStrip, payload.length - backStrip);

      // Reverse second level: split into 2-char pairs, hex2bin each
      final firstReverse = StringBuffer();
      for (int i = 0; i < stripped.length; i += 2) {
        final hexPair = stripped.substring(i, i + 2);
        final charCode = int.parse(hexPair, radix: 16);
        firstReverse.writeCharCode(charCode);
      }

      // Reverse first level: hex2bin
      final secondReverse = StringBuffer();
      final first = firstReverse.toString();
      for (int i = 0; i < first.length; i += 2) {
        final hexPair = first.substring(i, i + 2);
        final charCode = int.parse(hexPair, radix: 16);
        secondReverse.writeCharCode(charCode);
      }

      // The result is the hash (hex-encoded JSON); decode it
      return decryptHash(secondReverse.toString());
    } catch (_) {
      return null;
    }
  }

  /// Decrypts the `hash` field directly (single hex decode → JSON).
  /// This is the fastest way to get response data since hash = bin2hex(json).
  static Map<String, dynamic>? decryptHash(String hash) {
    try {
      final jsonBytes = <int>[];
      for (int i = 0; i < hash.length; i += 2) {
        jsonBytes.add(int.parse(hash.substring(i, i + 2), radix: 16));
      }
      final jsonStr = utf8.decode(jsonBytes);
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Decrypts an encrypted server response.
  /// Server responses use `sendResponse → app_data_encryption`.
  /// The response body is `{payload: "...", hash: "..."}`.
  /// We decode via the `hash` field (faster than full payload decryption).
  static Map<String, dynamic>? decryptResponse(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final hash = responseData['hash'];
      if (hash is String && hash.isNotEmpty) {
        return decryptHash(hash);
      }
      // If no hash field, response might be plain JSON (e.g., login)
      return responseData;
    }
    if (responseData is String) {
      // Try parsing as JSON first
      try {
        final parsed = jsonDecode(responseData);
        if (parsed is Map<String, dynamic>) {
          return decryptResponse(parsed);
        }
      } catch (_) {}
    }
    return null;
  }
}
