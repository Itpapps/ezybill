import 'dart:convert';
import 'dart:typed_data';

/// ESC/POS byte command library for thermal receipt printers.
///
/// Mirrors the `bufLinear` byte arrays and control codes from the Android
/// `BluetoothChatService.SetFonts()` implementation. All commands are
/// standard ESC/POS (Epson compatible) and work with most 58mm / 80mm
/// thermal printers.
class EscPosCommands {
  EscPosCommands._();

  // ── Line separators ────────────────────────────────────────────────────

  /// 32-character dot separator for 58mm printers.
  static const String separator58mm = '................................';

  /// 40-character dash separator for 80mm printers.
  static const String separator80mm = '----------------------------------------';

  /// 48-character dash separator for ESC/POS legacy format.
  static const String separatorLegacy = '------------------------------------------------';

  /// Returns the appropriate line separator for the given [lineWidth].
  static String separator(int lineWidth) {
    if (lineWidth >= 40) return separator80mm;
    return separator58mm;
  }

  /// Returns a double-line separator (equals signs).
  static String doubleSeparator(int lineWidth) {
    return '=' * lineWidth;
  }

  // ── Carriage return / line feed ────────────────────────────────────────

  /// Carriage return byte (0x0D).
  static const List<int> cr = [0x0D];

  /// Line feed byte (0x0A).
  static const List<int> lf = [0x0A];

  /// CR + LF combined.
  static const List<int> crlf = [0x0D, 0x0A];

  /// Multiple line feeds for paper advance.
  static List<int> feed(int lines) {
    return List<int>.generate(lines, (_) => 0x0A);
  }

  // ── ESC/POS font size commands (bufLinear[1..16]) ──────────────────────
  //
  // Format: {0x1B, 0x4B, 0x0N} where N = font size index.
  // These match BluetoothChatService.SetFonts() from the Android source.

  /// Smallest font — bufLinear[1].
  static const List<int> fontSmallest = [0x1B, 0x4B, 0x00];

  /// Font size 2 — bufLinear[2] (used for "EZYBILL" footer).
  static const List<int> font2 = [0x1B, 0x4B, 0x01];

  /// Font size 3 — bufLinear[3].
  static const List<int> font3 = [0x1B, 0x4B, 0x02];

  /// Font size 4 — bufLinear[4].
  static const List<int> font4 = [0x1B, 0x4B, 0x03];

  /// Font size 5 — bufLinear[5].
  static const List<int> font5 = [0x1B, 0x4B, 0x04];

  /// Font size 6 — bufLinear[6].
  static const List<int> font6 = [0x1B, 0x4B, 0x05];

  /// Font size 7 — bufLinear[7].
  static const List<int> font7 = [0x1B, 0x4B, 0x06];

  /// Font size 8 — bufLinear[8].
  static const List<int> font8 = [0x1B, 0x4B, 0x07];

  /// Font size 9 — bufLinear[9].
  static const List<int> font9 = [0x1B, 0x4B, 0x08];

  /// Font size 10 — bufLinear[10].
  static const List<int> font10 = [0x1B, 0x4B, 0x09];

  /// Font size 11 — bufLinear[11].
  static const List<int> font11 = [0x1B, 0x4B, 0x0A];

  /// Line separator font — bufLinear[12].
  static const List<int> fontSeparator = [0x1B, 0x4B, 0x0B];

  /// Header/footer font — bufLinear[13] (receipt title, "POWERED BY").
  static const List<int> fontHeader = [0x1B, 0x4B, 0x0C];

  /// Font size 14 — bufLinear[14].
  static const List<int> font14 = [0x1B, 0x4B, 0x0D];

  /// Body font — bufLinear[15] (field labels and values).
  static const List<int> fontBody = [0x1B, 0x4B, 0x0E];

  /// Font size 16 — bufLinear[16].
  static const List<int> font16 = [0x1B, 0x4B, 0x0F];

  // ── Bold ───────────────────────────────────────────────────────────────

  /// ESC E 1 — turn bold on.
  static const List<int> boldOn = [0x1B, 0x45, 0x01];

