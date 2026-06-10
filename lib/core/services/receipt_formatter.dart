import 'package:intl/intl.dart';

/// Formats receipt content for thermal printer output.
///
/// All methods return `List<String>` — one element per printed line. The
/// caller is responsible for converting to bytes (via [EscPosCommands]) and
/// sending to the printer (via [BluetoothPrintNotifier]).
///
/// Width parameter: pass `32` for 58mm printers, `40` for 80mm printers.
/// Use [PrinterModel.lineWidth] from the Bluetooth service.
class ReceiptFormatter {
  ReceiptFormatter._();

  // ── String formatting helpers ──────────────────────────────────────────

  /// Pad [text] on the right to [width] characters, truncating if longer.
  static String padRight(String text, int width) {
    if (text.length >= width) return text.substring(0, width);
    return text.padRight(width);
  }

  /// Pad [text] on the left to [width] characters, truncating if longer.
  static String padLeft(String text, int width) {
    if (text.length >= width) return text.substring(0, width);
    return text.padLeft(width);
  }

  /// Center [text] within [width] characters.
  static String center(String text, int width) {
    if (text.length >= width) return text.substring(0, width);
    final totalPad = width - text.length;
    final leftPad = totalPad ~/ 2;
    return '${' ' * leftPad}$text';
  }

  /// Line separator: dots for 58mm (32), dashes for 80mm (40).
  static String separator(int width) {
    if (width >= 40) return '-' * width;
    return '.' * width;
  }

  /// Double separator (equals signs).
  static String doubleSeparator(int width) {
    return '=' * width;
  }

  /// Format a label:value pair where label is left-aligned and value follows.
  static String _field(String label, String value, int width) {
    // Label takes ~38% of line width: 18 chars for 48w, 14 for 32w
    final labelWidth = (width * 0.38).round().clamp(12, 20);
    final padded = label.padRight(labelWidth);
    final valueSpace = width - labelWidth - 1; // -1 for ':'
    final trimmedVal = value.length > valueSpace ? value.substring(0, valueSpace) : value;
    return '$padded:$trimmedVal';
  }

  /// Wrap a long value field across multiple lines.
  /// First line has the label, subsequent lines are indented.
  static List<String> _wrapField(String label, String value, int width) {
    final labelWidth = (width * 0.38).round().clamp(12, 20);
    final padded = label.padRight(labelWidth);
    final prefix = '$padded:';
    final valueWidth = width - prefix.length;
    if (valueWidth <= 0 || value.length <= valueWidth) {
      return [_field(label, value, width)];
    }
    // Split value across multiple lines
    final lines = <String>[];
    final indent = ' ' * prefix.length;
    var remaining = value;
    var first = true;
    while (remaining.isNotEmpty) {
      final chunk = remaining.length > valueWidth
          ? remaining.substring(0, valueWidth)
          : remaining;
      if (first) {
        lines.add('$prefix$chunk');
        first = false;
      } else {
        lines.add('$indent$chunk');
      }
      remaining = remaining.length > valueWidth
          ? remaining.substring(valueWidth)
          : '';
    }
    return lines;
  }

  /// Current date/time in the format used by the Android app:
  /// `DDD MMM DD YYYY HH:MM:SS` (e.g., "Thu Mar 26 2026 10:30:00").
  static String _nowFormatted() {
    final now = DateTime.now();
    final dayName = DateFormat('EEE').format(now);
    final month = DateFormat('MMM').format(now);
    final day = DateFormat('dd').format(now);
    final year = DateFormat('yyyy').format(now);
    final time = DateFormat('HH:mm:ss').format(now);
    return '$dayName $month $day $year $time';
  }

  // ── 1. DEFAULT Payment Receipt (write2) ────────────────────────────────

