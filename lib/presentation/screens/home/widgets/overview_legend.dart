import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

/// 2x2 grid of clickable stat cards for the overview section.
///
/// Each card shows: colored dot + value (mono, colored) + label.
/// Tap switches to the corresponding pill tab.
class OverviewLegend extends StatelessWidget {
  const OverviewLegend({
    super.key,
    required this.active,
    required this.inactive,
    required this.fresh,
    required this.healthPercent,
    required this.onTapActive,
    required this.onTapInactive,
    required this.onTapFresh,
    required this.onTapHealth,
  });

  final int active;
  final int inactive;
  final int fresh;
  final int healthPercent;
  final VoidCallback onTapActive;
  final VoidCallback onTapInactive;
  final VoidCallback onTapFresh;
  final VoidCallback onTapHealth;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final l = AppLocalizations.of(context)!;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _LegendCard(
                dotColor: c.greenDot,
                value: _fmt(active),
                valueColor: c.greenDot,
                label: l.active,
                onTap: onTapActive,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: _LegendCard(
                dotColor: c.redDot,
                value: _fmt(inactive),
                valueColor: c.redDot,
                label: l.inactive,
                onTap: onTapInactive,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: _LegendCard(
                dotColor: c.amber,
                value: _fmt(fresh),
                valueColor: c.amber,
                label: l.fresh,
                onTap: onTapFresh,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: _LegendCard(
                dotColor: c.blue,
                value: '$healthPercent%',
                valueColor: c.blue,
                label: l.health,
                onTap: onTapHealth,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _fmt(int n) {
    return n.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}

class _LegendCard extends StatelessWidget {
  const _LegendCard({
    required this.dotColor,
    required this.value,
    required this.valueColor,
    required this.label,
    required this.onTap,
  });

  final Color dotColor;
  final String value;
  final Color valueColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(8),
          boxShadow: AppShadow.card,
        ),
        child: Row(
          children: [
            // Colored dot
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            // Value + label
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: valueColor,
                    height: 1.2,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
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
