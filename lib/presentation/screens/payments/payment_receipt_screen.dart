import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/receipt_formatter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../presentation/common/widgets/app_toast.dart';

/// Post-payment receipt screen displayed after a successful payment.
///
/// Shows customer details, receipt number, amounts, payment mode, and date.
/// Print button connects to the Bluetooth thermal printer via [bluetoothPrintProvider]
/// and uses [ReceiptFormatter.formatPaymentReceipt] to format the output.
class PaymentReceiptScreen extends StatefulWidget {
  final String customerName;
  final String customerId;
  final String mobileNumber;
  final String receiptNumber;
  final double dueAmount;
  final double paidAmount;
  final String paymentMode;
  final DateTime paymentDate;
  final String statusMessage;
  final String? address;
  final String? accountNumber;

  const PaymentReceiptScreen({
    super.key,
    required this.customerName,
    required this.customerId,
    required this.mobileNumber,
    required this.receiptNumber,
    required this.dueAmount,
    required this.paidAmount,
    required this.paymentMode,
    required this.paymentDate,
    required this.statusMessage,
    this.address,
    this.accountNumber,
  });

  @override
  State<PaymentReceiptScreen> createState() =>
      _PaymentReceiptScreenState();
}

class _PaymentReceiptScreenState extends State<PaymentReceiptScreen> {
  // ── Print logic ─────────────────────────────────────────────────────────

  Future<void> _handlePrint() async {
    final c = Theme.of(context).extension<AppColors>()!;

    final didPrint = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: c.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ConnectPrinterBottomSheet(
        c: c,
        receiptBuilder: (int width) => ReceiptFormatter.formatPaymentReceipt(
          customerName: widget.customerName,
          accountNumber: widget.accountNumber ?? '',
          mobile: widget.mobileNumber,
          address: widget.address ?? '',
          receiptNo: widget.receiptNumber,
          dueAmount: formatCurrency(widget.dueAmount),
          paidAmount: formatCurrency(widget.paidAmount),
          paymentMode: widget.paymentMode,
          width: width,
        ),
      ),
    );

    if (didPrint == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(LucideIcons.checkCircle2, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('Receipt printed successfully'),
          ]),
          backgroundColor: c.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = Theme.of(context).extension<AppColors>()!;
    final formattedDate =
        '${widget.paymentDate.day.toString().padLeft(2, '0')}/${widget.paymentDate.month.toString().padLeft(2, '0')}/${widget.paymentDate.year}  ${widget.paymentDate.hour.toString().padLeft(2, '0')}:${widget.paymentDate.minute.toString().padLeft(2, '0')}';