  /// Formats a standard payment receipt.
  ///
  /// Matches the Android `write2()` / `sendMessage2()` method.
  /// Date/time is centered. Address wraps if too long.
  static List<String> formatPaymentReceipt({
    required String customerName,
    String accountNumber = '',
    required String mobile,
    required String address,
    required String receiptNo,
    required String dueAmount,
    required String paidAmount,
    String? paymentMode,
    String? date,
    int width = 32,
  }) {
    final sep = separator(width);
    final dateStr = date ?? _nowFormatted();
    // Center the date/time line
    final dateDisplay = center(dateStr, width);

    final lines = <String>[
      sep,
      center('PAYMENT RECEIPT', width),
      sep,
      dateDisplay,
      sep,
      _field('CUSTOMER NAME', customerName, width),
    ];
    // Account Number (replaces Customer ID)
    if (accountNumber.isNotEmpty) {
      lines.add(_field('ACCOUNT NO.', accountNumber, width));
    }
    lines.add(_field('MOBILE NO.', mobile, width));
    // Address with wrapping for long values
    if (address.isNotEmpty) {
      lines.addAll(_wrapField('ADDRESS', address, width));
    }
    lines.add(_field('RECEIPT NUMBER', receiptNo, width));
    lines.add(_field('BILL AMT', dueAmount, width));
    lines.add(_field('PAID AMT', paidAmount, width));
    if (paymentMode != null) {
      lines.add(_field('PAYMENT MODE', paymentMode, width));
    }
    lines.addAll([
      sep,
      '', // blank line
      '', // blank line
      '', // blank line (paper feed)
    ]);
    return lines;
  }

  // ── 2. FORMAT1 Payment Receipt — Cheque (write1) ───────────────────────

  /// Formats a cheque payment receipt with bank details.
  ///
  /// Matches the Android `write1()` / `sendMessage1()` method.
  static List<String> formatChequeReceipt({
    required String customerName,
    String accountNumber = '',
    required String mobile,
    required String address,
    required String receiptNo,
    required String dueAmount,
    required String paidAmount,
    required String chequeNo,
    required String bankName,
    required String branch,
    String? date,
    int width = 32,
  }) {
    final sep = separator(width);
    final dateStr = date ?? _nowFormatted();
    final dateDisplay = center(dateStr, width);

    final lines = <String>[
      sep,
      center('PAYMENT RECEIPT', width),
      sep,
      dateDisplay,
      sep,
      _field('CUSTOMER NAME', customerName, width),
    ];
    if (accountNumber.isNotEmpty) {
      lines.add(_field('ACCOUNT NO.', accountNumber, width));
    }
    lines.add(_field('MOBILE NO.', mobile, width));
    if (address.isNotEmpty) {
      lines.addAll(_wrapField('ADDRESS', address, width));
    }
    lines.addAll([
      _field('RECEIPT NUMBER', receiptNo, width),
      _field('BILL AMT', dueAmount, width),
      _field('PAID AMT', paidAmount, width),
      _field('CHEQUE NO.', chequeNo, width),
      _field('BANK NAME', bankName, width),
      _field('BRANCH', branch, width),
      sep,
      '',
      '',
      '',
    ]);
    return lines;
  }

  // ── 3. Legacy ESC/POS Payment Receipt (write) ─────────────────────────

  /// Returns line tuples for legacy ESC/POS receipt formatting.
  ///
  /// Each entry is a `MapEntry<String, String>` where key is a font label
  /// hint (header/body/separator) and value is the text. The caller should
  /// map these to actual ESC/POS font commands from [EscPosCommands].
  static List<MapEntry<String, String>> formatLegacyReceipt({
    required String customerName,
    required String customerId,
    required String address,
    required String receiptNo,
    required String dueAmount,
    required String paidAmount,
    required String outstandingAmount,
    String? date,
  }) {
    final dateStr = date ?? _nowFormatted();
    const sep = '------------------------------------------------'; // 48 chars

    return [
      const MapEntry('header', '         PAYMENT RECEIPT'),
      MapEntry('separator', sep),
      MapEntry('header', dateStr),
      MapEntry('separator', sep),
      MapEntry('body', 'CUSTOMER NAME:$customerName'),
      MapEntry('body', 'CUSTOMER NUMBER:$customerId'),
      MapEntry('body', 'CUSTOMER ADDRESS:$address'),
      MapEntry('body', 'RECEIPT NUMBER:$receiptNo'),
      MapEntry('separator', sep),
      MapEntry('body', 'TOT.DUE.AMT:$dueAmount'),
      MapEntry('body', 'PAID.AMT   :$paidAmount'),
      MapEntry('separator', sep),
      MapEntry('body', 'O/S.AMT    :$outstandingAmount'),
      MapEntry('separator', sep),
      const MapEntry('header', '           POWERED BY'),
      const MapEntry('font2', '      EZYBILL'),
    ];
  }

