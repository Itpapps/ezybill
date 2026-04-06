import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../application/providers/lco_payment_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../data/models/lco/lco_wallet_entry.dart';

/// LCO Wallet History screen with date-range picker and scrollable list.
class LcoWalletHistoryScreen extends ConsumerStatefulWidget {
  const LcoWalletHistoryScreen({super.key});

  @override
  ConsumerState<LcoWalletHistoryScreen> createState() =>
      _LcoWalletHistoryScreenState();
}

class _LcoWalletHistoryScreenState
    extends ConsumerState<LcoWalletHistoryScreen> {
  late DateTime _fromDate;
  late DateTime _toDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _fromDate = DateTime(now.year, now.month, 1);
    _toDate = now;

    // Load initial data after build.
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHistory());
  }

  void _loadHistory() {
    ref.read(lcoPaymentProvider.notifier).loadWalletHistory(
          startDate: formatApiDate(_fromDate),
          endDate: formatApiDate(_toDate),
        );
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = isFrom ? _fromDate : _toDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
          if (_fromDate.isAfter(_toDate)) _toDate = _fromDate;
        } else {
          _toDate = picked;
          if (_toDate.isBefore(_fromDate)) _fromDate = _toDate;
        }
      });
      _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final st = ref.watch(lcoPaymentProvider);
    final entries = st.walletHistory;
    final isLoading = st.walletHistoryLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet History'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // ── Date Range Picker ────────────────────────────────────────
          _buildDateRangeBar(c),

          // ── Count Header ─────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: c.bg,
            child: Text(
              isLoading
                  ? 'Loading...'
                  : '${entries.length} transaction${entries.length == 1 ? '' : 's'}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: c.ink40,
              ),
            ),
          ),

          // ── List / Empty / Loading ───────────────────────────────────
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : entries.isEmpty
                    ? _buildEmptyState(c)
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: entries.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) =>
                            _buildEntryCard(c, entries[index]),
                      ),
          ),
        ],
      ),
    );
  }

  // ── Date Range Bar ──────────────────────────────────────────────────────

  Widget _buildDateRangeBar(AppColors c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: c.card,
        boxShadow: [AppShadow.sm],
      ),
      child: Row(
        children: [
          Expanded(child: _datePill(c, _fromDate, () => _pickDate(isFrom: true))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'to',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: c.ink40,
              ),
            ),
          ),
          Expanded(child: _datePill(c, _toDate, () => _pickDate(isFrom: false))),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _loadHistory,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: c.red,
                borderRadius: AppRadius.smBR,
              ),
              child:
                  const Icon(LucideIcons.refreshCw, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _datePill(AppColors c, DateTime date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: c.bg,
          borderRadius: AppRadius.smBR,
          border: Border.all(color: c.ink10),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.calendar, size: 14, color: c.ink40),
            const SizedBox(width: 6),
            Text(
              formatDisplayDate(date),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: c.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Entry Card ──────────────────────────────────────────────────────────

  Widget _buildEntryCard(AppColors c, LcoWalletEntry entry) {
    final isCredit = (entry.creditAmount ?? 0) > 0;
    final amount = isCredit
        ? (entry.creditAmount ?? 0)
        : (entry.debitAmount ?? 0);
    final amountColor = isCredit ? c.green : c.red;
    final amountPrefix = isCredit ? '+' : '-';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: AppRadius.cardBR,
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: date + amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatApiDateForDisplay(entry.depositDate),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: c.ink60,
                ),
              ),
              Text(
                '$amountPrefix${formatCurrency(amount)}',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: amountColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Type badge + deposit amount
          Row(
            children: [
              if (entry.paymentMode != null && entry.paymentMode!.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isCredit ? c.greenSoft : c.redSoft,
                    borderRadius: AppRadius.pillBR,
                  ),
                  child: Text(
                    entry.paymentMode!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isCredit ? c.green : c.red,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              if (entry.transactionNo != null &&
                  entry.transactionNo!.isNotEmpty)
                Expanded(
                  child: Text(
                    'Txn: ${entry.transactionNo}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: c.ink40,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),

          // Remarks
          if (entry.remarks != null && entry.remarks!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              entry.remarks!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: c.ink60,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Bank details (if cheque payment)
          if (entry.chequeDdnumber != null &&
              entry.chequeDdnumber!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Cheque: ${entry.chequeDdnumber}  |  ${entry.bank ?? ''} ${entry.branch ?? ''}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: c.ink40,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  // ── Empty State ─────────────────────────────────────────────────────────

  Widget _buildEmptyState(AppColors c) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.inbox, size: 48, color: c.ink20),
          const SizedBox(height: 12),
          Text(
            'No transactions found',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: c.ink40,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try adjusting the date range.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: c.ink20,
            ),
          ),
        ],
      ),
    );
  }
}
