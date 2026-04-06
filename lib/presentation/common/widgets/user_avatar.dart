import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

/// Circular avatar that shows initials derived from [name],
/// with background/text color deterministically chosen by name hash.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    this.size = 40,
  });

  /// Full name — initials are the first letter of the first two words.
  final String name;

  /// Diameter of the circle. Defaults to 40px per spec.
  final double size;

  /// Compute initials: first letter of each word, max 2 characters.
  String get _initials {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return '?';
    if (words.length == 1) return words.first[0].toUpperCase();
    return '${words.first[0]}${words[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final avatarColor = avatarColorForName(name);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: avatarColor.background,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: GoogleFonts.plusJakartaSans(
          fontSize: size * 0.325, // ~13px at 40, ~17px at 52
          fontWeight: FontWeight.w700,
          color: avatarColor.text,
          height: 1,
        ),
      ),
    );
  }
}