  // ── 4. Payment History Receipt ─────────────────────────────────────────

  /// Formats a payment history detail receipt.
  ///
  /// Matches the Android `PaymentHistory_write()` method.
  static List<String> formatPaymentHistory({
    required String customerName,
    required String paymentDate,
    required String paymentId,
    required String paymentMode,
    required String amount,
    required String receiptNo,
    required String remarks,
    String? date,
    required int width,
  }) {
    final sep = separator(width);
    final dateStr = date ?? _nowFormatted();

    return [
      sep,
      center('PAYMENT HISTORY', width),
      sep,
      dateStr,
      sep,
      _field('CUSTOMER NAME', customerName, width),
      _field('PAYMENT DATE', paymentDate, width),
      _field('PAYMENT ID', paymentId, width),
      _field('PAYMENT MODE', paymentMode, width),
      _field('AMOUNT', amount, width),
      _field('RECEIPT NO', receiptNo, width),
      _field('REMARKS', remarks, width),
      sep,
      '',
      '',
      '',
    ];
  }

  // ── 5. Invoice History Receipt ─────────────────────────────────────────

  /// Formats an invoice history detail receipt.
  ///
  /// Matches the Android `InvoiceHistory_write()` method.
  static List<String> formatInvoice({
    required String customerName,
    required String invoiceNumber,
    required String invoiceDate,
    required String dueDate,
    required String basePrice,
    required String setupPrice,
    required String taxAmount,
    required String pendingAmount,
    required String discountAmount,
    required String totalAmount,
    required String isAdhoc,
    String? date,
    required int width,
  }) {
    final sep = separator(width);
    final dateStr = date ?? _nowFormatted();

    return [
      sep,
      center('INVOICE HISTORY', width),
      sep,
      dateStr,
      sep,
      _field('CUSTOMER NAME', customerName, width),
      _field('INVOICE NO.', invoiceNumber, width),
      _field('INVOICE DATE', invoiceDate, width),
      _field('DUE DATE', dueDate, width),
      _field('BASE PRICE', basePrice, width),
      _field('SET UP PRICE', setupPrice, width),
      _field('TAX AMOUNT', taxAmount, width),
      _field('PENDING AMOUNT', pendingAmount, width),
      _field('DISCOUNT AMOUNT', discountAmount, width),
      _field('TOTAL AMOUNT', totalAmount, width),
      _field('ADHOC BILLS', isAdhoc, width),
      sep,
      '',
      '',
      '',
    ];
  }

  // ── 6. Employee Collection Report ──────────────────────────────────────

  /// Formats the employee collection summary report.
  ///
  /// Matches the Android `write_reports()` method. Each item in [items]
  /// should contain keys: `custId`, `paidAmt`, `paymentMode`.
  ///
  /// [fromDate] and [toDate] are optional date range labels.
  static List<String> formatEmpCollectionReport({
    required List<Map<String, dynamic>> items,
    String? fromDate,
    String? toDate,
    required int width,
  }) {
    final sep = separator(width);
    final dateStr = _nowFormatted();
    final lines = <String>[
      sep,
      center('REPORTS', width),
      sep,
      dateStr,
      sep,
      'ID          AMOUNT         MODE',
      sep,
    ];

    for (final item in items) {
      final id = padLeft(item['custId']?.toString() ?? '', 12);
      final amt = padLeft(item['paidAmt']?.toString() ?? '', 15);
      final mode = padLeft(item['paymentMode']?.toString() ?? '', 10);
      lines.add('$id$amt$mode');
    }

    lines.addAll([sep, '', '']);
    return lines;
  }

  // ── 7. Collection Detail Report ────────────────────────────────────────

