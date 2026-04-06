import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

/// Toggleable panel showing recent wallet recharges.
///
/// Animated show/hide with slide + fade transition.
/// Card with title "RECENT WALLET RECHARGES" and rows: amount + date.
class WalletHistoryPanel extends StatelessWidget {
  const WalletHistoryPanel({
    super.key,
    required this.visible,
    required this.isLoading,
    required this.entries,
  });

  /// Whether the panel is shown.
  final bool visible;

  /// Whether wallet history is currently loading.
  final bool isLoading;

  /// List of wallet history entries. Each has `amount` and `date` keys.
  final List<Map<String, dynamic>> entries;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return SizeTransition(
          sizeFactor: animation,
          axisAlignment: -1,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: visible
          ? _Panel(
              key: const ValueKey('wallet-history'),
              isLoading: isLoading,
              entries: entries,
            )
          : const SizedBox.shrink(key: ValueKey('wallet-history-empty')),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    super.key,
    required this.isLoading,
    required this.entries,
  });

  final bool isLoading;
  final List<Map<String, dynamic>> entries;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: AppRadius.cardBR,
          boxShadow: AppShadow.card,
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'RECENT WALLET RECHARGES',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: c.ink20,
                letterSpacing: 0.06 * 10,
              ),
            ),
            const SizedBox(height: 8),

            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No recent wallet recharges',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: c.ink40,
                  ),
                ),
              )
            else
              ...entries.take(5).map((entry) {
                final amount = entry['amount']?.toString() ?? '0';
                final date = entry['date']?.toString() ??
                    entry['created_date']?.toString() ??
                    '';
                return _HistoryRow(amount: amount, date: date);
              }),
          ],
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.amount, required this.date});

  final String amount;
  final String date;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.ink05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '\u20B9$amount',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: c.ink60,
            ),
          ),
          Text(
            date,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: c.ink20,
            ),
          ),
        ],
      ),
    );
  }
}