  /// ESC E 0 — turn bold off.
  static const List<int> boldOff = [0x1B, 0x45, 0x00];

  // ── Text alignment ────────────────────────────────────────────────────

  /// ESC a 0 — align left.
  static const List<int> alignLeft = [0x1B, 0x61, 0x00];

  /// ESC a 1 — align center.
  static const List<int> alignCenter = [0x1B, 0x61, 0x01];

  /// ESC a 2 — align right.
  static const List<int> alignRight = [0x1B, 0x61, 0x02];

  // ── Underline ─────────────────────────────────────────────────────────

  /// ESC - 1 — underline on (1 dot).
  static const List<int> underlineOn = [0x1B, 0x2D, 0x01];

  /// ESC - 0 — underline off.
  static const List<int> underlineOff = [0x1B, 0x2D, 0x00];

  // ── Double height / width ─────────────────────────────────────────────

  /// GS ! 0x00 — normal size.
  static const List<int> sizeNormal = [0x1D, 0x21, 0x00];

  /// GS ! 0x01 — double height.
  static const List<int> sizeDoubleHeight = [0x1D, 0x21, 0x01];

  /// GS ! 0x10 — double width.
  static const List<int> sizeDoubleWidth = [0x1D, 0x21, 0x10];

  /// GS ! 0x11 — double width + double height.
  static const List<int> sizeDouble = [0x1D, 0x21, 0x11];

  // ── Paper cut ─────────────────────────────────────────────────────────

  /// GS V 0 — full cut.
  static const List<int> cutFull = [0x1D, 0x56, 0x00];

  /// GS V 1 — partial cut.
  static const List<int> cutPartial = [0x1D, 0x56, 0x01];

  // ── Initialise / reset ────────────────────────────────────────────────

  /// ESC @ — initialise printer (reset to default settings).
  static const List<int> reset = [0x1B, 0x40];

  // ── Helper: convert text to UTF-8 bytes ───────────────────────────────

  /// Encodes a string as UTF-8 bytes for transmission to the printer.
  static Uint8List textToBytes(String text) {
    return Uint8List.fromList(utf8.encode(text));
  }

  /// Encodes a string followed by a line feed.
  static Uint8List textLine(String text) {
    return Uint8List.fromList([...utf8.encode(text), 0x0A]);
  }

  // ── Builder helpers ───────────────────────────────────────────────────

  /// Build a complete byte payload from a sequence of command/text segments.
  ///
  /// Each element in [segments] can be a `List<int>` (raw bytes/commands)
  /// or a `String` (converted to UTF-8). Returns a single [Uint8List].
  ///
  /// Example:
  /// ```dart
  /// final bytes = EscPosCommands.buildPayload([
  ///   EscPosCommands.reset,
  ///   EscPosCommands.alignCenter,
  ///   EscPosCommands.boldOn,
  ///   'PAYMENT RECEIPT\n',
  ///   EscPosCommands.boldOff,
  ///   EscPosCommands.alignLeft,
  ///   'Customer: John Doe\n',
  ///   EscPosCommands.feed(3),
  ///   EscPosCommands.cutPartial,
  /// ]);
  /// ```
  static Uint8List buildPayload(List<dynamic> segments) {
    final buffer = <int>[];
    for (final segment in segments) {
      if (segment is List<int>) {
        buffer.addAll(segment);
      } else if (segment is String) {
        buffer.addAll(utf8.encode(segment));
      }
    }
    return Uint8List.fromList(buffer);
  }

  /// Build an ESC/POS receipt using the legacy font commands.
  ///
  /// This replicates the Android `write()` method that prefixes each line
  /// with a `bufLinear` font command followed by a carriage return.
  static Uint8List buildLegacyReceipt(List<MapEntry<List<int>, String>> lines) {
    final buffer = <int>[];
    for (final entry in lines) {
      buffer.addAll(entry.key); // font command
      buffer.addAll(utf8.encode(entry.value));
      buffer.addAll(cr);
    }
    // 3 blank lines for paper feed.
    buffer.addAll(cr);
    buffer.addAll(cr);
    buffer.addAll(cr);
    return Uint8List.fromList(buffer);
  }
}