  /// Formats the collection detail report with serial numbers.
  ///
  /// Matches the Android `write_reportscollection()` method.
  /// Each item should contain keys: `name`, `amount`.
  static List<String> formatCollectionDetail({
    required List<Map<String, dynamic>> items,
    String? employeeName,
    required int width,
  }) {
    final sep = separator(width);
    final dateStr = _nowFormatted();
    double totalAmount = 0;

    final lines = <String>[
      sep,
      center('COLLECTION  REPORT', width),
      sep,
      dateStr,
      sep,
    ];

    if (employeeName != null && employeeName.isNotEmpty) {
      lines.add('Employee: $employeeName');
      lines.add(sep);
    }

    lines.add('S.NO    NAME                AMOUNT');
    lines.add(sep);

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final sno = padLeft('${i + 1}', 8);
      final name = padLeft(item['name']?.toString() ?? '', 12);
      final amt = (item['amount'] is double)
          ? item['amount'] as double
          : double.tryParse(item['amount']?.toString() ?? '0') ?? 0;
      totalAmount += amt;
      final amtStr = padLeft(amt.toStringAsFixed(2), 10);
      lines.add('$sno$name$amtStr');
    }

    lines.addAll([
      sep,
      'TOTAL AMOUNT${padLeft(totalAmount.toStringAsFixed(2), width - 12)}',
      sep,
      '',
      '',
    ]);

    return lines;
  }

  // ── 8. Miniday Report ──────────────────────────────────────────────────

  /// Formats the miniday (daily summary) report.
  ///
  /// Matches the Android `write_miniday_reports()` method.
  /// Each item should contain keys: `mode`, `custCount`, `amount`.
  static List<String> formatMiniDayReport({
    required List<Map<String, dynamic>> items,
    String? date,
    double? grandTotal,
    required int width,
  }) {
    final sep = separator(width);
    final dateStr = date ?? _nowFormatted();
    double total = grandTotal ?? 0;

    final lines = <String>[
      sep,
      center('MINIDAY  REPORT', width),
      sep,
      dateStr,
      sep,
      'MODE    COUNT            AMOUNT',
      sep,
    ];

    for (final item in items) {
      final mode = padLeft(item['mode']?.toString() ?? '', 8);
      final count = padLeft(item['custCount']?.toString() ?? '', 12);
      final amt = (item['amount'] is double)
          ? item['amount'] as double
          : double.tryParse(item['amount']?.toString() ?? '0') ?? 0;
      if (grandTotal == null) total += amt;
      final amtStr = padLeft(amt.toStringAsFixed(2), 10);
      lines.add('$mode$count$amtStr');
    }

    lines.addAll([
      sep,
      'TOTAL AMOUNT${padLeft(total.toStringAsFixed(2), width - 12)}',
      sep,
      '',
      '',
    ]);

    return lines;
  }

  // ── 9. Services / Packages Report ──────────────────────────────────────

  /// Formats the activated services/packages report.
  ///
  /// Matches the Android `write_servicesreports()` method.
  /// Each item should contain keys: `packageName`, `startDate`, `endDate`,
  /// `amount`.
  static List<String> formatServicesReport({
    required List<Map<String, dynamic>> packages,
    String? customerName,
    required int width,
  }) {
    final sep = separator(width);
    final dateStr = _nowFormatted();
    double totalAmount = 0;

    final lines = <String>[
      sep,
      center('ACTIVATED PACKAGES', width),
      sep,
      dateStr,
      sep,
    ];

    if (customerName != null && customerName.isNotEmpty) {
      lines.add('Customer: $customerName');
      lines.add(sep);
    }

    lines.add('Name       Start & End Date            Amount');
    lines.add(sep);

    for (final pkg in packages) {
      final name = padRight(pkg['packageName']?.toString() ?? '', 12);
      final start = pkg['startDate']?.toString() ?? '';
      final end = pkg['endDate']?.toString() ?? '';
      final amt = (pkg['amount'] is double)
          ? pkg['amount'] as double
          : double.tryParse(pkg['amount']?.toString() ?? '0') ?? 0;
      totalAmount += amt;
      final amtStr = padLeft(amt.toStringAsFixed(2), 10);
      lines.add('$name$start');
      lines.add('${padRight('', 12)}$end$amtStr');
    }

    lines.addAll([
      sep,
      'TOTAL AMOUNT${padLeft(totalAmount.toStringAsFixed(2), width - 12)}',
      sep,
      '',
      '',
    ]);

    return lines;
  }
}
