import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// A small colored circle that indicates subscriber status.
///
/// Maps a status string (`active`, `deactivated`, `suspended`, `fresh`)
/// to its corresponding dot color from the design-system palette.
class StatusDot extends StatelessWidget {
  const StatusDot({
    super.key,
    required this.status,
    this.size = 9,
  });

  /// Status string — case-insensitive.
  final String status;

  /// Diameter of the dot. Defaults to 9px per spec.
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = StatusColor.fromString(status).color;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