    return Scaffold(

      backgroundColor: c.bg,
      appBar: AppBar(
        title: Text(
          'Payment Receipt',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: c.card,
        foregroundColor: c.ink,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Success Icon & Header ─────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                color: c.greenSoft,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: c.green.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.checkCircle2,
                      size: 36,
                      color: c.green,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l.paymentSuccessful,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: c.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.statusMessage,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: c.ink40,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // ── Paid Amount ───────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: c.card,
                border: Border(
                  left: BorderSide(color: c.ink10),
                  right: BorderSide(color: c.ink10),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Amount Paid',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: c.ink40,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatCurrency(widget.paidAmount),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: c.ink,
                    ),
                  ),
                ],
              ),
            ),

            // ── Dashed divider ────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: c.card,
                border: Border(
                  left: BorderSide(color: c.ink10),
                  right: BorderSide(color: c.ink10),
                ),
              ),
              child: CustomPaint(
                painter: _DashedLinePainter(color: c.ink20),
                size: const Size(double.infinity, 1),
              ),
            ),

            // ── Detail Rows ───────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(14)),
                border: Border(
                  left: BorderSide(color: c.ink10),
                  right: BorderSide(color: c.ink10),
                  bottom: BorderSide(color: c.ink10),
                ),
              ),
              child: Column(
                children: [
                  _receiptRow(
                    c,
                    label: 'Customer Name',
                    value: widget.customerName,
                  ),
                  if (widget.accountNumber != null &&
                      widget.accountNumber!.isNotEmpty)
                    _receiptRow(
                      c,
                      label: 'Account No.',
                      value: widget.accountNumber!,
                      isMono: true,
                    ),
                  _receiptRow(
                    c,
                    label: l.mobile,
                    value: widget.mobileNumber,
                  ),
                  if (widget.address != null && widget.address!.isNotEmpty)
                    _receiptRow(
                      c,
                      label: 'Address',
                      value: widget.address!,
                    ),
                  _receiptRow(
                    c,
                    label: l.receiptNumber,
                    value: widget.receiptNumber,
                    isMono: true,
                  ),
                  _receiptRow(
                    c,
                    label: 'Due Amount',
                    value: formatCurrency(widget.dueAmount),
                    isMono: true,
                    valueColor: c.red,
                  ),
                  _receiptRow(
                    c,
                    label: 'Paid Amount',
                    value: formatCurrency(widget.paidAmount),
                    isMono: true,
                    valueColor: c.green,
                  ),
                  _receiptRow(
                    c,
                    label: l.paymentMode,
                    value: widget.paymentMode,
                  ),
                  _receiptRow(
                    c,
                    label: 'Date & Time',
                    value: formattedDate,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Action Buttons ────────────────────────────────────────
            Row(
              children: [
                // Print button — wired to real BLE printer
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _handlePrint,
                      icon: Icon(LucideIcons.printer, size: 18, color: c.ink60),
                      label: Text(
                        l.print,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: c.ink60,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: c.ink10),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.smBR,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Share button (stub)
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        AppToast.show(
                          context,
                          message: 'PDF share coming soon',
                          variant: ToastVariant.info,
                        );
                      },
                      icon: Icon(LucideIcons.share2, size: 18, color: c.ink60),
                      label: Text(
                        l.share,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: c.ink60,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: c.ink10),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.smBR,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Done Button ───────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  // Pop back to the screen before make-payment
                  // (customer profile or search)
                  Navigator.of(context)
                    ..pop() // receipt screen
                    ..pop(); // make-payment screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.red,
                  foregroundColor: c.card,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.pillBR,
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l.done,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _receiptRow(
    AppColors c, {
    required String label,
    required String value,
    bool isMono = false,
    Color? valueColor,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: c.ink40,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: isMono
                  ? GoogleFonts.jetBrainsMono(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: valueColor ?? c.ink,
                    )
                  : GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: valueColor ?? c.ink,
                    ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints a horizontal dashed line.
class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      color != oldDelegate.color;
}

// ─────────────────────────────────────────────────────────────────────────────
// _ConnectPrinterBottomSheet
//
// Production-grade BLE thermal printer flow:
//   Loading → Device List → Connecting → Connected (Print) → Printing → Done
//
// CRITICAL for multi-customer workflows:
//   - Always disconnect fully before reconnecting
//   - Verify connection with a real status check before writing
//   - Use PrintBluetoothThermal.writeBytes (not raw MethodChannel)
//   - Wait for hardware buffer flush after write
//   - Disconnect cleanly after each print so next session starts fresh
// ─────────────────────────────────────────────────────────────────────────────

enum _SheetState { loading, error, devices, connecting, connected, printing }

class _ConnectPrinterBottomSheet extends StatefulWidget {
  final AppColors c;
  final List<String> Function(int width) receiptBuilder;

  const _ConnectPrinterBottomSheet({
    required this.c,
    required this.receiptBuilder,
  });

  @override
  State<_ConnectPrinterBottomSheet> createState() =>
      _ConnectPrinterBottomSheetState();
}

class _ConnectPrinterBottomSheetState
    extends State<_ConnectPrinterBottomSheet> {
  _SheetState _state = _SheetState.loading;
  List<BluetoothInfo> _devices = [];
  String? _error;
  String _statusMsg = 'Searching for printers...';
  String _connectedName = '';
  String _connectedMac = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  @override
  void dispose() {
    // Do NOT disconnect here — let the print finish naturally.
    // Disconnection happens explicitly in _print() after success.
    super.dispose();
  }

  // ── Init: permissions → BT check → load devices ────────────────────────

  Future<void> _init() async {
    if (!mounted) return;
    setState(() {
      _state = _SheetState.loading;
      _statusMsg = 'Preparing printer...';
      _error = null;
    });

    try {
      // 0. Force-disconnect any stale connection from previous session.
      //    Use generous delay to let BT socket fully release.
      await _forceDisconnect();

      // 1. Permissions
      if (Platform.isAndroid) {
        final results = await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
        ].request();
        if (!mounted) return;
        if (!results.values.every((s) => s.isGranted)) {
          final perm = results.values.any((s) => s.isPermanentlyDenied);
          _setError(perm
              ? 'Bluetooth permission permanently denied.\nPlease grant it in App Settings.'
              : 'Bluetooth permission is required to find printers.');
          return;
        }
      }

      // 2. BT adapter check
      final btOn = await PrintBluetoothThermal.bluetoothEnabled;
      if (!mounted) return;
      if (!btOn) {
        _setError('Bluetooth is turned off.\nPlease enable Bluetooth and try again.');
        return;
      }

      // 3. Load paired devices
      if (mounted) setState(() => _statusMsg = 'Searching for printers...');
      final bonded = await PrintBluetoothThermal.pairedBluetooths;
      if (!mounted) return;
      final filtered = bonded.where((d) => d.macAdress.isNotEmpty).toList();

      if (filtered.isEmpty) {
        _setError('No paired printers found.\nPair your printer in phone Bluetooth Settings first, then tap Retry.');
        return;
      }

      // Check for saved printer — skip device list and auto-connect directly
      try {
        final prefs = await SharedPreferences.getInstance();
        final savedMac = prefs.getString('bluetoothmac');
        if (savedMac != null && savedMac.isNotEmpty) {
          final saved = filtered.where((d) => d.macAdress == savedMac).firstOrNull;
          if (saved != null) {
            setState(() => _devices = filtered);
            _connect(saved);
            return;
          }
        }
      } catch (_) {}
      // No saved printer (or not in paired list) — fall through to normal flow

      // If only one printer, auto-connect for faster UX
      if (filtered.length == 1) {
        setState(() => _devices = filtered);
        _connect(filtered.first);
        return;
      }

      setState(() {
        _devices = filtered;
        _state = _SheetState.devices;
      });
    } catch (e) {
      debugPrint('[BT Print] init error: $e');
      if (mounted) _setError('Failed to load printers:\n$e');
    }
  }

  /// Unconditionally disconnects and waits for Android RFCOMM to fully close.
  /// MUST always disconnect + wait, even if connectionStatus says false —
  /// Android BT can have half-open sockets that report as closed.
  Future<void> _forceDisconnect() async {
    try { await PrintBluetoothThermal.disconnect; } catch (_) {}
    // Android RFCOMM needs ~1s to fully tear down the socket.
    // Shorter delays cause the next connect() to get a stale channel.
    await Future<void>.delayed(const Duration(milliseconds: 1000));
  }

  void _setError(String msg) {
    if (!mounted) return;
    setState(() {
      _state = _SheetState.error;
      _error = msg;
    });
  }

  // ── Connect ─────────────────────────────────────────────────────────────

  Future<void> _connect(BluetoothInfo device) async {
    if (!mounted) return;
    final name = device.name.isNotEmpty ? device.name : 'Printer';
    setState(() {
      _state = _SheetState.connecting;
      _statusMsg = 'Connecting to $name...';
    });

    try {
      // Always tear down any previous socket — even if "not connected"
      await _forceDisconnect();

      final ok = await PrintBluetoothThermal.connect(
        macPrinterAddress: device.macAdress,
      ).timeout(const Duration(seconds: 15), onTimeout: () => false);

      if (!ok) {
        if (mounted) {
          _setError('Could not connect to $name.\nMake sure the printer is ON and nearby.');
        }
        return;
      }

      // Poll connection status to confirm RFCOMM channel is truly open
      bool confirmed = false;
      for (int i = 0; i < 8; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 250));
        try {
          confirmed = await PrintBluetoothThermal.connectionStatus;
        } catch (_) {
          confirmed = false;
        }
        if (confirmed) break;
      }

      if (!confirmed) {
        if (mounted) _setError('Connection unstable — printer may be busy.\nPower cycle the printer and try again.');
        return;
      }

      // ── CRITICAL: Post-connect stabilization ────────────────────────
      // After connect() returns true AND connectionStatus confirms,
      // the RFCOMM channel still needs time to stabilize on Android.
      // Without this, writes to a freshly-connected socket can silently
      // fail (bytes go to buffer but never reach the printer).
      await Future<void>.delayed(const Duration(milliseconds: 800));

      // Re-verify after stabilization — catches connections that drop
      // immediately (printer turned off between connect and now)
      bool stable = false;
      try { stable = await PrintBluetoothThermal.connectionStatus; } catch (_) {}
      if (!stable) {
        if (mounted) _setError('Printer connection dropped.\nMake sure it is powered ON and try again.');
        return;
      }

      // ── CRITICAL: Prime the BT output stream ─────────────────────────
      // Some thermal printer BT modules silently drop the FIRST writeBytes
      // after connect (data goes to buffer but never reaches print head).
      // Sending a probe byte here "primes" the stream so the actual receipt
      // write in _print() is the second call and reaches the printer.
      // A single newline feeds ~1mm of paper — invisible to the user since
      // this happens during the "Connecting..." phase.
      try {
        await PrintBluetoothThermal.writeBytes([0x0A]);
        debugPrint('[BT Print] Probe write OK');
      } catch (e) {
        debugPrint('[BT Print] Probe write failed: $e');
      }
      await Future<void>.delayed(const Duration(milliseconds: 200));

      debugPrint('[BT Print] Connected and stable: $name (${device.macAdress})');
      if (!mounted) return;
      setState(() {
        _state = _SheetState.connected;
        _connectedName = name;
        _connectedMac = device.macAdress;
      });
    } catch (e) {
      debugPrint('[BT Print] connect error: $e');
      if (mounted) _setError('Connection failed:\n$e');
    }
  }

  // ── Print ───────────────────────────────────────────────────────────────

  Future<void> _print() async {
    if (!mounted) return;
    setState(() {
      _state = _SheetState.printing;
      _statusMsg = 'Preparing to print...';
    });

    try {
      // ─── Step 1: Verify connection is alive ───────────────────────────
      bool isConnected = false;
      try { isConnected = await PrintBluetoothThermal.connectionStatus; } catch (_) {}

      if (!isConnected) {
        // Auto-reconnect once — full disconnect→connect→stabilize cycle
        if (mounted) setState(() => _statusMsg = 'Reconnecting...');
        debugPrint('[BT Print] Connection lost, reconnecting to $_connectedMac');

        await _forceDisconnect();
        try {
          final ok = await PrintBluetoothThermal.connect(
            macPrinterAddress: _connectedMac,
          ).timeout(const Duration(seconds: 10), onTimeout: () => false);
          if (ok) {
            // Wait for stabilization (same as _connect)
            await Future<void>.delayed(const Duration(milliseconds: 800));
            isConnected = await PrintBluetoothThermal.connectionStatus;
          }
        } catch (_) {}

        if (!isConnected) {
          if (mounted) _setError('Printer disconnected.\nTap Retry to reconnect.');
          return;
        }
        // Prime stream after reconnect (same as _connect)
        try { await PrintBluetoothThermal.writeBytes([0x0A]); } catch (_) {}
        await Future<void>.delayed(const Duration(milliseconds: 200));
        debugPrint('[BT Print] Reconnected successfully');
      }

      // ─── Step 2: Build receipt bytes at detected width ──────────────
      if (mounted) setState(() => _statusMsg = 'Printing receipt...');

      // Detect printer width from connected device name
      // 97BT- prefix = 80mm thermal (48 chars); default = 58mm (32 chars)
      final int printWidth = _connectedName.toUpperCase().startsWith('97BT-') ? 48 : 32;
      debugPrint('[BT Print] Printer: $_connectedName, width: $printWidth chars');

      final receiptLines = widget.receiptBuilder(printWidth);
      final buf = StringBuffer('\n');
      for (final line in receiptLines) {
        buf.writeln(line.replaceAll('\u20B9', 'Rs.'));
      }
      buf.write('\n\n\n'); // paper feed for tear-off
      final receiptText = buf.toString();
      final List<int> bytes = utf8.encode(receiptText).toList();
      debugPrint('[BT Print] Sending ${bytes.length} bytes');

      // ─── Step 3: Write bytes to printer ────────────────────────────────
      final writeOk = await PrintBluetoothThermal.writeBytes(bytes);
      debugPrint('[BT Print] writeBytes result=$writeOk');

      if (!mounted) return;
      if (!writeOk) {
        _setError('Print failed — data not sent.\nMake sure printer is ON and try again.');
        return;
      }

      // ─── Step 4: Wait for printer to physically finish ────────────────
      if (mounted) setState(() => _statusMsg = 'Printing...');
      await Future<void>.delayed(const Duration(seconds: 2));

      // ─── Step 5: Disconnect cleanly ───────────────────────────────────
      // Always disconnect so the next print session starts fresh.
      try { await PrintBluetoothThermal.disconnect; } catch (_) {}
      await Future<void>.delayed(const Duration(milliseconds: 500));

      debugPrint('[BT Print] Print complete, disconnected');
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      debugPrint('[BT Print] print error: $e');
      if (mounted) {
        _setError('Print error: ${e.toString().length > 80 ? e.toString().substring(0, 80) : e}');
      }
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final c = widget.c;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: c.ink20,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Row(
                children: [
                  Icon(LucideIcons.printer, size: 20, color: c.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _state == _SheetState.connected
                          ? 'Printer Connected'
                          : 'Select Printer',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: c.ink,
                      ),
                    ),
                  ),
                  if (_state == _SheetState.devices ||
                      _state == _SheetState.error)
                    GestureDetector(
                      onTap: _init,
                      child: Icon(LucideIcons.refreshCw, size: 18, color: c.ink40),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Body — based on state
              _buildBody(c),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(AppColors c) {
    switch (_state) {
      case _SheetState.loading:
      case _SheetState.connecting:
      case _SheetState.printing:
        return _buildProgress(c);
      case _SheetState.error:
        return _buildError(c);
      case _SheetState.devices:
        return _buildDevices(c);
      case _SheetState.connected:
        return _buildConnected(c);
    }
  }

  // ── Progress: loading / connecting / printing ───────────────────────────

  Widget _buildProgress(AppColors c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          SizedBox(
            width: 36, height: 36,
            child: CircularProgressIndicator(strokeWidth: 3, color: c.red),
          ),
          const SizedBox(height: 16),
          Text(
            _statusMsg,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14, fontWeight: FontWeight.w500, color: c.ink60,
            ),
          ),
        ],
      ),
    );
  }

  // ── Error ───────────────────────────────────────────────────────────────

  Widget _buildError(AppColors c) {
    final isPerm = _error?.contains('permanently') ?? false;
    return Column(
      children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: c.red.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(LucideIcons.alertTriangle, size: 26, color: c.red),
        ),
        const SizedBox(height: 12),
        Text(
          _error ?? 'Something went wrong',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.ink60, height: 1.5),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 42,
                child: OutlinedButton(
                  onPressed: _init,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: c.ink10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Retry',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, fontWeight: FontWeight.w600, color: c.ink60,
                    ),
                  ),
                ),
              ),
            ),
            if (isPerm) ...[
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () => openAppSettings(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Open Settings',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Device list ─────────────────────────────────────────────────────────

  Widget _buildDevices(AppColors c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paired Bluetooth Devices',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: c.ink40, letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        ..._devices.map((d) {
          final name = d.name.isNotEmpty ? d.name : 'Unknown Device';
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: c.bg,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _connect(d),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: c.ink10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: c.red.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(LucideIcons.printer, size: 20, color: c.red),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14, fontWeight: FontWeight.w600, color: c.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(d.macAdress,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11, color: c.ink40,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(LucideIcons.chevronRight, size: 18, color: c.ink20),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── Connected — show Print button ───────────────────────────────────────

  Widget _buildConnected(AppColors c) {
    return Column(
      children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: c.green.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(LucideIcons.checkCircle2, size: 30, color: c.green),
        ),
        const SizedBox(height: 12),
        Text(
          'Connected to $_connectedName',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15, fontWeight: FontWeight.w600, color: c.green,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Tap below to print the receipt',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.ink40),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _print,
            icon: const Icon(LucideIcons.printer, size: 18),
            label: Text(
              'Print Receipt',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15, fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: c.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
