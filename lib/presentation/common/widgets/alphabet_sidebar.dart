import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

/// Vertical A-Z sidebar for list filtering.
///
/// Highlights the active letter in red. `#` at the top means "show all".
class AlphabetSidebar extends StatelessWidget {
  const AlphabetSidebar({
    super.key,
    this.activeLetter,
    this.lettersWithItems = const {},
    required this.onLetterTap,
  });

  /// Currently selected letter, or `null` / `'#'` for "all".
  final String? activeLetter;

  /// Set of letters that have at least one item — shown with darker ink.
  final Set<String> lettersWithItems;

  /// Called when a letter or `#` is tapped.
  final ValueChanged<String> onLetterTap;

  static const _letters = [
    '#',
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I',
    'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R',
    'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
  ];

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _letters.map((letter) {
        final isActive = letter == activeLetter ||
            (letter == '#' && (activeLetter == null || activeLetter == '#'));
        final hasItems = lettersWithItems.contains(letter);

        return GestureDetector(
          onTap: () => onLetterTap(letter),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 22,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isActive ? c.red : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              letter,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: isActive
                    ? Colors.white
                    : hasItems
                        ? c.ink40
                        : c.ink20,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
