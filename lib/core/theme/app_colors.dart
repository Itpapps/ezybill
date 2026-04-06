import 'package:flutter/material.dart';

/// Avatar color pair used for user initials circles.
class AvatarColor {
  final Color background;
  final Color text;
  const AvatarColor({required this.background, required this.text});
}

/// Status-to-color mapping enum.
enum StatusColor {
  active(Color(0xFF00C853)),
  deactivated(Color(0xFFFF1744)),
  suspended(Color(0xFFF5A623)),
  fresh(Color(0xFF4A90D9));

  final Color color;
  const StatusColor(this.color);

  /// Look up a [StatusColor] by its string name (case-insensitive).
  static StatusColor fromString(String status) {
    switch (status.toLowerCase().trim()) {
      case 'active':
        return StatusColor.active;
      case 'deactivated':
      case 'inactive':
        return StatusColor.deactivated;
      case 'suspended':
        return StatusColor.suspended;
      case 'fresh':
      case 'new':
        return StatusColor.fresh;
      default:
        return StatusColor.active;
    }
  }
}

/// Six-color avatar palette assigned by name hash.
const List<AvatarColor> avatarPalette = [
  AvatarColor(background: Color(0xFFDBEAFE), text: Color(0xFF3B82F6)), // Blue
  AvatarColor(background: Color(0xFFD1FAE5), text: Color(0xFF059669)), // Green
  AvatarColor(background: Color(0xFFFEF3C7), text: Color(0xFFD97706)), // Amber
  AvatarColor(background: Color(0xFFFCE7F3), text: Color(0xFFDB2777)), // Pink
  AvatarColor(background: Color(0xFFEDE9FE), text: Color(0xFF7C3AED)), // Purple
  AvatarColor(background: Color(0xFFF1F5F9), text: Color(0xFF64748B)), // Gray
];

/// Returns an [AvatarColor] deterministically chosen by hashing [name].
AvatarColor avatarColorForName(String name) {
  final hash = name.codeUnits.fold<int>(0, (sum, c) => sum + c);
  return avatarPalette[hash % avatarPalette.length];
}

/// ThemeExtension carrying every POC design-token color.
///
/// Access via `Theme.of(context).extension<AppColors>()!`.
class AppColors extends ThemeExtension<AppColors> {
  // ── Backgrounds ──────────────────────────────────────────
  final Color bg;
  final Color card;

  // ── Brand / Primary ──────────────────────────────────────
  final Color red;
  final Color redSoft;
  final Color redDark;

  // ── Semantic ─────────────────────────────────────────────
  final Color green;
  final Color greenSoft;
  final Color greenDot;
  final Color redDot;
  final Color amber;
  final Color amberSoft;
  final Color blue;
  final Color blueSoft;
  final Color purple;
  final Color purpleSoft;

  // ── Ink (text & line palette) ────────────────────────────
  final Color ink;
  final Color ink80;
  final Color ink60;
  final Color ink40;
  final Color ink20;
  final Color ink10;
  final Color ink05;

  // ── Toast ────────────────────────────────────────────────
  final Color toastSuccessBg;
  final Color toastSuccessText;
  final Color toastSuccessBorder;
  final Color toastInfoBg;
  final Color toastInfoText;
  final Color toastInfoBorder;

  const AppColors({
    required this.bg,
    required this.card,
    required this.red,
    required this.redSoft,
    required this.redDark,
    required this.green,
    required this.greenSoft,
    required this.greenDot,
    required this.redDot,
    required this.amber,
    required this.amberSoft,
    required this.blue,
    required this.blueSoft,
    required this.purple,
    required this.purpleSoft,
    required this.ink,
    required this.ink80,
    required this.ink60,
    required this.ink40,
    required this.ink20,
    required this.ink10,
    required this.ink05,
    required this.toastSuccessBg,
    required this.toastSuccessText,
    required this.toastSuccessBorder,
    required this.toastInfoBg,
    required this.toastInfoText,
    required this.toastInfoBorder,
  });

