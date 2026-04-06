import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../application/providers/lco_payment_provider.dart';
import '../../../core/config/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/lco/lco_payment_request.dart';
import '../../common/widgets/app_toast.dart';

/// Two-phase LCO Payment screen.
///
/// Phase 1: Search an LCO by code.
/// Phase 2: Fill in payment details and submit.
class LcoPaymentScreen extends ConsumerStatefulWidget {
  const LcoPaymentScreen({super.key});

  @override
  ConsumerState<LcoPaymentScreen> createState() => _LcoPaymentScreenState();
}

class _LcoPaymentScreenState extends ConsumerState<LcoPaymentScreen> {
  final _lcoCodeController = TextEditingController();
  final _amountController = TextEditingController();
  final _remarksController = TextEditingController();
  final _chequeNoController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _branchController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isBankMode = false;
  bool _isAdjustment = false;
  String _adjustmentType = 'credit'; // 'credit' or 'debit'
  DateTime? _chequeDate;

  @override
  void dispose() {
    _lcoCodeController.dispose();
    _amountController.dispose();
    _remarksController.dispose();
    _chequeNoController.dispose();
    _bankNameController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  // ── Search ──────────────────────────────────────────────────────────────

  Future<void> _onSearch() async {
    final code = _lcoCodeController.text.trim();
    if (code.isEmpty) {
      AppToast.show(context,
          message: 'Enter an LCO code to search.', variant: ToastVariant.info);
      return;
    }
    await ref.read(lcoPaymentProvider.notifier).searchLco(code);

    if (!mounted) return;
    final st = ref.read(lcoPaymentProvider);
    if (st.hasSearchResult) {
      _amountController.text = st.pendingAmount.toStringAsFixed(2);
    }
  }

  // ── Payment ─────────────────────────────────────────────────────────────

  Future<void> _onPay() async {
    if (!_formKey.currentState!.validate()) return;

    final session = ref.read(appSessionProvider);
    if (session == null) return;

    final st = ref.read(lcoPaymentProvider);

    final request = LcoPaymentRequest(
      authToken: session.token,
      lcoEmployeeId: session.employeeId.toString(),
      lcoBillingId: st.lcoBillingId,
      receiptNumber: '',
      amount: double.tryParse(_amountController.text.trim()) ?? 0,
      mode: _isBankMode ? 'Bank' : 'Cash',
      adjustFlag: _isAdjustment ? 1 : 0,
      dabitCredit: _isAdjustment ? _adjustmentType : '',
      accept: 1,
      chequeDdnumber: _isBankMode ? _chequeNoController.text.trim() : null,
      chequeDate: _isBankMode && _chequeDate != null
          ? '${_chequeDate!.year}-${_chequeDate!.month.toString().padLeft(2, '0')}-${_chequeDate!.day.toString().padLeft(2, '0')}'
          : null,
      bank: _isBankMode ? _bankNameController.text.trim() : null,
      branch: _isBankMode ? _branchController.text.trim() : null,
      remarks: _remarksController.text.trim(),
    );

    final success =
        await ref.read(lcoPaymentProvider.notifier).makeLcoPayment(request);

    if (!mounted) return;
    if (success) {
      AppToast.show(context,
          message: 'Payment successful!', variant: ToastVariant.success);
    }
  }

  // ── Cheque date picker ──────────────────────────────────────────────────

  Future<void> _pickChequeDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _chequeDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _chequeDate = picked);
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final st = ref.watch(lcoPaymentProvider);

