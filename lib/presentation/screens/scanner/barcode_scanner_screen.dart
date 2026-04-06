import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/theme/app_colors.dart';

/// Full-screen barcode scanner using the device camera.
///
/// On a successful scan, pops the screen and returns the scanned value as a
/// `String` via `Navigator.pop(context, value)`. The caller receives it from
/// `context.push<String>(RouteNames.barcodeScanner)`.
///
/// Features:
///   - Camera viewfinder with overlay scan zone.
///   - Torch (flashlight) toggle.
///   - Camera flip (front/back) toggle.
///   - Manual entry fallback text field.
///   - Camera permission handling.
class BarcodeScannerScreen extends StatefulWidget {
  /// Optional label shown in the manual entry hint (e.g., "Box Number").
  final String? hintLabel;

  const BarcodeScannerScreen({super.key, this.hintLabel});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  late MobileScannerController _controller;
  final TextEditingController _manualController = TextEditingController();
  final FocusNode _manualFocus = FocusNode();

  bool _torchEnabled = false;
  bool _showManualEntry = false;
  bool _hasScanned = false;
  bool _permissionDenied = false;
  bool _checkingPermission = true;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    _checkCameraPermission();
  }

  @override
  void dispose() {
    _controller.dispose();
    _manualController.dispose();
    _manualFocus.dispose();
    super.dispose();
  }

  // ── Permission ─────────────────────────────────────────────────────────

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _permissionDenied = !status.isGranted;
      _checkingPermission = false;
    });
  }

  // ── Scan handler ───────────────────────────────────────────────────────

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final value = barcodes.first.rawValue;
    if (value == null || value.isEmpty) return;

    setState(() => _hasScanned = true);

    // Haptic feedback on successful scan.
    HapticFeedback.mediumImpact();

    Navigator.of(context).pop(value);
  }

  void _submitManualEntry() {
    final value = _manualController.text.trim();
    if (value.isEmpty) return;
    Navigator.of(context).pop(value);
  }

  void _toggleTorch() {
    _controller.toggleTorch();
    setState(() => _torchEnabled = !_torchEnabled);
  }

  void _toggleManualEntry() {
    setState(() {
      _showManualEntry = !_showManualEntry;
      if (_showManualEntry) {
        _manualFocus.requestFocus();
      } else {
        _manualFocus.unfocus();
      }
    });
  }

  // ── UI ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _checkingPermission
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _permissionDenied
              ? _buildPermissionDenied()
              : _buildScanner(),
    );
  }

  Widget _buildScanner() {
    return Stack(
      children: [
        // Camera feed
        MobileScanner(
          controller: _controller,
          onDetect: _onDetect,
        ),

        // Semi-transparent overlay with scan zone cutout
        _buildOverlay(),

        // Top bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(LucideIcons.x,
                        color: Colors.white, size: 24),
                  ),
                  const Text(
                    'Scan Barcode',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: _toggleTorch,
                    icon: Icon(
                      _torchEnabled ? LucideIcons.zapOff : LucideIcons.zap,
                      color: _torchEnabled ? AppColors.warning : Colors.white,
                      size: 22,
                    ),
                    tooltip: 'Toggle Flashlight',
                  ),
                ],
              ),
            ),
          ),
        ),

        // Instruction text
        Positioned(
          left: 0,
          right: 0,
          bottom: _showManualEntry ? 200 : 160,
          child: const Text(
            'Point your camera at a barcode',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ),

        // Bottom action bar
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildBottomBar(),
        ),
      ],
    );
  }

  Widget _buildOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scanWidth = constraints.maxWidth * 0.75;
        final scanHeight = scanWidth * 0.5;
        final top = (constraints.maxHeight - scanHeight) / 2 - 40;
        final left = (constraints.maxWidth - scanWidth) / 2;

        return Stack(
          children: [
            // Darkened background
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.5),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  // Transparent scan zone
                  Positioned(
                    top: top,
                    left: left,
                    child: Container(
                      width: scanWidth,
                      height: scanHeight,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scan zone border
            Positioned(
              top: top,
              left: left,
              child: Container(
                width: scanWidth,
                height: scanHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary, width: 2.5),
                ),
              ),
            ),

            // Corner accents
            ..._buildCornerAccents(top, left, scanWidth, scanHeight),
          ],
        );
      },
    );
  }

  List<Widget> _buildCornerAccents(
      double top, double left, double width, double height) {
    const size = 24.0;
    const thickness = 4.0;
    const color = AppColors.primary;

    return [
      // Top-left
      Positioned(
        top: top - 1,
        left: left - 1,
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: _CornerPainter(corner: 0, color: color, thickness: thickness)),
        ),
      ),
      // Top-right
      Positioned(
        top: top - 1,
        left: left + width - size + 1,
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: _CornerPainter(corner: 1, color: color, thickness: thickness)),
        ),
      ),
      // Bottom-left
      Positioned(
        top: top + height - size + 1,
        left: left - 1,
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: _CornerPainter(corner: 2, color: color, thickness: thickness)),
        ),
      ),
      // Bottom-right
      Positioned(
        top: top + height - size + 1,
        left: left + width - size + 1,
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: _CornerPainter(corner: 3, color: color, thickness: thickness)),
        ),
      ),
    ];
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Toggle manual entry
            GestureDetector(
              onTap: _toggleManualEntry,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _showManualEntry
                        ? LucideIcons.camera
                        : LucideIcons.keyboard,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _showManualEntry
                        ? 'Use Camera Instead'
                        : 'Enter Manually',
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      color: Colors.white70,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),

            // Manual entry text field
            if (_showManualEntry) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _manualController,
                      focusNode: _manualFocus,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            widget.hintLabel ?? 'Enter barcode value...',
                        hintStyle: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.white30),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.white30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.1),
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _submitManualEntry(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _submitManualEntry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Icon(LucideIcons.search, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionDenied() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.dangerBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(LucideIcons.cameraOff,
                    size: 36, color: AppColors.danger),
              ),
              const SizedBox(height: 16),
              const Text(
                'Camera Permission Required',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Camera access is needed to scan barcodes.\nPlease grant permission in Settings.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => openAppSettings(),
                icon: const Icon(LucideIcons.settings, size: 16),
                label: const Text('Open Settings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Corner accent painter for the scan zone
// ─────────────────────────────────────────────────────────────────────────────

class _CornerPainter extends CustomPainter {
  /// 0 = top-left, 1 = top-right, 2 = bottom-left, 3 = bottom-right.
  final int corner;
  final Color color;
  final double thickness;

  _CornerPainter({
    required this.corner,
    required this.color,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    switch (corner) {
      case 0: // top-left
        path.moveTo(0, size.height);
        path.lineTo(0, 0);
        path.lineTo(size.width, 0);
        break;
      case 1: // top-right
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
        break;
      case 2: // bottom-left
        path.moveTo(0, 0);
        path.lineTo(0, size.height);
        path.lineTo(size.width, size.height);
        break;
      case 3: // bottom-right
        path.moveTo(size.width, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        break;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) =>
      corner != oldDelegate.corner || color != oldDelegate.color;
}
