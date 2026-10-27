import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../application/providers/auth_provider.dart';
import '../../../application/providers/bms_provider.dart';
import '../../../application/providers/core_providers.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────

const String _kRememberMeKey = 'remember_me_enabled';
const String _kSavedUsernameKey = 'remember_me_username';

// ── Login palette (white & red only) ─────────────────────────────────────────
// Login-only values from the redesign spec. AppColors is NOT modified.

const Color _kBgTop = Color(0xFFF6E8EA);
const Color _kBgMid = Color(0xFFF1DEE1);
const Color _kBgBottom = Color(0xFFEBD2D5);
const Color _kRed = Color(0xFFD42A32);
const Color _kRedDeco = Color(0xFFD62A32);
const Color _kGlowRed = Color(0xFFDC2D35);
const Color _kInk = Color(0xFF1E1A1C);
const Color _kInkSoft = Color(0xFF6E6468);
const Color _kPlaceholder = Color(0xFFA99EA3);
const Color _kLabel = Color(0xFF3E3639);
const Color _kEye = Color(0xFF8C8287);
const Color _kShadowWarm = Color(0xFFA05058); // rgb(160, 80, 88)

// Soft-touch surfaces. The card face is a faint blush rather than pure white,
// so the white highlights of the raised logo, fields and checkbox can show.
const Color _kCardTop = Color(0xFFF9F2F3);
const Color _kCardBottom = Color(0xFFF4E9EB);
const Color _kSoftFaceTop = Color(0xFFFFFCFC);
const Color _kSoftFaceBottom = Color(0xFFF3E8EA);
const Color _kFieldFaceBottom = Color(0xFFF7EFF1);
const Color _kSoftShadow = Color(0x8CC39BA2); // rgba(195, 155, 162, 0.55)
const List<Color> _kRedGradient = [
  Color(0xFFEC4950),
  Color(0xFFD02830),
  Color(0xFFBC1F27),
];

/// Input-field corner radius.
const BorderRadius _kFieldRadius = BorderRadius.all(Radius.circular(18));

/// How much room a focused field keeps around it when the keyboard opens.
/// Flutter's default (20 all round) left the Sign In button under the
/// keyboard; 160 below keeps the next field and the button in view too.
const EdgeInsets _kFieldScrollPadding = EdgeInsets.fromLTRB(20, 20, 20, 160);

/// One google_fonts base style per weight, built once. Calling GoogleFonts
/// inside every build would restart a failed font fetch on each keyboard frame
/// while the device is offline and the font is not cached yet.
final Map<FontWeight, TextStyle> _kLoginFontByWeight = {};

/// Login text style in the app's own font — the theme's Plus Jakarta Sans,
/// through google_fonts (already a dependency).
TextStyle _loginText(
  double size,
  FontWeight weight,
  Color color, {
  double? letterSpacing,
}) =>
    (_kLoginFontByWeight[weight] ??=
            GoogleFonts.plusJakartaSans(fontWeight: weight))
        .copyWith(
      fontSize: size,
      color: color,
      letterSpacing: letterSpacing,
    );

/// Card layout metrics. Phones get a compact set so the single card stays
/// short; tablets (shortest side >= 600) get the full spec sizes.
class _LoginMetrics {
  const _LoginMetrics({
    required this.cardRadius,
    required this.cardPadding,
    required this.logoTile,
    required this.logoTileRadius,
    required this.logoInner,
    required this.logoInnerRadius,
    required this.gapLogoTitle,
    required this.titleSize,
    required this.dividerTop,
    required this.dividerBottom,
    required this.welcomeSize,
    required this.gapBeforeFields,
    required this.fieldHeight,
    required this.fieldGap,
    required this.gapBeforeRemember,
    required this.gapBeforeButton,
    required this.buttonHeight,
    required this.buttonTextSize,
  });

  final double cardRadius;
  final EdgeInsets cardPadding;
  final double logoTile;
  final double logoTileRadius;
  final double logoInner;
  final double logoInnerRadius;
  final double gapLogoTitle;
  final double titleSize;
  final double dividerTop;
  final double dividerBottom;
  final double welcomeSize;
  final double gapBeforeFields;
  final double fieldHeight;
  final double fieldGap;
  final double gapBeforeRemember;
  final double gapBeforeButton;
  final double buttonHeight;
  final double buttonTextSize;

