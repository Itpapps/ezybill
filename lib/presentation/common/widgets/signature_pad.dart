import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';

/// Result returned when the user saves a signature.
class SignatureResult {
  /// Raw PNG image bytes of the signature.
  final Uint8List pngBytes;

  /// Width of the captured image in pixels.
  final int width;

  /// Height of the captured image in pixels.
  final int height;

  const SignatureResult({
    required this.pngBytes,
    required this.width,
    required this.height,
  });
}

/// A touch-based signature capture widget.
///
/// Uses [CustomPainter] + [GestureDetector] to let the user draw a signature
/// with their finger. Mirrors the Android `CaptureSignature` activity:
///   - Canvas: configurable size (default 600x320), white background.
///   - Stroke: width 5.0, black, round joins, anti-aliased.
///   - Actions: Clear, Save, Cancel.
///   - Save returns PNG bytes via `toImage()` + `toByteData()`.
///
/// Can be embedded inline in forms or shown as a bottom sheet via
/// [SignaturePad.showAsBottomSheet].
class SignaturePad extends StatefulWidget {
  /// Width of the signature canvas.
  final double canvasWidth;

  /// Height of the signature canvas.
  final double canvasHeight;

  /// Stroke width for the signature pen.
  final double strokeWidth;

  /// Color of the signature stroke.
  final Color strokeColor;

  /// Background color of the canvas.
  final Color backgroundColor;

  /// Called when the user taps the Save button. Receives the PNG bytes.
  final ValueChanged<SignatureResult>? onSave;

  /// Called when the user taps Cancel.
  final VoidCallback? onCancel;

  const SignaturePad({
    super.key,
    this.canvasWidth = 600,
    this.canvasHeight = 320,
    this.strokeWidth = 5.0,
    this.strokeColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.onSave,
    this.onCancel,
  });

  /// Show the signature pad as a modal bottom sheet and return the result.
  ///
  /// Returns `null` if the user cancels.
  static Future<SignatureResult?> showAsBottomSheet(
    BuildContext context, {
    double canvasWidth = 600,
    double canvasHeight = 320,
  }) async {
    return showModalBottomSheet<SignatureResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Capture Signature',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              SignaturePad(
                canvasWidth: canvasWidth,
                canvasHeight: canvasHeight,
                onSave: (result) => Navigator.of(ctx).pop(result),
                onCancel: () => Navigator.of(ctx).pop(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  final List<_Stroke> _strokes = [];
  _Stroke? _currentStroke;
  bool _hasDrawn = false;
  bool _isSaving = false;

  final GlobalKey _canvasKey = GlobalKey();

  // ── Touch handlers ───────────────────────────────────────────────────

  void _onPanStart(DragStartDetails details) {
    final localPos = _clampToCanvas(details.localPosition);
    setState(() {
      _currentStroke = _Stroke(
        color: widget.strokeColor,
        strokeWidth: widget.strokeWidth,
      );
      _currentStroke!.points.add(localPos);
      _hasDrawn = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_currentStroke == null) return;
    final localPos = _clampToCanvas(details.localPosition);
    setState(() {
      _currentStroke!.points.add(localPos);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentStroke == null) return;
    setState(() {
      _strokes.add(_currentStroke!);
      _currentStroke = null;
    });
  }

  Offset _clampToCanvas(Offset pos) {
    return Offset(
      pos.dx.clamp(0, widget.canvasWidth),
      pos.dy.clamp(0, widget.canvasHeight),
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────

  void _clear() {
    setState(() {
      _strokes.clear();
      _currentStroke = null;
      _hasDrawn = false;
    });
  }

  Future<void> _save() async {
    if (!_hasDrawn || _isSaving) return;
    setState(() => _isSaving = true);

    try {
      final result = await _captureSignature();
      if (result != null) {
        widget.onSave?.call(result);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<SignatureResult?> _captureSignature() async {
    final width = widget.canvasWidth.toInt();
    final height = widget.canvasHeight.toInt();

    // Create an offscreen canvas and draw the signature onto it.
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // White background.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      Paint()..color = widget.backgroundColor,
    );

    // Draw all strokes.
    for (final stroke in _strokes) {
      _drawStroke(canvas, stroke);
    }
    if (_currentStroke != null) {
      _drawStroke(canvas, _currentStroke!);
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    if (byteData == null) return null;

    return SignatureResult(
      pngBytes: byteData.buffer.asUint8List(),
      width: width,
      height: height,
    );
  }

  void _drawStroke(Canvas canvas, _Stroke stroke) {
    if (stroke.points.length < 2) {
      // Single dot.
      if (stroke.points.isNotEmpty) {
        canvas.drawCircle(
          stroke.points.first,
          stroke.strokeWidth / 2,
          Paint()
            ..color = stroke.color
            ..style = PaintingStyle.fill,
        );
      }
      return;
    }

    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final path = Path();
    path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
    for (var i = 1; i < stroke.points.length; i++) {
      path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  void _cancel() {
    widget.onCancel?.call();
  }

  // ── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Canvas area
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: SizedBox(
              width: widget.canvasWidth,
              height: widget.canvasHeight,
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: RepaintBoundary(
                  key: _canvasKey,
                  child: CustomPaint(
                    painter: _SignaturePainter(
                      strokes: _strokes,
                      currentStroke: _currentStroke,
                    ),
                    size: Size(widget.canvasWidth, widget.canvasHeight),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Hint text
        if (!_hasDrawn)
          const Padding(
            padding: EdgeInsets.only(top: 4, bottom: 8),
            child: Text(
              'Draw your signature above',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ),

        const SizedBox(height: 8),

        // Action buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // Cancel
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _cancel,
                  icon: const Icon(LucideIcons.x, size: 16),
                  label: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Clear
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _hasDrawn ? _clear : null,
                  icon: const Icon(LucideIcons.eraser, size: 16),
                  label: const Text('Clear'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: BorderSide(
                      color: _hasDrawn ? AppColors.danger : AppColors.border,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Save
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _hasDrawn && !_isSaving ? _save : null,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : const Icon(LucideIcons.check, size: 16),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: AppColors.white,
                    disabledBackgroundColor: AppColors.border,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stroke model
// ─────────────────────────────────────────────────────────────────────────────

class _Stroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  _Stroke({
    this.color = Colors.black,
    this.strokeWidth = 5.0,
  }) : points = [];
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomPainter
// ─────────────────────────────────────────────────────────────────────────────

class _SignaturePainter extends CustomPainter {
  final List<_Stroke> strokes;
  final _Stroke? currentStroke;

  _SignaturePainter({
    required this.strokes,
    this.currentStroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }
    if (currentStroke != null) {
      _drawStroke(canvas, currentStroke!);
    }
  }

  void _drawStroke(Canvas canvas, _Stroke stroke) {
    if (stroke.points.isEmpty) return;

    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    if (stroke.points.length == 1) {
      canvas.drawCircle(
        stroke.points.first,
        stroke.strokeWidth / 2,
        Paint()
          ..color = stroke.color
          ..style = PaintingStyle.fill,
      );
      return;
    }

    final path = Path();
    path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
    for (var i = 1; i < stroke.points.length; i++) {
      path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
