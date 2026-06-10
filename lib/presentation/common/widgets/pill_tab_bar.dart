import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// Describes a single tab inside a [PillTabBar].
class PillTab {
  final String label;

  /// Optional badge count shown inline after the label.
  final int? count;

  /// Background color when this tab is selected.
  final Color activeBg;

  /// Text/badge color when this tab is selected.
  final Color activeText;

  const PillTab({
    required this.label,
    this.count,
    required this.activeBg,
    required this.activeText,
  });
}

/// A horizontal row of pill-shaped tabs — each with its own active color.
///
/// Per spec: bg `ink-05`, 3px padding, pill radius, each tab flex-1.
class PillTabBar extends StatelessWidget {
  const PillTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  final List<PillTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: c.ink05,
        borderRadius: AppRadius.pillBR,
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final tab = tabs[i];
          final selected = i == selectedIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: selected ? tab.activeBg : Colors.transparent,
                  borderRadius: AppRadius.pillBR,
                ),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tab.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected ? tab.activeText : c.ink40,
                        ),
                      ),
                      if (tab.count != null) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          constraints: const BoxConstraints(minWidth: 18),
                          decoration: BoxDecoration(
                            color: selected
                                ? tab.activeText.withValues(alpha: 0.15)
                                : c.ink20.withValues(alpha: 0.2),
                            borderRadius: AppRadius.pillBR,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${tab.count}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: selected ? tab.activeText : c.ink40,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
