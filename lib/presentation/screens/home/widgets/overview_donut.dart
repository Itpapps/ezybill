import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

/// 70x70 donut chart showing Active / Inactive / Fresh percentages.
///
/// Uses [CustomPainter] with 3 arcs:
/// - Green (active), Red (inactive), Amber (fresh)
/// - Grey background ring
/// - Center: total count (mono font, w800) + "Total" label
class OverviewDonut extends StatelessWidget {
  const OverviewDonut({
    super.key,
    required this.active,
    required this.inactive,
    required this.fresh,
  });

  final int active;
  final int inactive;
  final int fresh;

  int get total => active + inactive + fresh;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;

    return SizedBox(
      width: 70,
      height: 70,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(70, 70),
            painter: _DonutPainter(
              active: active,
              inactive: inactive,
              fresh: fresh,
              greenColor: c.greenDot,
              redColor: c.redDot,
              amberColor: c.amber,
              bgRingColor: c.ink05,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatCount(total),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: c.ink,
                  height: 1.1,
                ),
              ),
              Text(
                'Total',
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
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      final k = count / 1000;
      return k == k.roundToDouble()
          ? '${k.toInt()},${(count % 1000).toString().padLeft(3, '0')}'
          : count.toString().replaceAllMapped(
              RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
              (m) => '${m[1]},',
            );
    }
    return count.toString();
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.active,
    required this.inactive,
    required this.fresh,
    required this.greenColor,
    required this.redColor,
    required this.amberColor,
    required this.bgRingColor,
  });

  final int active;
  final int inactive;
  final int fresh;
  final Color greenColor;
  final Color redColor;
  final Color amberColor;
  final Color bgRingColor;

  static const double _strokeWidth = 6.0;
  static const double _gap = 0.03; // radians gap between arcs

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - _strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background ring
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..color = bgRingColor
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    final total = active + inactive + fresh;
    if (total == 0) return;

    final segments = <_Segment>[
      _Segment(active / total, greenColor),
      _Segment(inactive / total, redColor),
      _Segment(fresh / total, amberColor),
    ];

    // Filter out zero-width segments
    final nonZero = segments.where((s) => s.fraction > 0).toList();
    if (nonZero.isEmpty) return;

    final totalGap = _gap * nonZero.length;
    final available = 2 * math.pi - totalGap;

    double startAngle = -math.pi / 2; // start from top

    for (final seg in nonZero) {
      final sweep = seg.fraction * available;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..color = seg.color
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep + _gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      active != old.active ||
      inactive != old.inactive ||
      fresh != old.fresh;
}

class _Segment {
  final double fraction;
  final Color color;
  const _Segment(this.fraction, this.color);
}