    // Listen for error messages.
    ref.listen<LcoPaymentState>(lcoPaymentProvider, (prev, next) {
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        AppToast.show(context,
            message: next.errorMessage!, variant: ToastVariant.info);
        ref.read(lcoPaymentProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('LCO Payment'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Phase 1: Search Panel ──────────────────────────────────
              _buildSearchPanel(c, st),
              const SizedBox(height: 16),

              // ── LCO Details (after search) ─────────────────────────────
              if (st.hasSearchResult) ...[
                _buildLcoDetailsCard(c, st),
                const SizedBox(height: 16),

                // ── Phase 2: Payment Panel ───────────────────────────────
                _buildPaymentPanel(c, st),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Search Panel ────────────────────────────────────────────────────────

  Widget _buildSearchPanel(AppColors c, LcoPaymentState st) {
    return Container(
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
            'SEARCH LCO',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: c.ink40,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _lcoCodeController,
                  decoration: const InputDecoration(
                    hintText: 'Enter LCO Code',
                    prefixIcon: Icon(LucideIcons.search, size: 18),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _onSearch(),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed:
                      st.phase == LcoPaymentPhase.searching ? null : _onSearch,
                  child: st.phase == LcoPaymentPhase.searching
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Search'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── LCO Details Card ───────────────────────────────────────────────────

  Widget _buildLcoDetailsCard(AppColors c, LcoPaymentState st) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.blueSoft,
        borderRadius: AppRadius.cardBR,
        border: Border.all(color: c.blue.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LCO DETAILS',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: c.ink40,
            ),
          ),
          const SizedBox(height: 8),
          _detailRow(c, 'Name', st.lcoName),
          const SizedBox(height: 4),
          _detailRow(c, 'Address', st.lcoAddress),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'Pending Amount:  ',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: c.ink60,
                ),
              ),
              Text(
                formatCurrency(st.pendingAmount),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
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

  Widget _detailRow(AppColors c, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            '$label:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: c.ink60,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : '--',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: c.ink,
            ),
          ),
        ),
      ],
    );
  }

  // ── Payment Panel ───────────────────────────────────────────────────────

  Widget _buildPaymentPanel(AppColors c, LcoPaymentState st) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: AppRadius.cardBR,
        boxShadow: AppShadow.card,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PAYMENT DETAILS',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: c.ink40,
              ),
            ),
            const SizedBox(height: 16),

            // Amount
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '\u20B9 ',
                prefixStyle: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: c.ink,
                ),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter an amount';
                final amt = double.tryParse(v.trim());
                if (amt == null || amt <= 0) return 'Amount must be > 0';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Payment Mode Toggle
            Text(
              'Payment Mode',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: c.ink60,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _modeChip(c, 'Cash', !_isBankMode, () {
                  setState(() => _isBankMode = false);
                }),
                const SizedBox(width: 8),
                _modeChip(c, 'Bank', _isBankMode, () {
                  setState(() => _isBankMode = true);
                }),
              ],
            ),
            const SizedBox(height: 16),

            // Bank fields (conditional)
            if (_isBankMode) ...[
              TextFormField(
                controller: _chequeNoController,
                decoration:
                    const InputDecoration(labelText: 'Cheque / DD Number'),
                validator: (v) {
                  if (_isBankMode && (v == null || v.trim().isEmpty)) {
                    return 'Required for bank payments';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bankNameController,
                decoration: const InputDecoration(labelText: 'Bank Name'),
                validator: (v) {
                  if (_isBankMode && (v == null || v.trim().isEmpty)) {
                    return 'Required for bank payments';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _branchController,
                decoration: const InputDecoration(labelText: 'Branch'),
                validator: (v) {
                  if (_isBankMode && (v == null || v.trim().isEmpty)) {
                    return 'Required for bank payments';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickChequeDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Cheque Date',
                      hintText: _chequeDate != null
                          ? '${_chequeDate!.day.toString().padLeft(2, '0')}/${_chequeDate!.month.toString().padLeft(2, '0')}/${_chequeDate!.year}'
                          : 'Select date',
                      suffixIcon:
                          const Icon(LucideIcons.calendar, size: 18),
                    ),
                    validator: (v) {
                      if (_isBankMode && _chequeDate == null) {
                        return 'Select a cheque date';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Adjustment
            Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _isAdjustment,
                    activeColor: c.red,
                    onChanged: (v) =>
                        setState(() => _isAdjustment = v ?? false),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Adjustment',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: c.ink,
                  ),
                ),
                if (_isAdjustment) ...[
                  const SizedBox(width: 16),
                  _radioChip(c, 'Credit', _adjustmentType == 'credit', () {
                    setState(() => _adjustmentType = 'credit');
                  }),
                  const SizedBox(width: 8),
                  _radioChip(c, 'Debit', _adjustmentType == 'debit', () {
                    setState(() => _adjustmentType = 'debit');
                  }),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Remarks
            TextFormField(
              controller: _remarksController,
              decoration: const InputDecoration(
                labelText: 'Remarks',
                hintText: 'Enter remarks (mandatory)',
              ),
              maxLines: 2,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Remarks are required';
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Pay button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: st.phase == LcoPaymentPhase.paying ? null : _onPay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.pillBR,
                  ),
                ),
                child: st.phase == LcoPaymentPhase.paying
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Pay',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
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

  // ── Mode Chip ──────────────────────────────────────────────────────────

  Widget _modeChip(
      AppColors c, String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? c.red : c.bg,
          borderRadius: AppRadius.pillBR,
          border: Border.all(
            color: selected ? c.red : c.ink10,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : c.ink60,
          ),
        ),
      ),
    );
  }

  // ── Radio Chip ─────────────────────────────────────────────────────────

  Widget _radioChip(
      AppColors c, String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? c.redSoft : c.bg,
          borderRadius: AppRadius.pillBR,
          border: Border.all(
            color: selected ? c.red : c.ink10,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? c.red : c.ink60,
          ),
        ),
      ),
    );
  }
}
