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

    final chips = [
      _AlertChipData(
        icon: LucideIcons.checkCircle,
        iconBg: c.greenSoft,
        iconColor: c.greenDot,
        count: rechargedCount,
        label: l.recharged,
      ),
      _AlertChipData(
        icon: LucideIcons.alertTriangle,
        iconBg: c.amberSoft,
        iconColor: c.amber,
        count: expiring7dCount,
        label: l.expiring7d,
      ),
      _AlertChipData(
        icon: LucideIcons.creditCard,
        iconBg: c.blueSoft,
        iconColor: c.blue,
        count: walletRechargeCount,
        label: '${l.wallet} \u203A',
        onTap: onWalletTap,
      ),
      _AlertChipData(
        icon: LucideIcons.zap,
        iconBg: c.redSoft,
        iconColor: c.redDot,
        count: overdueCount,
        label: l.overdue,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // On wider screens (tablets), expand chips evenly
        final isWide = constraints.maxWidth >= 400;

        if (isWide) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                for (int i = 0; i < chips.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(child: _AlertChip(data: chips[i], expanded: true)),
                ],
              ],
            ),
          );
        }

        // On narrower screens (phones), scroll horizontally
        return SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              for (int i = 0; i < chips.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                _AlertChip(data: chips[i], expanded: false),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _AlertChipData {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final int count;
  final String label;
  final VoidCallback? onTap;

  const _AlertChipData({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.count,
    required this.label,
    this.onTap,
  });
}

class _AlertChip extends StatelessWidget {
  const _AlertChip({
    required this.data,
    this.expanded = false,
  });

  final _AlertChipData data;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;

    // Scale sizes for expanded (tablet) vs compact (phone)
    final iconBoxSize = expanded ? 24.0 : 18.0;
    final iconSize = expanded ? 13.0 : 10.0;
    final countFontSize = expanded ? 14.0 : 12.0;
    final labelFontSize = expanded ? 9.0 : 7.0;
    final hPad = expanded ? 12.0 : 10.0;
    final vPad = expanded ? 8.0 : 5.0;

    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(8),
          boxShadow: AppShadow.card,
        ),
        child: Row(
          mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
          children: [
            // Icon container
            Container(
              width: iconBoxSize,
              height: iconBoxSize,
              decoration: BoxDecoration(
                color: data.iconBg,
                borderRadius: BorderRadius.circular(5),
              ),
              alignment: Alignment.center,
              child: Icon(data.icon, size: iconSize, color: data.iconColor),
            ),
            const SizedBox(width: 6),
            // Count + label
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.count.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: countFontSize,
                      fontWeight: FontWeight.w800,
                      color: c.ink,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    data.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: labelFontSize,
                      fontWeight: FontWeight.w600,
                      color: c.ink40,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