  // ── Light theme instance ─────────────────────────────────
  static const light = AppColors(
    bg: Color(0xFFF6F8FB),
    card: Color(0xFFFFFFFF),
    red: Color(0xFFE53935),
    redSoft: Color(0xFFFFF0F0),
    redDark: Color(0xFFC62828),
    green: Color(0xFF2ECC71),
    greenSoft: Color(0xFFEAFAF1),
    greenDot: Color(0xFF00C853),
    redDot: Color(0xFFFF1744),
    amber: Color(0xFFF5A623),
    amberSoft: Color(0xFFFEF9EE),
    blue: Color(0xFF4A90D9),
    blueSoft: Color(0xFFEEF4FB),
    purple: Color(0xFF7E57C2),
    purpleSoft: Color(0xFFF3EEFA),
    ink: Color(0xFF1A1D23),
    ink80: Color(0xFF2D3139),
    ink60: Color(0xFF4A5060),
    ink40: Color(0xFF7A8194),
    ink20: Color(0xFFB4BAC8),
    ink10: Color(0xFFD8DCE6),
    ink05: Color(0xFFEEF0F4),
    toastSuccessBg: Color(0xFFE8F8EE),
    toastSuccessText: Color(0xFF15803D),
    toastSuccessBorder: Color(0xFFBBF7D0),
    toastInfoBg: Color(0xFFEEF4FB),
    toastInfoText: Color(0xFF1D4ED8),
    toastInfoBorder: Color(0xFFBFDBFE),
  );

  // ── Dark theme instance ──────────────────────────────────
  static const dark = AppColors(
    bg: Color(0xFF0F1219),
    card: Color(0xFF1A2030),
    red: Color(0xFFE53935),
    redSoft: Color(0xFF3A1A1A),
    redDark: Color(0xFFC62828),
    green: Color(0xFF2ECC71),
    greenSoft: Color(0xFF1A2E22),
    greenDot: Color(0xFF00C853),
    redDot: Color(0xFFFF1744),
    amber: Color(0xFFF5A623),
    amberSoft: Color(0xFF2E2618),
    blue: Color(0xFF4A90D9),
    blueSoft: Color(0xFF1A2235),
    purple: Color(0xFF7E57C2),
    purpleSoft: Color(0xFF251E35),
    ink: Color(0xFFE8ECF2),
    ink80: Color(0xFFC8CDD8),
    ink60: Color(0xFFA0A8B8),
    ink40: Color(0xFF6B7590),
    ink20: Color(0xFF3D4560),
    ink10: Color(0xFF252D40),
    ink05: Color(0xFF1A2235),
    toastSuccessBg: Color(0xFF1A2E22),
    toastSuccessText: Color(0xFF4ADE80),
    toastSuccessBorder: Color(0xFF1A3A28),
    toastInfoBg: Color(0xFF1A2235),
    toastInfoText: Color(0xFF60A5FA),
    toastInfoBorder: Color(0xFF1E3050),
  );

