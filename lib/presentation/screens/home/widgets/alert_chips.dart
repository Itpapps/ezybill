import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

/// Horizontal scroll row of alert chips.
///
/// Chips: Recharged (green), Expiring 7d (amber), Wallet (blue, toggles
/// history), Overdue (pink/red).
class AlertChips extends StatelessWidget {
  const AlertChips({
    super.key,
    required this.rechargedCount,
    required this.expiring7dCount,
    required this.walletRechargeCount,
    required this.overdueCount,
    this.onWalletTap,
  });

  final int rechargedCount;
  final int expiring7dCount;
  final int walletRechargeCount;
  final int overdueCount;
  final VoidCallback? onWalletTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final l = AppLocalizations.of(context)!;

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _AlertChip(
            icon: LucideIcons.checkCircle,
            iconBg: c.greenSoft,
            iconColor: c.greenDot,
            count: rechargedCount,
            label: l.recharged,
          ),
          const SizedBox(width: 6),
          _AlertChip(
            icon: LucideIcons.alertTriangle,
            iconBg: c.amberSoft,
            iconColor: c.amber,
            count: expiring7dCount,
            label: l.expiring7d,
          ),
          const SizedBox(width: 6),
          _AlertChip(
            icon: LucideIcons.creditCard,
            iconBg: c.blueSoft,
            iconColor: c.blue,
            count: walletRechargeCount,
            label: '${l.wallet} \u203A',
            onTap: onWalletTap,
          ),
          const SizedBox(width: 6),
          _AlertChip(
            icon: LucideIcons.zap,
            iconBg: c.redSoft,
            iconColor: c.redDot,
            count: overdueCount,
            label: l.overdue,
          ),
        ],
      ),
    );
  }
}

class _AlertChip extends StatelessWidget {
  const _AlertChip({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.count,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final int count;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(8),
          boxShadow: AppShadow.card,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(5),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 10, color: iconColor),
            ),
            const SizedBox(width: 6),
            // Count + label
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count.toString(),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: c.ink,
                    height: 1.1,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 7,
                    fontWeight: FontWeight.w600,
                    color: c.ink40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
