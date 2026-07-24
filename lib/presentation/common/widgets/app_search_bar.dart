import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// Pill-shaped search bar with a left search icon and a right circular
/// red "go" button. Matches the POC design exactly.
class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    super.key,
    this.placeholder = 'Phone, Name, or Setup Box ID',
    this.onChanged,
    this.onSubmitted,
    this.controller,
  });

  final String placeholder;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? controller;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode.addListener(() {
      if (_hasFocus != _focusNode.hasFocus) {
        setState(() => _hasFocus = _focusNode.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    debugPrint('=== AppSearchBar._submit() CALLED ===');
    debugPrint('  _controller.text: "${_controller.text}"');
    debugPrint('  onSubmitted wired: ${widget.onSubmitted != null}');
    widget.onSubmitted?.call(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: AppRadius.pillBR,
        border: Border.all(
          color: _hasFocus ? c.red : c.ink10,
          width: 1.5,
        ),
        boxShadow: [AppShadow.sm],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(LucideIcons.search, size: 18, color: c.ink40),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              onSubmitted: (_) => _submit(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: c.ink,
              ),
              decoration: InputDecoration(
                hintText: widget.placeholder,
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: c.ink20,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: _submit,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: c.red,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                LucideIcons.arrowRight,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 7),
        ],
      ),
    );
  }
}
