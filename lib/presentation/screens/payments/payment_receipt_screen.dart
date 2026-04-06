import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../presentation/common/widgets/app_toast.dart';

/// Post-payment receipt screen displayed after a successful payment.
///
/// Shows customer details, receipt number, amounts, payment mode, and date.
/// Provides stub buttons for printing (BLE) and sharing (PDF).
class PaymentReceiptScreen extends StatelessWidget {
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
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = Theme.of(context).extension<AppColors>()!;
    final formattedDate =
        '${paymentDate.day.toString().padLeft(2, '0')}/${paymentDate.month.toString().padLeft(2, '0')}/${paymentDate.year}  ${paymentDate.hour.toString().padLeft(2, '0')}:${paymentDate.minute.toString().padLeft(2, '0')}';

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
                    statusMessage,
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
                    formatCurrency(paidAmount),
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
                    value: customerName,
                  ),
                  _receiptRow(
                    c,
                    label: 'Customer ID',
                    value: customerId,
                  ),
                  _receiptRow(
                    c,
                    label: l.mobile,
                    value: mobileNumber,
                  ),
                  if (address != null && address!.isNotEmpty)
                    _receiptRow(
                      c,
                      label: 'Address',
                      value: address!,
                    ),
                  _receiptRow(
                    c,
                    label: l.receiptNumber,
                    value: receiptNumber,
                    isMono: true,
                  ),
                  _receiptRow(
                    c,
                    label: 'Due Amount',
                    value: formatCurrency(dueAmount),
                    isMono: true,
                    valueColor: c.red,
                  ),
                  _receiptRow(
                    c,
                    label: 'Paid Amount',
                    value: formatCurrency(paidAmount),
                    isMono: true,
                    valueColor: c.green,
                  ),
                  _receiptRow(
                    c,
                    label: l.paymentMode,
                    value: paymentMode,
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
                // Print button (stub)
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        AppToast.show(
                          context,
                          message: 'BLE print coming soon',
                          variant: ToastVariant.info,
                        );
                      },
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
