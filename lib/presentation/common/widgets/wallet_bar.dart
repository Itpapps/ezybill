import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

/// Wallet balance bar with JetBrains Mono amount, last-recharge info,
/// and a red pill top-up button.
class WalletBar extends StatelessWidget {
  const WalletBar({
    super.key,
    required this.balance,
    this.lastRechargeText,
    this.onTopUp,
    this.onHistory,
  });

  /// Formatted balance string, e.g. `"12,450"`.
  final String balance;

  /// Last recharge description, e.g. `"Last: ₹5,000 on 22 Mar 2026"`.
  final String? lastRechargeText;

  final VoidCallback? onTopUp;
  final VoidCallback? onHistory;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = Theme.of(context).extension<AppColors>()!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Wallet icon container
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: c.greenSoft,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Icon(LucideIcons.wallet, size: 14, color: c.green),
          ),
          const SizedBox(width: 8),

          // Balance + last recharge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '\u20B9$balance',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: c.ink,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l.balance,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: c.ink40,
                      ),
                    ),
                  ],
                ),
                if (lastRechargeText != null)
                  GestureDetector(
                    onTap: onHistory,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          lastRechargeText!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                            color: c.ink20,
                          ),
                        ),
                        if (onHistory != null) ...[
                          const SizedBox(width: 4),
                          Icon(LucideIcons.history, size: 10, color: c.blue),
                          const SizedBox(width: 2),
                          Text(
                            l.ledger,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: c.blue,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Top-up button
          GestureDetector(
            onTap: onTopUp,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: c.red,
                borderRadius: AppRadius.pillBR,
                boxShadow: [
                  BoxShadow(
                    color: c.red.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.plus, size: 12, color: Colors.white),
                  const SizedBox(width: 3),
                  Text(
                    l.topUp,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