  // ── Static convenience fields for backward compatibility ──
  // These proxy the light theme values so screens can use
  // `AppColors.primary` etc. without a BuildContext.
  static const Color white = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFFE53935);
  static const Color primaryLight = Color(0xFFFFF0F0);
  static const Color primaryDark = Color(0xFFC62828);
  static const Color background = Color(0xFFF6F8FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1D23);
  static const Color textSecondary = Color(0xFF4A5060);
  static const Color textMuted = Color(0xFF7A8194);
  static const Color border = Color(0xFFD8DCE6);
  static const Color success = Color(0xFF2ECC71);
  static const Color successBg = Color(0xFFEAFAF1);
  static const Color danger = Color(0xFFFF1744);
  static const Color dangerBg = Color(0xFFFFF0F0);
  static const Color warning = Color(0xFFF5A623);
  static const Color warningBg = Color(0xFFFEF9EE);
  static const Color info = Color(0xFF4A90D9);
  static const Color infoBg = Color(0xFFEEF4FB);
  static const Color orange = Color(0xFFF5A623);
  static const Color orangeBg = Color(0xFFFEF9EE);

  // ── ThemeExtension plumbing ──────────────────────────────
  @override
  AppColors copyWith({
    Color? bg,
    Color? card,
    Color? red,
    Color? redSoft,
    Color? redDark,
    Color? green,
    Color? greenSoft,
    Color? greenDot,
    Color? redDot,
    Color? amber,
    Color? amberSoft,
    Color? blue,
    Color? blueSoft,
    Color? purple,
    Color? purpleSoft,
    Color? ink,
    Color? ink80,
    Color? ink60,
    Color? ink40,
    Color? ink20,
    Color? ink10,
    Color? ink05,
    Color? toastSuccessBg,
    Color? toastSuccessText,
    Color? toastSuccessBorder,
    Color? toastInfoBg,
    Color? toastInfoText,
    Color? toastInfoBorder,
  }) {
    return AppColors(
      bg: bg ?? this.bg,
      card: card ?? this.card,
      red: red ?? this.red,
      redSoft: redSoft ?? this.redSoft,
      redDark: redDark ?? this.redDark,
      green: green ?? this.green,
      greenSoft: greenSoft ?? this.greenSoft,
      greenDot: greenDot ?? this.greenDot,
      redDot: redDot ?? this.redDot,
      amber: amber ?? this.amber,
      amberSoft: amberSoft ?? this.amberSoft,
      blue: blue ?? this.blue,
      blueSoft: blueSoft ?? this.blueSoft,
      purple: purple ?? this.purple,
      purpleSoft: purpleSoft ?? this.purpleSoft,
      ink: ink ?? this.ink,
      ink80: ink80 ?? this.ink80,
      ink60: ink60 ?? this.ink60,
      ink40: ink40 ?? this.ink40,
      ink20: ink20 ?? this.ink20,
      ink10: ink10 ?? this.ink10,
      ink05: ink05 ?? this.ink05,
      toastSuccessBg: toastSuccessBg ?? this.toastSuccessBg,
      toastSuccessText: toastSuccessText ?? this.toastSuccessText,
      toastSuccessBorder: toastSuccessBorder ?? this.toastSuccessBorder,
      toastInfoBg: toastInfoBg ?? this.toastInfoBg,
      toastInfoText: toastInfoText ?? this.toastInfoText,
      toastInfoBorder: toastInfoBorder ?? this.toastInfoBorder,
    );
  }

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      bg: Color.lerp(bg, other.bg, t)!,
      card: Color.lerp(card, other.card, t)!,
      red: Color.lerp(red, other.red, t)!,
      redSoft: Color.lerp(redSoft, other.redSoft, t)!,
      redDark: Color.lerp(redDark, other.redDark, t)!,
      green: Color.lerp(green, other.green, t)!,
      greenSoft: Color.lerp(greenSoft, other.greenSoft, t)!,
      greenDot: Color.lerp(greenDot, other.greenDot, t)!,
      redDot: Color.lerp(redDot, other.redDot, t)!,
      amber: Color.lerp(amber, other.amber, t)!,
      amberSoft: Color.lerp(amberSoft, other.amberSoft, t)!,
      blue: Color.lerp(blue, other.blue, t)!,
      blueSoft: Color.lerp(blueSoft, other.blueSoft, t)!,
      purple: Color.lerp(purple, other.purple, t)!,
      purpleSoft: Color.lerp(purpleSoft, other.purpleSoft, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      ink80: Color.lerp(ink80, other.ink80, t)!,
      ink60: Color.lerp(ink60, other.ink60, t)!,
      ink40: Color.lerp(ink40, other.ink40, t)!,
      ink20: Color.lerp(ink20, other.ink20, t)!,
      ink10: Color.lerp(ink10, other.ink10, t)!,
      ink05: Color.lerp(ink05, other.ink05, t)!,
      toastSuccessBg: Color.lerp(toastSuccessBg, other.toastSuccessBg, t)!,
      toastSuccessText: Color.lerp(toastSuccessText, other.toastSuccessText, t)!,
      toastSuccessBorder: Color.lerp(toastSuccessBorder, other.toastSuccessBorder, t)!,
      toastInfoBg: Color.lerp(toastInfoBg, other.toastInfoBg, t)!,
      toastInfoText: Color.lerp(toastInfoText, other.toastInfoText, t)!,
      toastInfoBorder: Color.lerp(toastInfoBorder, other.toastInfoBorder, t)!,
    );
  }
}
