import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../application/providers/payment_provider.dart';
import '../../../core/config/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/payment/make_payment_request.dart';
import '../../../data/models/payment/payment_mode.dart';
import '../../../presentation/common/widgets/app_toast.dart';
import 'payment_receipt_screen.dart';
import '../../../l10n/app_localizations.dart';

class MakePaymentScreen extends ConsumerStatefulWidget {
  final String? customerId;
  final String? customerName;
  final double? initialPendingAmount;

  const MakePaymentScreen({
    super.key,
    this.customerId,
    this.customerName,
    this.initialPendingAmount,
  });

  @override
  ConsumerState<MakePaymentScreen> createState() => _MakePaymentScreenState();
}

class _MakePaymentScreenState extends ConsumerState<MakePaymentScreen> {
  final _amountController = TextEditingController();
  final _receiptController = TextEditingController();
  final _remarksController = TextEditingController();
  final _chequeNoController = TextEditingController();
  final _bankController = TextEditingController();
  final _branchController = TextEditingController();
  final _voucherCodeController = TextEditingController();

  DateTime? _chequeDate;
  String _cardType = 'debit'; // debit or credit

  @override
  void initState() {
    super.initState();
    if(widget.initialPendingAmount !=null &&
    widget.initialPendingAmount! >0){
      _amountController.text = widget.initialPendingAmount!.toStringAsFixed(2);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPaymentBlocked();
      _initializeData();
    });
  }

  void _checkPaymentBlocked() {
    final session = ref.read(appSessionProvider);
    if (session?.isPaymentBlocked == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(
            'Payment Blocked',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Payments have been blocked for your account. Please contact your administrator.',
            style: GoogleFonts.plusJakartaSans(fontSize: 14),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('OK',
                  style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    }
  }

  void _initializeData() {
    final notifier = ref.read(paymentProvider.notifier);
    notifier.loadPaymentModes();
    if (widget.customerId != null) {
      notifier.loadPendingAmount(widget.customerId!);
    }
    // Load receipt ranges if AUTO_RECEIPT_NUMBER == 0 (manual receipt selection)
    final session = ref.read(appSessionProvider);
    if (session?.autoReceiptNumber == 0) {
      notifier.loadReceiptRanges();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _receiptController.dispose();
    _remarksController.dispose();
    _chequeNoController.dispose();
    _bankController.dispose();
    _branchController.dispose();
    _voucherCodeController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Mode key normalization — maps PaymentModeName to a canonical key
  // ─────────────────────────────────────────────────────────────────────────

  String _modeKey(PaymentMode? mode) {
    if (mode == null) return 'cash';
    final name = mode.paymentModeName.toLowerCase().trim();
    if (name.contains('cheque') || name.contains('bank')) return 'cheque';
    if (name.contains('card')) return 'card';
    if (name.contains('voucher')) return 'voucher';
    if (name.contains('upi')) return 'upi';
    return 'cash';
  }

  /// Returns the modeType string to send to the API based on the mode key.
  String _modeTypeString(String modeKey) {
    switch (modeKey) {
      case 'cheque':
        return 'bank';
      case 'card':
        return 'card';
      case 'voucher':
        return 'voucher';
      case 'upi':
        return 'upi';
      default:
        return 'cash';
    }
  }

  /// Returns the button label per mode — exact Android parity.
  String _buttonLabel(String modeKey, AppLocalizations l) {
    switch (modeKey) {
      case 'cheque':
        return l.payByCheque;
      case 'card':
        return l.payByCard;
      case 'voucher':
        return l.payByVoucher;
      case 'upi':
        return l.pay;
      default:
        return l.payByCash;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Visibility helpers — per field/mode matrix from doc section 1.3
  // ─────────────────────────────────────────────────────────────────────────

  bool _showAmountRow(String modeKey) => modeKey != 'voucher';

  bool _showReceiptRow(String modeKey) =>
      modeKey == 'cash' || modeKey == 'upi';

  bool _showChequeFields(String modeKey) => modeKey == 'cheque';

  bool _showVoucherField(String modeKey) => modeKey == 'voucher';

  bool _showCardType(String modeKey) => modeKey == 'card';

  bool _showQrArea(String modeKey) => modeKey == 'upi';

  // ─────────────────────────────────────────────────────────────────────────
  // Submit payment — implements ALL validation rules from doc sections
  // 1.5, 1.6, 1.7, 1.8, 1.9, 1.10
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _submitPayment() async {
    final c = Theme.of(context).extension<AppColors>()!;
    final payState = ref.read(paymentProvider);
    final session = ref.read(appSessionProvider);
    final pending = payState.pendingAmount;
    final mode = payState.selectedMode;
    final modeKey = _modeKey(mode);
    final pendingAmt = pending?.pendingAmount ?? 0.0;
    final isLcoDeposit = session?.useLcoDeposit == 1;

    // ── 1. Voucher mode validation (section 1.7) ──────────────────────────
    if (modeKey == 'voucher') {
      final code = _voucherCodeController.text.trim();
      if (code.isEmpty) {
        AppToast.show(context,
            message: 'Please enter a voucher code.',
            variant: ToastVariant.info);
        return;
      }
    }

    // ── 2. Amount validation (section 1.5) ─────────────────────────────────
    double enteredAmount = 0.0;
    if (modeKey == 'voucher') {
      enteredAmount = 0.0; // Amount is always 0 for voucher
    } else if (isLcoDeposit) {
      // useLcoDeposit == 1: Amount locked to pendingAmount, no validation
      enteredAmount = pendingAmt;
    } else {
      // useLcoDeposit == 0: editable field — full validation
      final amountText = _amountController.text.trim();
      final parsed = double.tryParse(amountText) ?? 0.0;

      // Rule 1: amount == 0 → block
      if (parsed == 0.0) {
        _showBlockDialog('Empty Fields!', 'Amount should not be empty');
        return;
      }

      enteredAmount = parsed;

      // Rule 2: amount < pendingAmount → block
      if (enteredAmount < pendingAmt) {
        _showBlockDialog(
          'Invalid Amount',
          'Entered amount ${formatCurrency(enteredAmount)}, is less than the actual pending amount - ${formatCurrency(pendingAmt)}, please enter actual pending amount or excess amount to continue',
        );
        return;
      }

      // Rule 3: amount >= pendingAmount → confirmation dialog
      // (includes exact match per Android: "is more than" dialog shown for >= )
      if (enteredAmount > pendingAmt && pendingAmt > 0) {
        final proceed =
            await _showExcessAmountDialog(enteredAmount, pendingAmt);
        if (proceed != true) return;
      }
    }

    // ── 3. Card mode validation (section 1.8) ─────────────────────────────
    if (modeKey == 'card') {
      // Amount must not be zero (already checked above for non-voucher modes)
      if (_cardType.isEmpty) {
        AppToast.show(context,
            message: 'Please select card type',
            variant: ToastVariant.info);
        return;
      }
    }

    // ── 4. Bank/Cheque mode validation (section 1.6) ──────────────────────
    if (modeKey == 'cheque') {
      if (_chequeNoController.text.trim().isEmpty ||
          _bankController.text.trim().isEmpty ||
          _branchController.text.trim().isEmpty ||
          _chequeDate == null) {
        _showBlockDialog('Empty Fields!', 'Fields should not be empty.');
        return;
      }
      // Cheque date must not be before today
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final chequeDay =
          DateTime(_chequeDate!.year, _chequeDate!.month, _chequeDate!.day);
      if (chequeDay.isBefore(todayDate)) {
        _showBlockDialog(
            'Invalid Date', 'Cheque date must not be before today.');
        return;
      }
    }

    // ── 5. Receipt number validation (section 1.4) ────────────────────────
    if (_showReceiptRow(modeKey)) {
      if (session?.autoReceiptNumber == 0) {
        // AUTO_RECEIPT_NUMBER == 0: must select a receipt range
        if (payState.selectedReceiptRange == null) {
          AppToast.show(context,
              message: 'Select valid Receipt Number.',
              variant: ToastVariant.info);
          return;
        }
      }
      // AUTO_RECEIPT_NUMBER == 1: user can type freely, no mandatory validation
    }

    // ── 6. Build remarks with suffix (section 1.9) ────────────────────────
    final userRemarks = _remarksController.text.trim();
    final fullRemarks = userRemarks.isEmpty
        ? 'Paid From Flutter App'
        : '$userRemarks. Paid From Flutter App';

    // ── 7. Build receipt number ───────────────────────────────────────────
    String? receiptNumber;
    if (_showReceiptRow(modeKey)) {
      if (session?.autoReceiptNumber == 0) {
        receiptNumber = payState.selectedReceiptRange?.currentNumber;
      } else if (session?.autoReceiptNumber != 0) {
        final typed = _receiptController.text.trim();
        receiptNumber = typed.isNotEmpty ? typed : null;
      }
    }

    // ── 8. Build MakePaymentRequest (section 1.10) ────────────────────────
    final modeTypeStr = _modeTypeString(modeKey);

    final request = MakePaymentRequest(
      altCustomerId: widget.customerId ?? '',
      amount: enteredAmount,
      modeType: modeTypeStr,
      receiptNumber: receiptNumber,
      altReceiptNumber: receiptNumber, // altReceiptNumber if available
      remarks: fullRemarks,
      billingId: pending?.billingId,
      // Bank/Cheque fields
      chequeNo:
          modeKey == 'cheque' ? _chequeNoController.text.trim() : null,
      bank: modeKey == 'cheque' ? _bankController.text.trim() : null,
      branch: modeKey == 'cheque' ? _branchController.text.trim() : null,
      chequeDate: modeKey == 'cheque' && _chequeDate != null
          ? '${_chequeDate!.year}-${_chequeDate!.month.toString().padLeft(2, '0')}-${_chequeDate!.day.toString().padLeft(2, '0')}'
          : modeKey == 'cheque'
              ? '0000-00-00'
              : null,
      // Card fields
      cardType: modeKey == 'card' ? _cardType : null,
      rrnNo: modeKey == 'card' ? '' : null, // rrnNo sent empty for card
      // Voucher fields
      voucherCode:
          modeKey == 'voucher' ? _voucherCodeController.text.trim() : null,
    );

    // ── 9. Execute payment ────────────────────────────────────────────────
    final success =
        await ref.read(paymentProvider.notifier).makePayment(request);

    if (!mounted) return;

    // ── 10. Post-payment handling (section 1.11) ──────────────────────────
    if (success) {
      final result = ref.read(paymentProvider).paymentResult;
      if (result == null) return;

      if (result.statusCode == 0) {
        // Navigate to receipt screen with response data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentReceiptScreen(
              customerName:
                  pending?.customerName ?? widget.customerName ?? '',
              customerId: widget.customerId ?? '',
              mobileNumber: pending?.mobileNumber ?? '',
              receiptNumber: result.receiptNumber,
              dueAmount: pendingAmt,
              paidAmount: enteredAmount,
              paymentMode: mode?.paymentModeName ?? 'Cash',
              paymentDate: DateTime.now(),
              statusMessage: result.statusMsg,
            ),
          ),
        );
      } else {
        // statusCode >= 1: show error dialog with status_msg and pop back
        _showErrorAndPop(result.statusMsg);
      }
    } else {
      // API failure (network error, exception, etc.)
      final payState2 = ref.read(paymentProvider);
      _showErrorDialog(
          'Payment Failed!', payState2.errorMessage ?? 'Server is busy or unreachable!');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Dialog helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// Blocks the payment with an OK-only dialog (section 1.5 rules 1 & 2,
  /// section 1.6 bank validation).
  void _showBlockDialog(String title, String message) {
    final c = Theme.of(context).extension<AppColors>()!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: c.red,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: c.ink80),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: c.red,
              foregroundColor: c.card,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('OK',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  /// Excess amount confirmation dialog (section 1.5 rule 3).
  /// Returns true if user clicks OK to proceed, false/null if Cancel.
  Future<bool?> _showExcessAmountDialog(double entered, double pending) {
    final c = Theme.of(context).extension<AppColors>()!;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'If you wish to pay excess amount click on OK else cancel the transaction by clicking on cancel',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: c.amber,
          ),
        ),
        content: Text(
          'Entered amount ${formatCurrency(entered)}, is more than the actual pending amount - ${formatCurrency(pending)}.',
          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: c.ink80),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.plusJakartaSans(color: c.ink40)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: c.amber,
              foregroundColor: c.card,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('OK',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  /// Shows error dialog with server status_msg then pops back (section 1.11).
  void _showErrorAndPop(String message) {
    final c = Theme.of(context).extension<AppColors>()!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Payment Failed!',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: c.red,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: c.ink80),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: c.red,
              foregroundColor: c.card,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('OK',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  /// Generic error dialog (does NOT pop the screen).
  void _showErrorDialog(String title, String message) {
    final c = Theme.of(context).extension<AppColors>()!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: c.red,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: c.ink80),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: c.red,
              foregroundColor: c.card,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('OK',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Receipt range picker bottom sheet
  // ─────────────────────────────────────────────────────────────────────────

  void _showReceiptRangePicker() {
    final c = Theme.of(context).extension<AppColors>()!;
    final payState = ref.read(paymentProvider);
    final ranges = payState.receiptRanges;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String search = '';
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final filtered = search.isEmpty
                ? ranges
                : ranges
                    .where((r) =>
                        r.currentNumber
                            .toLowerCase()
                            .contains(search.toLowerCase()) ||
                        r.fromNumber
                            .toLowerCase()
                            .contains(search.toLowerCase()))
                    .toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              maxChildSize: 0.85,
              minChildSize: 0.3,
              expand: false,
              builder: (_, scrollCtrl) => Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: c.ink20,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Select Receipt Number',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: c.ink,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: (v) => setModalState(() => search = v),
                      style: GoogleFonts.plusJakartaSans(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search receipt range...',
                        hintStyle: GoogleFonts.plusJakartaSans(
                            color: c.ink40, fontSize: 14),
                        prefixIcon:
                            Icon(LucideIcons.search, size: 18, color: c.ink40),
                        filled: true,
                        fillColor: c.ink05,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Text(
                                'No receipt ranges found',
                                style: GoogleFonts.plusJakartaSans(
                                    color: c.ink40),
                              ),
                            )
                          : GridView.builder(
                              controller: scrollCtrl,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                childAspectRatio: 2.5,
                              ),
                              itemCount: filtered.length,
                              itemBuilder: (_, i) {
                                final range = filtered[i];
                                final isSelected = payState
                                        .selectedReceiptRange?.rangeId ==
                                    range.rangeId;
                                return GestureDetector(
                                  onTap: () {
                                    ref
                                        .read(paymentProvider.notifier)
                                        .selectReceiptRange(range);
                                    Navigator.pop(ctx);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? c.red.withValues(alpha: 0.1)
                                          : c.card,
                                      borderRadius:
                                          BorderRadius.circular(10),
                                      border: Border.all(
                                        color:
                                            isSelected ? c.red : c.ink10,
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          range.currentNumber,
                                          style: GoogleFonts.jetBrainsMono(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? c.red
                                                : c.ink,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${range.fromNumber} - ${range.toNumber}',
                                          style:
                                              GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            color: c.ink40,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Cheque date picker — firstDate is today (cannot pick past dates)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _pickChequeDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _chequeDate ?? DateTime.now(),
      firstDate: DateTime.now(), // Cheque date must NOT be before today
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _chequeDate = picked);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = Theme.of(context).extension<AppColors>()!;
    final payState = ref.watch(paymentProvider);
    final session = ref.watch(appSessionProvider);
    final modeKey = _modeKey(payState.selectedMode);
    final isLcoDeposit = session?.useLcoDeposit == 1;
    final isAutoReceiptOff = session?.autoReceiptNumber == 0;
    final isAutoReceiptOn = session?.autoReceiptNumber != 0;

    // Pre-fill amount when useLcoDeposit == 1 and pending is loaded
    if (payState.pendingAmount != null) {
      final serverAmt =
          payState.pendingAmount!.pendingAmount.toStringAsFixed(2);
          if(isLcoDeposit){
            if(_amountController.text !=serverAmt){
              _amountController.text = serverAmt;
            }
          }else{
            final initialText = widget.initialPendingAmount?.toStringAsFixed(2) ?? '';
            if(_amountController.text.isEmpty ||
            _amountController.text == initialText){
              _amountController.text = serverAmt;
            }
          }
    }

    // Listen for errors from provider
    ref.listen<PaymentState>(paymentProvider, (prev, next) {
      if (next.errorMessage != null &&
          prev?.errorMessage != next.errorMessage) {
        AppToast.show(context,
            message: next.errorMessage!, variant: ToastVariant.info);
        ref.read(paymentProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: Text(
          l.makePayment,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: c.card,
        foregroundColor: c.ink,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Customer Info Banner ─────────────────────────────────────
            _buildCustomerBanner(c, payState),

            const SizedBox(height: 16),

            // ── Payment Mode Chips ──────────────────────────────────────
            if (payState.paymentModes.isNotEmpty) ...[
              Text(
                l.paymentMode,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: c.ink60,
                ),
              ),
              const SizedBox(height: 10),
              _buildModeChips(c, payState),
              const SizedBox(height: 20),
            ],

            // ── Payment Form ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: AppRadius.cardBR,
                boxShadow: AppShadow.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Details',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: c.ink,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Amount field: VISIBLE for all except Voucher.
                  //    DISABLED when useLcoDeposit == 1. ───────────────
                  if (_showAmountRow(modeKey))
                    _buildAmountField(c, isLcoDeposit),

                  // ── Receipt Number row: VISIBLE for Cash and UPI only ──
                  if (_showReceiptRow(modeKey)) ...[
                    // AUTO_RECEIPT_NUMBER == 1 (non-zero): show text field
                    if (isAutoReceiptOn) ...[
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _receiptController,
                        label: l.receiptNumber,
                        icon: LucideIcons.receipt,
                        colors: c,
                      ),
                    ],
                    // AUTO_RECEIPT_NUMBER == 0: show receipt range picker
                    if (isAutoReceiptOff) ...[
                      const SizedBox(height: 14),
                      _buildReceiptRangePicker(c, payState),
                    ],
                  ],

                  // ── Cheque/Bank fields: VISIBLE for Bank mode only ─────
                  if (_showChequeFields(modeKey)) ...[
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: _chequeNoController,
                      label: 'Cheque / DD Number',
                      icon: LucideIcons.fileText,
                      colors: c,
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: _bankController,
                      label: 'Bank Name',
                      icon: LucideIcons.landmark,
                      colors: c,
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: _branchController,
                      label: 'Branch',
                      icon: LucideIcons.mapPin,
                      colors: c,
                    ),
                    const SizedBox(height: 14),
                    _buildChequeDatePicker(c),
                  ],

                  // ── Card type selector: VISIBLE for Card mode only ─────
                  if (_showCardType(modeKey)) ...[
                    const SizedBox(height: 14),
                    _buildCardTypeSelector(c),
                  ],

                  // ── Voucher code: VISIBLE for Voucher mode only ────────
                  if (_showVoucherField(modeKey)) ...[
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: _voucherCodeController,
                      label: l.voucherCode,
                      icon: LucideIcons.ticket,
                      colors: c,
                    ),
                  ],

                  // ── QR Code image area: VISIBLE for UPI only ───────────
                  if (_showQrArea(modeKey)) ...[
                    const SizedBox(height: 14),
                    _buildQrCodeArea(c),
                  ],

                  // ── Remarks: shown for ALL modes ───────────────────────
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _remarksController,
                    label: l.remarks,
                    icon: LucideIcons.messageSquare,
                    colors: c,
                    maxLines: 2,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Pay Button with mode-specific label ──────────────────────
            _buildPayButton(c, payState, modeKey, l),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Sub-widgets
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildCustomerBanner(AppColors c, PaymentState payState) {
    final pending = payState.pendingAmount;
    final name = pending?.customerName ?? widget.customerName ?? '';
    final mobile = pending?.mobileNumber ?? '';
    final pendingAmt = pending?.pendingAmount;

    if (name.isEmpty && pending == null) {
      if (payState.phase == PaymentPhase.loadingPending) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: AppRadius.cardBR,
            boxShadow: AppShadow.card,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: c.red,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Loading customer details...',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, color: c.ink40),
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    }

    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: AppRadius.cardBR,
        boxShadow: AppShadow.card,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: c.red.withValues(alpha: 0.1),
            child: Text(
              initial,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: c.red,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: c.ink,
                  ),
                ),
                if (mobile.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    mobile,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: c.ink40,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  'ID: ${widget.customerId ?? ''}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: c.ink40,
                  ),
                ),
              ],
            ),
          ),
          if (pendingAmt != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Pending',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: c.ink40,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatCurrency(pendingAmt),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: c.red,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildModeChips(AppColors c, PaymentState payState) {
    final modes = payState.paymentModes;
    final selected = payState.selectedMode;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: modes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final mode = modes[i];
          final isActive =
              selected?.paymentModeId == mode.paymentModeId;
          final mKey = _modeKey(mode);

          IconData icon;
          switch (mKey) {
            case 'cheque':
              icon = LucideIcons.fileText;
            case 'card':
              icon = LucideIcons.creditCard;
            case 'voucher':
              icon = LucideIcons.ticket;
            case 'upi':
              icon = LucideIcons.smartphone;
            default:
              icon = LucideIcons.banknote;
          }

          return GestureDetector(
            onTap: () {
              ref.read(paymentProvider.notifier).selectPaymentMode(mode);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? c.red : c.card,
                borderRadius: AppRadius.pillBR,
                border: Border.all(
                  color: isActive ? c.red : c.ink10,
                  width: isActive ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isActive ? c.card : c.ink60,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    mode.paymentModeName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive ? c.card : c.ink60,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAmountField(AppColors c, bool locked) {
    return TextField(
      controller: _amountController,
      enabled: !locked,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      style: GoogleFonts.jetBrainsMono(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: locked ? c.ink40 : c.ink,
      ),
      decoration: InputDecoration(
        labelText: 'Amount',
        labelStyle: GoogleFonts.plusJakartaSans(color: c.ink40),
        prefixText: '\u20B9 ',
        prefixStyle: GoogleFonts.jetBrainsMono(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: c.ink,
        ),
        filled: true,
        fillColor: locked ? c.ink05 : c.bg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.ink10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.ink10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.red, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.ink10),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required AppColors colors,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.plusJakartaSans(fontSize: 14, color: colors.ink),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.plusJakartaSans(color: colors.ink40),
        prefixIcon: Icon(icon, size: 18, color: colors.ink40),
        filled: true,
        fillColor: colors.bg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.ink10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.ink10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.red, width: 2),
        ),
      ),
    );
  }

  Widget _buildReceiptRangePicker(AppColors c, PaymentState payState) {
    final selected = payState.selectedReceiptRange;
    return GestureDetector(
      onTap: _showReceiptRangePicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: c.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.ink10),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.receipt, size: 18, color: c.ink40),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selected != null
                    ? 'Receipt: ${selected.currentNumber}'
                    : 'Select Receipt Number',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: selected != null ? c.ink : c.ink40,
                ),
              ),
            ),
            Icon(LucideIcons.chevronDown, size: 18, color: c.ink40),
          ],
        ),
      ),
    );
  }

  Widget _buildChequeDatePicker(AppColors c) {
    final dateText = _chequeDate != null
        ? '${_chequeDate!.day.toString().padLeft(2, '0')}/${_chequeDate!.month.toString().padLeft(2, '0')}/${_chequeDate!.year}'
        : 'Select Cheque Date';
    return GestureDetector(
      onTap: _pickChequeDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: c.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.ink10),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.calendar, size: 18, color: c.ink40),
            const SizedBox(width: 12),
            Text(
              dateText,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: _chequeDate != null ? c.ink : c.ink40,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardTypeSelector(AppColors c) {
    return Row(
      children: [
        Text(
          'Card Type:',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: c.ink60,
          ),
        ),
        const SizedBox(width: 16),
        _buildCardChip(c, 'Debit', 'debit'),
        const SizedBox(width: 8),
        _buildCardChip(c, 'Credit', 'credit'),
      ],
    );
  }

  Widget _buildCardChip(AppColors c, String label, String value) {
    final isActive = _cardType == value;
    return GestureDetector(
      onTap: () => setState(() => _cardType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? c.red.withValues(alpha: 0.1) : c.bg,
          borderRadius: AppRadius.pillBR,
          border: Border.all(
            color: isActive ? c.red : c.ink10,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? c.red : c.ink60,
          ),
        ),
      ),
    );
  }

  /// QR code image area placeholder for UPI Payment mode.
  Widget _buildQrCodeArea(AppColors c) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: c.ink05,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.ink10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.qrCode, size: 64, color: c.ink20),
          const SizedBox(height: 8),
          Text(
            'QR Code',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: c.ink40,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Scan to pay via UPI',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: c.ink40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton(AppColors c, PaymentState payState, String modeKey, AppLocalizations l) {
    final isProcessing = payState.phase == PaymentPhase.processing;
    final label = _buttonLabel(modeKey, l);

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isProcessing ? null : _submitPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: c.red,
          foregroundColor: c.card,
          disabledBackgroundColor: c.red.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.pillBR,
          ),
          elevation: 0,
        ),
        child: isProcessing
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: c.card,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Processing...',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
