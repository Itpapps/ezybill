import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// Describes a single circular action button used in the detail bottom sheet.
class CircleAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const CircleAction({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });
}

/// A row of circular action buttons (52px diameter) with icon, color, and label.
///
/// Used in the subscriber detail bottom sheet.
class CircleActionBar extends StatelessWidget {
  const CircleActionBar({
    super.key,
    required this.actions,
  });

  final List<CircleAction> actions;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions.map((action) {
          return GestureDetector(
            onTap: action.onTap,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: c.bg,
                    shape: BoxShape.circle,
                    boxShadow: AppShadow.card,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    action.icon,
                    size: 22,
                    color: action.color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  action.label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: c.ink60,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
