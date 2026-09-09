import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../application/providers/auth_provider.dart';
import '../../../application/providers/bms_provider.dart';
import '../../../application/providers/core_providers.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────

const String _kRememberMeKey = 'remember_me_enabled';
const String _kSavedUsernameKey = 'remember_me_username';

/// Input-field corner radius. The target uses a rounded rectangle here, not
/// the pill shape used for the Sign In CTA.
const BorderRadius _kFieldRadius = BorderRadius.all(Radius.circular(16));

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

  @override
  void dispose() {
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
    final colors = Theme.of(context).extension<AppColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.sizeOf(context).height;
    // Band widths scale off the viewport so the sweep composition holds from
    // 320px through tablet, instead of fixed px that would under-span a wide
    // screen and over-span a narrow one.
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bandWidth = screenWidth * 2.4;

    // Listen for error state and show snackbar.
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.status == AuthStatus.error &&
          next.errorMessage != null &&
          prev?.errorMessage != next.errorMessage) {
        _showErrorSnackbar(next.errorMessage!);
      }
    });

    return Scaffold(
      // Without this the Scaffold's own Material paints scaffoldBackgroundColor
      // (near-white in light) in the band vacated below the body when the IME
      // opens, which can flash if the resize leads the keyboard animation.
      backgroundColor:
          Color.lerp(colors.redDark, Colors.black, isDark ? 0.66 : 0.50)!,
      body: SizedBox(
        width: double.infinity,
        // `height` here is still CLAMPED by the Scaffold body's constraints,
        // which shrink when the keyboard opens. So this box is NOT a reliable
        // anchor — every decorative layer below carries its own explicit
        // `height: screenHeight` instead, which a Positioned child may exceed
        // (the Stack clips it). That is what keeps the canvas fixed.
        height: screenHeight,
        // Decorative layers paint first (behind). The content SafeArea is the
        // last child, so it paints on top and is hit-tested first; the
        // decorative layers are childless DecoratedBox/Container, whose
        // hitTestSelf is false, so they cannot absorb a pointer.
        // NOTE: SafeArea is the sole NON-positioned child, so RenderStack
        // lays it out with loosened constraints (StackFit.loose). The content
        // column reaches full width via the version Row's MainAxisSize.max
        // and the button's SizedBox(width: double.infinity) — not via a tight
        // parent constraint as it was at HEAD.
        child: Stack(
          children: [
            // Base gradient — fixed to true screen height so its four stops
            // cannot recompress when the body shrinks.
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: screenHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  // Deepened locally toward the target crimson. AppColors is
                  // NOT modified — these are login-only lerps off the tokens.
                  gradient: LinearGradient(
                    colors: [
                      Color.lerp(colors.red, Colors.black,
                          isDark ? 0.18 : 0.08)!,
                      Color.lerp(colors.red, Colors.black,
                          isDark ? 0.26 : 0.15)!,
                      Color.lerp(colors.redDark, Colors.black,
                          isDark ? 0.38 : 0.24)!,
                      Color.lerp(colors.redDark, Colors.black,
                          isDark ? 0.66 : 0.50)!,
                    ],
                    stops: const [0.0, 0.30, 0.68, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            // ── Sweeping diagonal bands ─────────────────────────────
            // Long, shallow, rotated capsules. Each is Positioned inside the
            // Stack, so none of them contributes to layout geometry.
            Positioned(
              left: -screenWidth * 0.55,
              top: screenHeight * 0.05,
              child: Transform.rotate(
                angle: -0.34,
                child: Container(
                  width: bandWidth,
                  height: 132,
                  decoration: BoxDecoration(
                    color:
                        Colors.white.withValues(alpha: isDark ? 0.040 : 0.065),
                    borderRadius: BorderRadius.circular(120),
                  ),
                ),
              ),
            ),
            Positioned(
              left: -screenWidth * 0.42,
              top: screenHeight * 0.20,
              child: Transform.rotate(
                angle: -0.32,
                child: Container(
                  width: bandWidth,
                  height: 84,
                  decoration: BoxDecoration(
                    color:
                        Colors.white.withValues(alpha: isDark ? 0.026 : 0.042),
                    borderRadius: BorderRadius.circular(90),
                  ),
                ),
              ),
            ),
            Positioned(
              left: -screenWidth * 0.30,
              top: screenHeight * 0.33,
              child: Transform.rotate(
                angle: -0.30,
                child: Container(
                  width: bandWidth,
                  height: 58,
                  decoration: BoxDecoration(
                    color:
                        Colors.white.withValues(alpha: isDark ? 0.018 : 0.030),
                    borderRadius: BorderRadius.circular(60),
                  ),
                ),
              ),
            ),
            // Lower-right depth. Top-anchored like the rest — a `bottom:`
            // anchor would ride up with the shrinking body.
            Positioned(
              left: -screenWidth * 0.10,
              top: screenHeight * 0.62,
              child: Transform.rotate(
                angle: -0.26,
                child: Container(
                  width: bandWidth,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.13),
                    borderRadius: BorderRadius.circular(220),
                  ),
                ),
              ),
            ),
            // Key light, upper-left — restrained so it deepens rather than
            // washes out the crimson.
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: screenHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.65, -0.85),
                    radius: 1.15,
                    colors: [
                      Colors.white.withValues(alpha: isDark ? 0.05 : 0.07),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.62],
                  ),
                ),
              ),
            ),
            // Vignette, lower-right — THE black corner that was still moving.
            // `Positioned.fill` tracked the shrinking Stack, so its
            // Alignment(0.9, 1.0) centre rode up with the keyboard. A fixed
            // height decouples it from the viewport entirely.
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: screenHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.9, 1.0),
                    radius: 1.25,
                    colors: [
                      Colors.black.withValues(alpha: isDark ? 0.40 : 0.30),
                      // Fades to transparent BLACK, matching the start colour.
                      // `Colors.transparent` is also transparent black, but
                      // being explicit keeps this consistent with the white
                      // falloffs elsewhere in the file.
                      Colors.black.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.72],
                  ),
                ),
              ),
            ),
            SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 28),

                      // ── Logo / Branding Area ────────────────────────────
                      _buildHeader(colors),

                      const SizedBox(height: 28),

                      // ── Login Card ──────────────────────────────────────
                      // RepaintBoundary caches the card's raster. Its four
                      // BoxShadows are mask-filter blurs (the largest at
                      // sigma ~34); without this they re-blur on every scroll
                      // frame and every keyboard scroll-into-view frame,
                      // because SingleChildScrollView's viewport is a repaint
                      // boundary but nothing inside it is.
                      RepaintBoundary(
                        child: _buildLoginCard(colors, isDark, isLoading),
                      ),

                      const SizedBox(height: 16),

                      // ── Version ─────────────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'v1.0.0',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
            ),
          ],
        ),
      ),
    );
  }

  // ── API URL Indicator ───────────────────────────────────────────────────────

  Widget _buildApiUrlIndicator(AppColors colors) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 4),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.ink10, width: 1),
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

  Widget _buildHeader(AppColors colors) {
    return Column(
      children: [
        // Logo icon container
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(colors.red, Colors.white, 0.24)!,
                colors.red,
                colors.redDark,
              ],
              stops: const [0.0, 0.55, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            // Crisper rim to match the target's defined icon edge.
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.38),
              width: 1,
            ),
            boxShadow: [
              // Luminous red halo.
              BoxShadow(
                color: colors.red.withValues(alpha: 0.55),
                blurRadius: 28,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.32),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          // Gloss highlight over the upper half — fixed 80x80 tile, so the
          // overlay cannot change geometry.
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Specular gloss. A RadialGradient centred just ABOVE the tile
              // gives the curved highlight boundary a real glossy icon has;
              // the previous LinearGradient band cut off in a straight line,
              // which is what made it read as matte. Fills the same fixed
              // 80x80 tile, so nothing about the logo's size changes.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(21),
                    gradient: RadialGradient(
                      center: const Alignment(-0.35, -1.05),
                      radius: 1.25,
                      colors: [
                        Colors.white.withValues(alpha: 0.55),
                        Colors.white.withValues(alpha: 0.14),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.45, 0.78],
                    ),
                  ),
                ),
              ),
              // Client logo from BMS if one was supplied, else the TV mark.
              // Sits inside the FIXED 80x80 tile with a 38x38 box, so it can
              // never change the tile's size or the screen's height. Any
              // failure path (empty URL, 404, offline, slow load) falls back
              // to the same icon, so something always renders.
              _buildBrandMark(),
              // ── 4-point specular glint ──────────────────────────────
              // Three static elements inside the fixed 80x80 tile: two
              // tapered rays crossing at a bright core. Positioned, so it
              // adds no layout size; painted last so it stays crisp over
              // both the gloss and the icon. No blur, no painter, no
              // animation. Same structure in light and dark — it reads
              // against the red tile, which is identical in both themes.
              Positioned(
                left: 12,
                top: 8,
                child: SizedBox(
                  width: 14,
                  height: 19,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 1. Vertical ray — the longer of the two.
                      Container(
                        width: 1.6,
                        height: 19,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white.withValues(alpha: 0.90),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                      // 2. Horizontal ray — shorter, same taper.
                      Container(
                        width: 14,
                        height: 1.6,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white.withValues(alpha: 0.90),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                      // 3. Bright core.
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withValues(alpha: 1.0),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                            stops: const [0.18, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          l.appName,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Cable TV Billing Management',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  // ── Login Card ─────────────────────────────────────────────────────────────

  Widget _buildLoginCard(AppColors colors, bool isDark, bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // Faint luminous top edge falling to the flat surface colour.
        gradient: LinearGradient(
          colors: [
            isDark
                ? Color.lerp(colors.card, Colors.white, 0.07)!
                : Colors.white,
            colors.card,
            isDark
                ? Color.lerp(colors.card, Colors.black, 0.16)!
                : Color.lerp(colors.card, colors.ink, 0.04)!,
          ],
          stops: const [0.0, 0.38, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(22),
        // Rim: cool hairline in dark, near-white lift in light.
        border: Border.all(
          color: isDark
              ? colors.ink.withValues(alpha: 0.14)
              : Colors.white.withValues(alpha: 0.90),
          width: 1,
        ),
        // All three layers are outer shadows — they paint beyond the border
        // box and never contribute to width, height or layout spacing.
        boxShadow: [
          // 1. Sharp edge glow — tight, bright, sitting right on the rim.
          //    Low blur is what makes it read as a crisp lit edge rather
          //    than another soft halo.
          BoxShadow(
            color: isDark
                ? colors.red.withValues(alpha: 0.30)
                : Color.lerp(colors.red, Colors.white, 0.62)!
                    .withValues(alpha: 0.72),
            // Crisper in dark (the target's edge is defined, not diffuse);
            // wider in light, where the core reads as emitted light.
            blurRadius: isDark ? 10 : 18,
          ),
          // 2. Mid halo — carries the colour outward from the rim.
          BoxShadow(
            color: colors.red.withValues(alpha: isDark ? 0.24 : 0.32),
            blurRadius: 28,
            spreadRadius: 3,
          ),
          // 3. Bottom bloom — the target's dominant, lowest-frequency glow.
          BoxShadow(
            // In light the spill carries the same white-pink tint as the
            // core, rather than reading as pure red.
            color: isDark
                ? colors.red.withValues(alpha: 0.22)
                : Color.lerp(colors.red, Colors.white, 0.22)!
                    .withValues(alpha: 0.42),
            blurRadius: 58,
            spreadRadius: isDark ? 6 : 8,
            offset: Offset(0, isDark ? 22 : 26),
          ),
          // 4. Elevation — grounds the card against the background.
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.50 : 0.18),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card title
            Text(
              'Welcome Back',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: colors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sign in to your account',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colors.ink40,
              ),
            ),
            const SizedBox(height: 24),

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
              decoration: _inputDecoration(
                colors: colors,
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
            const SizedBox(height: 16),

            // ── Password Field ──────────────────────────────────────
            TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              enabled: !isLoading,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleLogin(),
              decoration: _inputDecoration(
                colors: colors,
                hint: l.password,
                icon: LucideIcons.lock,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                    size: 20,
                    color: colors.ink20,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
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
            const SizedBox(height: 12),

            // ── Remember Me ─────────────────────────────────────────
            GestureDetector(
              onTap: isLoading
                  ? null
                  : () => setState(() => _rememberMe = !_rememberMe),
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: isLoading
                          ? null
                          : (v) =>
                              setState(() => _rememberMe = v ?? false),
                      activeColor: colors.red,
                      checkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      side: BorderSide(
                        color: colors.red.withValues(alpha: 0.75),
                        width: 1.5,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l.rememberMe,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colors.ink60,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Login Button ────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: AppRadius.pillBR,
                  // Gradient lives on the wrapper; the button itself stays
                  // transparent so onPressed/disabled behaviour is untouched.
                  gradient: LinearGradient(
                    colors: [
                      Color.lerp(colors.red, Colors.white, 0.18)!
                          .withValues(alpha: isLoading ? 0.7 : 1.0),
                      colors.red.withValues(alpha: isLoading ? 0.7 : 1.0),
                      colors.redDark.withValues(alpha: isLoading ? 0.7 : 1.0),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: isLoading
                      ? []
                      : [
                          // Tight rim-light + wider bloom beneath the pill.
                          BoxShadow(
                            color: colors.red.withValues(alpha: 0.50),
                            blurRadius: 10,
                            spreadRadius: -1,
                            offset: const Offset(0, 2),
                          ),
                          BoxShadow(
                            color: colors.red.withValues(alpha: 0.38),
                            blurRadius: 26,
                            spreadRadius: -2,
                            offset: const Offset(0, 10),
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
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── API URL indicator ───────────────────────────────────
            _buildApiUrlIndicator(colors),
          ],
        ),
      ),
    );
  }

  // ── Input Decoration Helper ────────────────────────────────────────────────

  InputDecoration _inputDecoration({
    required AppColors colors,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      // Accent tile keeps the icon inside the existing field height:
      // 36px tall against ~46px of content, so geometry is unchanged.
      prefixIcon: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.only(left: 8, right: 8),
        decoration: BoxDecoration(
          color: colors.redSoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: colors.red.withValues(alpha: 0.20),
            width: 1,
          ),
        ),
        child: Icon(icon, size: 18, color: colors.red),
      ),
      prefixIconConstraints: const BoxConstraints(
        minWidth: 52,
        minHeight: 36,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: colors.bg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: _kFieldRadius,
        borderSide: BorderSide(color: colors.ink10, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: _kFieldRadius,
        borderSide: BorderSide(color: colors.ink10, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: _kFieldRadius,
        borderSide: BorderSide(color: colors.red, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: _kFieldRadius,
        borderSide: BorderSide(color: colors.redDot, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: _kFieldRadius,
        borderSide: BorderSide(color: colors.redDot, width: 1.5),
      ),
      hintStyle: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: colors.ink20,
      ),
      errorStyle: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: colors.redDot,
      ),
    );
  }
}