  static const phone = _LoginMetrics(
    cardRadius: 34,
    cardPadding: EdgeInsets.fromLTRB(22, 22, 22, 22),
    logoTile: 84,
    logoTileRadius: 26,
    logoInner: 60,
    logoInnerRadius: 18,
    gapLogoTitle: 10,
    titleSize: 24,
    dividerTop: 14,
    dividerBottom: 12,
    welcomeSize: 20,
    gapBeforeFields: 16,
    fieldHeight: 52,
    // Room for each raised field's soft shadow before the next one.
    fieldGap: 14,
    gapBeforeRemember: 12,
    gapBeforeButton: 16,
    buttonHeight: 50,
    buttonTextSize: 16,
  );

  static const tablet = _LoginMetrics(
    cardRadius: 44,
    cardPadding: EdgeInsets.fromLTRB(36, 34, 36, 34),
    logoTile: 100,
    logoTileRadius: 30,
    logoInner: 66,
    logoInnerRadius: 20,
    gapLogoTitle: 14,
    titleSize: 28,
    dividerTop: 24,
    dividerBottom: 22,
    welcomeSize: 22,
    gapBeforeFields: 22,
    fieldHeight: 58,
    fieldGap: 18,
    gapBeforeRemember: 14,
    gapBeforeButton: 22,
    buttonHeight: 56,
    buttonTextSize: 16.5,
  );
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  // Localization helper — available in all methods via context
  AppLocalizations get l => AppLocalizations.of(context)!;

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    _loadRememberedUsername();
  }

  /// The app theme's brightness, kept current so [dispose] can hand the
  /// status bar back (Theme cannot be looked up while the screen is removed).
  Brightness _appBrightness = Brightness.light;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appBrightness = Theme.of(context).brightness;
  }

  @override
  void dispose() {
    // The login's dark status-bar icons would otherwise stay on the next
    // screen (Home has no AnnotatedRegion of its own). Send back the style
    // MaterialApp uses for the current theme.
    SystemChrome.setSystemUIOverlayStyle(
      _appBrightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    );
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // ── Remember Me ────────────────────────────────────────────────────────────

  Future<void> _loadRememberedUsername() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final remembered = prefs.getBool(_kRememberMeKey) ?? false;
    final savedUsername = prefs.getString(_kSavedUsernameKey) ?? '';

    if (remembered && savedUsername.isNotEmpty) {
      setState(() {
        _rememberMe = true;
        _usernameController.text = savedUsername;
      });
    }
  }

  Future<void> _saveRememberMe() async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (_rememberMe) {
      await prefs.setBool(_kRememberMeKey, true);
      await prefs.setString(
          _kSavedUsernameKey, _usernameController.text.trim());
    } else {
      await prefs.remove(_kRememberMeKey);
      await prefs.remove(_kSavedUsernameKey);
      await prefs.remove('remember_me_password');
    }
  }

  // ── Connectivity Check ─────────────────────────────────────────────────────

  Future<bool> _isConnected() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return !result.contains(ConnectivityResult.none);
    } catch (_) {
      // If we can't check, assume connected and let the API call fail
      // with a proper error message.
      return true;
    }
  }

  // ── Login Handler ──────────────────────────────────────────────────────────

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    // Network check before calling the API.
    final connected = await _isConnected();
    if (!connected && mounted) {
      _showErrorSnackbar('No internet connection. Please check your network.');
      return;
    }

    // Persist remember-me preference.
    await _saveRememberMe();

    // Trigger login via the auth provider.
    await ref.read(authProvider.notifier).login(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
        );
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    final colors = Theme.of(context).extension<AppColors>()!;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(LucideIcons.alertCircle, color: colors.card, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ── API URL Edit Dialog ───────────────────────────────────────────────────

  void _showApiUrlDialog() {
    final colors = Theme.of(context).extension<AppColors>()!;
    final controller = TextEditingController(text: ApiConstants.baseUrl);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: colors.card,
        title: Text(
          l.apiBaseUrl,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: colors.ink,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.editServerUrl,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                color: colors.ink40,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: colors.ink,
              ),
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'http://192.168.1.143/...',
                hintStyle: TextStyle(color: colors.ink20, fontSize: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colors.ink10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colors.ink10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colors.red),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                controller.text = ApiConstants.defaultBaseUrl;
              },
              child: Text(
                l.resetToDefault,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11,
                  color: colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l.cancel,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                color: colors.ink40,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final url = controller.text.trim();
              if (url.isNotEmpty) {
                ApiConstants.setBaseUrl(url);
                ref
                    .read(sharedPreferencesProvider)
                    .setString('api_base_url', url);
              }
              Navigator.pop(ctx);
              setState(() {}); // Refresh displayed URL
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              l.save,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.loading;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final m = MediaQuery.sizeOf(context).shortestSide >= 600
        ? _LoginMetrics.tablet
        : _LoginMetrics.phone;

    // Listen for error state and show snackbar.
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.status == AuthStatus.error &&
          next.errorMessage != null &&
          prev?.errorMessage != next.errorMessage) {
        _showErrorSnackbar(next.errorMessage!);
      }
    });

    // Light canvas → dark status-bar icons while this screen is shown. A
    // region's style stays in effect after the screen goes, so dispose()
    // hands the status bar back to the app theme's style.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        // Matches the bottom of the backdrop gradient, so the band the IME
        // vacates below the body can never flash a different colour.
        backgroundColor: _kBgBottom,
        body: SizedBox(
          width: double.infinity,
          // The body's constraints shrink when the keyboard opens, so the
          // backdrop carries its own explicit `height: screenHeight` (which a
          // Positioned child may exceed; the Stack clips it). That keeps the
          // decorative canvas fixed while the content scrolls.
          height: screenHeight,
          child: Stack(
            children: [
              // Decorative backdrop — one static painter, rasterised once and
              // served from the RepaintBoundary cache; never hit-tested.
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: screenHeight,
                child: const IgnorePointer(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _LoginBackdropPainter(),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  // The scroll viewport — not the raw screen — is what the
                  // content has to fill, so the box tracks the space that
                  // actually exists when the keyboard is open.
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 20),
                                // Phone: full width minus 24px each side.
                                // Tablet: capped at 560px and centred.
                                Center(
                                  child: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 560),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // RepaintBoundary gives the card its
                                        // own layer, so scrolling moves it
                                        // without repainting its blurred
                                        // shadows.
                                        RepaintBoundary(
                                          child: _buildLoginCard(
                                              l, m, isLoading),
                                        ),
                                        const SizedBox(height: 18),
                                        _buildVersion(),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── API URL Indicator ───────────────────────────────────────────────────────

  Widget _buildApiUrlIndicator(AppColors colors, bool isDark) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 4),
      decoration: BoxDecoration(
        // Light keeps the filled pill. Dark drops the fill and shows a single
        // hairline above the row instead. Implemented as a top BorderSide
        // rather than a separate Divider widget, so the card gains no height:
        // the all-round border contributed 2px, the top-only one contributes
        // 1px, making dark 1px SHORTER — it can never grow.
        color: isDark ? Colors.transparent : colors.bg,
        borderRadius: isDark ? null : BorderRadius.circular(12),
        border: isDark
            ? Border(top: BorderSide(color: colors.ink10, width: 1))
            : Border.all(color: colors.ink10, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(LucideIcons.server, size: 14, color: colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ApiConstants.baseUrl,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                color: colors.ink40,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: _showApiUrlDialog,
            icon: Icon(LucideIcons.pencil, size: 14, color: colors.red),
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(
              minWidth: 34,
              minHeight: 34,
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  /// The mark shown inside the 80x80 brand tile.
  ///
  /// Prefers the per-client logo the BMS returns as `appLogoPath` (an absolute
  /// URL assembled server-side in validateAuthentication.php), matching the
  /// native Android app which downloads the same value into its login logo
  /// ImageView. Falls back to the TV icon whenever a logo is unavailable.
  ///
  /// Always occupies exactly 38x38 inside the fixed tile — placeholder, error
  /// and success states are all the same size, so nothing can shift.
  Widget _buildBrandMark() {
    const fallback = Icon(LucideIcons.tv, size: 38, color: Colors.white);

    final prefs = ref.read(sharedPreferencesProvider);
    final logoUrl = prefs.getString(kAppLogoPath)?.trim() ?? '';

    // Guard the two cases the server can produce that are not images: an empty
    // string, and a bare host with no file (when the dealer has no logo set,
    // `$ip_split[0].$app_logo_path` collapses to just the base URL).
    final looksLikeImage = logoUrl.startsWith('http') &&
        logoUrl.split('/').last.contains('.');
    if (!looksLikeImage) return fallback;

    // Larger than the 38px TV glyph on purpose: a logo image carries its own
    // internal padding, so it reads smaller than an icon at the same box size.
    // 58 inside the fixed 80x80 tile still leaves an 11px margin each side,
    // so the tile — and therefore the layout — is unchanged.
    return SizedBox(
      width: 58,
      height: 58,
      child: CachedNetworkImage(
        imageUrl: logoUrl,
        fit: BoxFit.contain,
        placeholder: (_, _) => fallback,
        errorWidget: (_, _, _) => fallback,
      ),
    );
  }

  /// Raised soft tile holding the red brand square. The mark inside is the
  /// unchanged [_buildBrandMark] (BMS client logo, TV icon fallback).
  Widget _buildLogoTile(_LoginMetrics m) {
    return Container(
      width: m.logoTile,
      height: m.logoTile,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(m.logoTileRadius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kSoftFaceTop, _kSoftFaceBottom],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 1.5,
        ),
        boxShadow: const [
          // Light from the top-left, then the warm shadow bottom-right.
          BoxShadow(
            color: Colors.white,
            offset: Offset(-8, -8),
            blurRadius: 18,
          ),
          BoxShadow(
            color: _kSoftShadow,
            offset: Offset(9, 10),
            blurRadius: 20,
          ),
        ],
      ),
      child: Container(
        width: m.logoInner,
        height: m.logoInner,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(m.logoInnerRadius),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEC4950), _kRed, Color(0xFFBC1F27)],
          ),
          boxShadow: [
            BoxShadow(
              color: _kRed.withValues(alpha: 0.32),
              offset: const Offset(0, 5),
              blurRadius: 12,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            _buildBrandMark(),
            Positioned(left: 7, top: 6, child: _buildGlint()),
          ],
        ),
      ),
    );
  }

  /// Small 4-point sparkle on the brand square's top-left corner.
  Widget _buildGlint() {
    Widget ray(double w, double h, Alignment begin, Alignment end) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: begin,
              end: end,
              colors: [
                Colors.white.withValues(alpha: 0.0),
                Colors.white.withValues(alpha: 0.95),
                Colors.white.withValues(alpha: 0.0),
              ],
            ),
          ),
        );
    return SizedBox(
      width: 12,
      height: 15,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ray(1.5, 15, Alignment.topCenter, Alignment.bottomCenter),
          ray(12, 1.5, Alignment.centerLeft, Alignment.centerRight),
          Container(
            width: 4.5,
            height: 4.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white,
                  Colors.white.withValues(alpha: 0.0),
                ],
                stops: const [0.2, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Version ────────────────────────────────────────────────────────────────

  /// Version text (same literal source as before) between two red rules that
  /// fade out toward the edges.
  Widget _buildVersion() {
    Widget rule(List<Color> colors) => Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
            ),
          ),
        );
    return Row(
      children: [
        rule([
          _kRedDeco.withValues(alpha: 0.0),
          _kRedDeco.withValues(alpha: 0.30),
        ]),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'v1.0.0',
            style: _loginText(12.5, FontWeight.w500, _kInkSoft),
          ),
        ),
        rule([
          _kRedDeco.withValues(alpha: 0.30),
          _kRedDeco.withValues(alpha: 0.0),
        ]),
      ],
    );
  }

  // ── Login Card ─────────────────────────────────────────────────────────────

  /// The single soft card holding everything: branding, divider, fields,
  /// Remember Me and Sign In. All form wiring is unchanged.
  Widget _buildLoginCard(
      AppLocalizations l, _LoginMetrics m, bool isLoading) {
    return DecoratedBox(
      // Outer shell — shadows and a hairline outline. The shell has no fill,
      // so only the shadows show around the card's shape. Shadows paint in
      // list order, so the even halo sits over the white light and keeps the
      // left and top edges visible against the pale background.
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(m.cardRadius),
        border: Border.all(
          color: _kShadowWarm.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: [
          // Soft light from the top-left, held back from the edge.
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.75),
            offset: const Offset(-14, -14),
            blurRadius: 30,
          ),
          // Even halo on every side, including left and top.
          BoxShadow(
            color: _kShadowWarm.withValues(alpha: 0.16),
            offset: const Offset(0, 3),
            blurRadius: 16,
          ),
          // Main warm drop shadow, bottom-right.
          BoxShadow(
            color: _kShadowWarm.withValues(alpha: 0.28),
            offset: const Offset(16, 22),
            blurRadius: 44,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(1), // inside the hairline
        padding: m.cardPadding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(m.cardRadius - 1),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.9),
            width: 1.5,
          ),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_kCardTop, _kCardBottom],
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Branding ────────────────────────────────────────────
              Center(child: _buildLogoTile(m)),
              SizedBox(height: m.gapLogoTitle),
              Text(
                l.appName,
                textAlign: TextAlign.center,
                style: _loginText(m.titleSize, FontWeight.w800, _kInk,
                    letterSpacing: -0.4),
              ),

              // ── Divider — red fading in from both sides ─────────────
              Container(
                height: 1,
                margin:
                    EdgeInsets.only(top: m.dividerTop, bottom: m.dividerBottom),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0x00C8232B),
                      Color(0x38C8232B), // #C8232B at 22%
                      Color(0x00C8232B),
                    ],
                  ),
                ),
              ),

              // Card title
              Text(
                'Welcome Back',
                textAlign: TextAlign.center,
                style: _loginText(m.welcomeSize, FontWeight.w700, _kInk),
              ),
              SizedBox(height: m.gapBeforeFields),

              // Fields and Remember Me fade back while signing in, the way
              // the disabled fields used to look. Only the look changes; the
              // disabling itself is the unchanged `enabled` / `onTap` wiring.
              Opacity(
                opacity: isLoading ? 0.6 : 1.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Username Field ──────────────────────────────────────
                    TextFormField(
                      controller: _usernameController,
                      focusNode: _usernameFocus,
                      enabled: !isLoading,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_passwordFocus),
                      style: _loginText(15, FontWeight.w600, _kInk),
                      cursorColor: _kRed,
                      scrollPadding: _kFieldScrollPadding,
                      decoration: _inputDecoration(
                        m: m,
                        hint: l.username,
                        icon: LucideIcons.user,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: m.fieldGap),

                    // ── Password Field ──────────────────────────────────────
                    TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      enabled: !isLoading,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleLogin(),
                      style: _loginText(15, FontWeight.w600, _kInk),
                      cursorColor: _kRed,
                      scrollPadding: _kFieldScrollPadding,
                      decoration: _inputDecoration(
                        m: m,
                        hint: l.password,
                        icon: LucideIcons.lock,
                        // IconButton keeps a 48x48 touch target.
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? LucideIcons.eyeOff
                                : LucideIcons.eye,
                            size: 20,
                            color: _kEye,
                          ),
                          onPressed: () {
                            setState(
                                () => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: m.gapBeforeRemember),

                    // ── Remember Me ─────────────────────────────────────────
                    // Same GestureDetector + Checkbox wiring as before. The red
                    // gradient box (or the raised soft box when unticked) is
                    // painted behind the Checkbox, which is made transparent so
                    // only its white check mark shows.
                    GestureDetector(
                      onTap: isLoading
                          ? null
                          : () => setState(() => _rememberMe = !_rememberMe),
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                gradient: _rememberMe
                                    ? const LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: _kRedGradient,
                                      )
                                    : const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          _kSoftFaceTop,
                                          _kSoftFaceBottom,
                                        ],
                                      ),
                                border: _rememberMe
                                    ? null
                                    : Border.all(
                                        color: _kRed.withValues(alpha: 0.30),
                                        width: 1.2,
                                      ),
                                boxShadow: _rememberMe
                                    ? [
                                        BoxShadow(
                                          color: _kRed.withValues(alpha: 0.30),
                                          offset: const Offset(0, 3),
                                          blurRadius: 8,
                                        ),
                                      ]
                                    : const [
                                        BoxShadow(
                                          color: Colors.white,
                                          offset: Offset(-2, -2),
                                          blurRadius: 4,
                                        ),
                                        BoxShadow(
                                          color: _kSoftShadow,
                                          offset: Offset(2, 2.5),
                                          blurRadius: 5,
                                        ),
                                      ],
                              ),
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: isLoading
                                    ? null
                                    : (v) => setState(
                                        () => _rememberMe = v ?? false),
                                fillColor: const WidgetStatePropertyAll(
                                    Colors.transparent),
                                checkColor: Colors.white,
                                side: BorderSide.none,
                                overlayColor: const WidgetStatePropertyAll(
                                    Colors.transparent),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Flexible: very large text wraps instead of
                          // running past the card padding.
                          Flexible(
                            child: Text(
                              l.rememberMe,
                              style: _loginText(14, FontWeight.w500, _kLabel),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: m.gapBeforeButton),

              // ── Login Button ────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: m.buttonHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.pillBR,
                    // Gradient lives on the wrapper; the button itself stays
                    // transparent so onPressed/disabled behaviour is untouched.
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        for (final c in _kRedGradient)
                          c.withValues(alpha: isLoading ? 0.7 : 1.0),
                      ],
                    ),
                    boxShadow: isLoading
                        ? []
                        : const [
                            BoxShadow(
                              color: Color(0x61C8232B), // rgba(200,35,43,0.38)
                              offset: Offset(0, 14),
                              blurRadius: 26,
                            ),
                          ],
                  ),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.transparent,
                      disabledForegroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.pillBR,
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            l.loginButton,
                            style: _loginText(m.buttonTextSize,
                                FontWeight.w600, Colors.white),
                          ),
                  ),
                ),
              ),

              // ── API URL indicator (debug/profile builds only) ─────────
              // Absent from release: end users never set the URL by hand — BMS
              // registration supplies it programmatically via setBaseUrl().
              // Light palette: the card is white in both themes now.
              if (kDevToolsEnabled) ...[
                const SizedBox(height: 12),
                _buildApiUrlIndicator(AppColors.light, false),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Input Decoration Helper ────────────────────────────────────────────────

  /// Raised soft-touch field: light halo top-left, warm shadow bottom-right,
  /// no visible border line (a faint red ring only on focus / error), round
  /// raised icon well.
  InputDecoration _inputDecoration({
    required _LoginMetrics m,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: _loginText(15, FontWeight.w500, _kPlaceholder),
      prefixIcon: _FieldIconTile(icon: icon),
      prefixIconConstraints: const BoxConstraints(minWidth: 54, minHeight: 36),
      suffixIcon: suffixIcon,
      // The face is a gradient painted by _SoftFieldBorder, not a flat fill.
      filled: false,
      // ~20px text line + padding = the field height from the metrics.
      contentPadding: EdgeInsets.symmetric(
        horizontal: 4,
        vertical: (m.fieldHeight - 20) / 2,
      ),
      border: const _SoftFieldBorder(),
      enabledBorder: const _SoftFieldBorder(),
      disabledBorder: const _SoftFieldBorder(),
      focusedBorder: _SoftFieldBorder(
        borderSide: BorderSide(color: _kRed.withValues(alpha: 0.40), width: 1.2),
      ),
      errorBorder: _SoftFieldBorder(
        borderSide: BorderSide(color: _kRed.withValues(alpha: 0.55), width: 1.2),
      ),
      focusedErrorBorder: _SoftFieldBorder(
        borderSide: BorderSide(color: _kRed.withValues(alpha: 0.75), width: 1.2),
      ),
      errorStyle: _loginText(11.5, FontWeight.w500, _kRed),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Halftone background texture
// ─────────────────────────────────────────────────────────────────────────────

/// One cluster of the halftone field.
///
/// All geometry is FRACTIONAL (0..1 of the canvas), so the composition scales
/// with the viewport rather than drifting on wide or short screens — the same
/// approach the sweep bands take. Values may
/// fall outside 0..1 where a cluster is meant to run off the edge.
class _HalftoneField {
  const _HalftoneField({
    required this.area,
    required this.anchor,
    required this.spacing,
    required this.dotRadius,
    required this.alpha,
  });

  /// Cluster bounds as a fraction of the canvas.
  final Rect area;

  /// Where the cluster is densest. Dot size and opacity fall off from here.
  final Alignment anchor;

  /// Grid pitch as a fraction of canvas WIDTH — used on both axes, so the
  /// lattice stays square whatever the aspect ratio.
  final double spacing;

  /// Dot radius at the anchor, as a fraction of canvas width.
  final double dotRadius;

  /// Dot opacity at the anchor, as a multiplier of the painter's tint.
  final double alpha;
}

/// The three dot clusters in the design: a dense corner top-right, a band
/// off the left edge mid-screen, and a cluster bottom-left.
const List<_HalftoneField> _kHalftoneFields = [
  _HalftoneField(
    area: Rect.fromLTRB(0.70, 0.02, 1.02, 0.26),
    anchor: Alignment.topRight,
    spacing: 0.030,
    dotRadius: 0.0060,
    alpha: 1.0,
  ),
  _HalftoneField(
    area: Rect.fromLTRB(-0.02, 0.40, 0.12, 0.62),
    anchor: Alignment.centerLeft,
    spacing: 0.030,
    dotRadius: 0.0056,
    alpha: 0.85,
  ),
  _HalftoneField(
    area: Rect.fromLTRB(0.02, 0.80, 0.30, 0.97),
    anchor: Alignment.bottomLeft,
    spacing: 0.030,
    dotRadius: 0.0056,
    alpha: 0.80,
  ),
];

/// Paints the halftone dot texture behind the login content.
///
/// Static — no animation and no state. [shouldRepaint] fires only when the
/// tint changes (i.e. on a theme switch), so the field rasterises once and is
/// then served from the RepaintBoundary cache; it does NOT redraw while the
/// keyboard animates.
class _HalftonePainter extends CustomPainter {
  const _HalftonePainter({required this.color});

  /// Tint for the field. Each dot scales its own alpha off this colour's.
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final paint = Paint()..isAntiAlias = true;
    // Scale off a capped width so dots and pitch stay phone-sized on tablets.
    final unit = math.min(size.width, 460.0);

    for (final field in _kHalftoneFields) {
      final rect = Rect.fromLTRB(
        field.area.left * size.width,
        field.area.top * size.height,
        field.area.right * size.width,
        field.area.bottom * size.height,
      );
      if (rect.isEmpty) continue;

      final step = field.spacing * unit;
      if (step <= 0) continue;

      final maxRadius = field.dotRadius * unit;
      final anchor = field.anchor.withinRect(rect);

      for (double y = rect.top; y <= rect.bottom; y += step) {
        for (double x = rect.left; x <= rect.right; x += step) {
          // Normalised radial falloff: 1 at the anchor, 0 at the far edge.
          final t = 1.0 -
              Offset(
                (x - anchor.dx) / rect.width,
                (y - anchor.dy) / rect.height,
              ).distance;
          if (t <= 0.04) continue;

          paint.color = color.withValues(alpha: color.a * field.alpha * t);
          canvas.drawCircle(Offset(x, y), maxRadius * (0.34 + 0.66 * t), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HalftonePainter oldDelegate) =>
      color != oldDelegate.color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Backdrop
// ─────────────────────────────────────────────────────────────────────────────

/// The decorative canvas behind the card: a vertical gradient, two soft red
/// glows (top-right, bottom-left), a tilted white panel bottom-right, a faint
/// thin ring and three dot clusters.
///
/// Static — no state, never repaints — so behind its RepaintBoundary it is
/// rasterised once and does not redraw while the keyboard animates.
class _LoginBackdropPainter extends CustomPainter {
  const _LoginBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;

    // 1. Base: #F9EFF0 → #F3E2E4 → #ECD4D6, top to bottom.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_kBgTop, _kBgMid, _kBgBottom],
          stops: [0.0, 0.5, 1.0],
        ).createShader(rect),
    );

    // 2. Soft red glows fading to nothing.
    void glow(Offset center, double radius, double alpha) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              _kGlowRed.withValues(alpha: alpha),
              _kGlowRed.withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }

    final reach = math.max(w, h * 0.6);
    glow(Offset(w, h * 0.04), reach * 0.75, 0.16);
    glow(Offset(0, h * 0.96), reach * 0.70, 0.13);

    // 3. Tilted rounded white panel, bottom-right (−28°).
    final panelW = math.min(w * 0.95, 620.0);
    canvas.save();
    canvas.translate(w * 0.88, h * 0.97);
    canvas.rotate(-28 * math.pi / 180);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: panelW,
          height: panelW * 0.62,
        ),
        Radius.circular(panelW * 0.13),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.50),
    );
    canvas.restore();

    // 4. Faint thin ring, upper right.
    canvas.drawCircle(
      Offset(w * 0.96, h * 0.24),
      math.min(w, h) * 0.62,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = _kRedDeco.withValues(alpha: 0.14),
    );

    // 5. Red dot clusters, fading out at their edges.
    _HalftonePainter(color: _kRedDeco.withValues(alpha: 0.20))
        .paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant _LoginBackdropPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Raised soft-touch text field
// ─────────────────────────────────────────────────────────────────────────────

/// Field shape that looks gently raised off the card: a white halo along the
/// top-left, a warm shadow along the bottom-right, and a face that is a touch
/// lighter at the top than at the bottom.
///
/// The halos are painted here, clipped to OUTSIDE the field, and the face is
/// painted over them, so nothing depends on paint order. It extends
/// [OutlineInputBorder], so the decorator's layout and error-text placement
/// are exactly the stock ones; only [paint] differs. [lerpFrom]/[lerpTo] keep
/// this type through the focus animation, so the look cannot drop out for a
/// frame.
class _SoftFieldBorder extends OutlineInputBorder {
  const _SoftFieldBorder({
    super.borderSide = BorderSide.none,
    super.borderRadius = _kFieldRadius,
  }) : super(gapPadding: 0);

  @override
  _SoftFieldBorder copyWith({
    BorderSide? borderSide,
    BorderRadius? borderRadius,
    double? gapPadding,
  }) {
    return _SoftFieldBorder(
      borderSide: borderSide ?? this.borderSide,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  _SoftFieldBorder scale(double t) {
    return _SoftFieldBorder(
      borderSide: borderSide.scale(t),
      borderRadius: borderRadius * t,
    );
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is _SoftFieldBorder) {
      return _SoftFieldBorder(
        borderSide: BorderSide.lerp(a.borderSide, borderSide, t),
        borderRadius: BorderRadius.lerp(a.borderRadius, borderRadius, t)!,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is _SoftFieldBorder) {
      return _SoftFieldBorder(
        borderSide: BorderSide.lerp(borderSide, b.borderSide, t),
        borderRadius: BorderRadius.lerp(borderRadius, b.borderRadius, t)!,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapStart,
    double gapExtent = 0.0,
    double gapPercentage = 0.0,
    TextDirection? textDirection,
  }) {
    final rrect = borderRadius.resolve(textDirection).toRRect(rect);

    // 1. Halos, outside the field only.
    canvas.save();
    canvas.clipPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(rect.inflate(32))
        ..addRRect(rrect),
    );
    canvas.drawRRect(
      rrect.shift(const Offset(-4, -4)),
      Paint()
        ..color = Colors.white
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawRRect(
      rrect.shift(const Offset(4, 5)),
      Paint()
        ..color = _kSoftShadow
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.restore();

    // 2. Face — lighter at the top, so the field reads as gently domed.
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_kSoftFaceTop, _kFieldFaceBottom],
        ).createShader(rect),
    );

    // 3. Faint ring only when a side is set (focus / error).
    if (borderSide.style != BorderStyle.none && borderSide.width > 0) {
      canvas.drawRRect(
        rrect.deflate(borderSide.width / 2),
        borderSide.toPaint(),
      );
    }
  }
}

/// Round raised 36x36 well holding a field's leading icon.
class _FieldIconTile extends StatelessWidget {
  const _FieldIconTile({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      margin: const EdgeInsetsDirectional.only(start: 8, end: 10),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kSoftFaceTop, _kSoftFaceBottom],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            offset: Offset(-2.5, -2.5),
            blurRadius: 5,
          ),
          BoxShadow(
            color: _kSoftShadow,
            offset: Offset(2.5, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Icon(icon, size: 18, color: _kRed),
    );
  }
}
