import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

/// Simple uppercase section label matching the POC spec:
/// 10px, weight 700, `ink-20`, letter-spacing 0.08em.
class SectionLabel extends StatelessWidget {
  const SectionLabel({
    super.key,
    required this.text,
    this.padding,
  });

  final String text;

  /// Optional outer padding. Defaults to `EdgeInsets.zero`.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;

    final label = Text(
      text.toUpperCase(),
      style: GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: c.ink20,
        letterSpacing: 0.08 * 10, // 0.08em at 10px
      ),
    );

    if (padding != null) {
      return Padding(padding: padding!, child: label);
    }
    return label;
  }
}
