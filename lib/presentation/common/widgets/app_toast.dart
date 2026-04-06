import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// Variant for toast notifications.
enum ToastVariant { success, info }

/// Shows an overlay toast at the top of the screen.
///
/// Auto-dismisses after 2800ms with a pop-in animation (300ms).
///
/// Usage:
/// ```dart
/// AppToast.show(context, message: 'Recharge done!', variant: ToastVariant.success);
/// ```
class AppToast {
  AppToast._();

  static OverlayEntry? _current;

  static void show(
    BuildContext context, {
    required String message,
    ToastVariant variant = ToastVariant.success,
  }) {
    _current?.remove();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        message: message,
        variant: variant,
        onDismiss: () {
          entry.remove();
          if (_current == entry) _current = null;
        },
      ),
    );
    _current = entry;

    Overlay.of(context).insert(entry);
  }
}

class _ToastWidget extends StatefulWidget {
  const _ToastWidget({
    required this.message,
    required this.variant,
    required this.onDismiss,
  });

  final String message;
  final ToastVariant variant;
  final VoidCallback onDismiss;

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeOut),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeOut),
    );

    _anim.forward();
    _timer = Timer(const Duration(milliseconds: 2800), _dismiss);
  }

  Future<void> _dismiss() async {
    _timer?.cancel();
    await _anim.reverse();
    if (mounted) widget.onDismiss();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;

    final Color bg;
    final Color text;
    final Color border;
    switch (widget.variant) {
      case ToastVariant.success:
        bg = c.toastSuccessBg;
        text = c.toastSuccessText;
        border = c.toastSuccessBorder;
      case ToastVariant.info:
        bg = c.toastInfoBg;
        text = c.toastInfoText;
        border = c.toastInfoBorder;
    }

    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 24,
      right: 24,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, child) => Opacity(
          opacity: _opacity.value,
          child: Transform.scale(
            scale: _scale.value,
            child: child,
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: AppRadius.pillBR,
              border: Border.all(color: border, width: 1),
              boxShadow: AppShadow.card,
            ),
            child: Text(
              widget.message,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: text,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
