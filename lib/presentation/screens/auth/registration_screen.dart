import 'dart:math' as math;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MethodChannel, SystemUiOverlayStyle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../application/providers/bms_provider.dart';
import '../../../application/providers/core_providers.dart';
import '../../../application/providers/locale_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/datasources/remote/bms_remote_datasource.dart';
import '../../../l10n/app_localizations.dart';
import '../../router/route_names.dart';

/// Native device-identity channel (Android handler in MainActivity.kt).
const MethodChannel _deviceChannel = MethodChannel('com.itp.ezybill/device');

// ── Registration palette (white & red only) ──────────────────────────────────
// The login screen's values, copied here so the login screen is not touched.
// AppColors is NOT modified.

const Color _kBgTop = Color(0xFFF6E8EA);
const Color _kBgMid = Color(0xFFF1DEE1);
const Color _kBgBottom = Color(0xFFEBD2D5);
const Color _kRed = Color(0xFFD42A32);
const Color _kRedDeco = Color(0xFFD62A32);
const Color _kGlowRed = Color(0xFFDC2D35);
const Color _kInk = Color(0xFF1E1A1C);
const Color _kInkSoft = Color(0xFF6E6468);
const Color _kPlaceholder = Color(0xFFA99EA3);
const Color _kShadowWarm = Color(0xFFA05058); // rgb(160, 80, 88)

// Soft-touch surfaces. The card face is a faint blush rather than pure white,
// so the white highlights of the raised logo, fields and globe button show.
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
/// Flutter's default (20 all round) left the next field and the button under
/// the keyboard; 160 below keeps them in view too.
const EdgeInsets _kFieldScrollPadding = EdgeInsets.fromLTRB(20, 20, 20, 160);

/// One google_fonts base style per weight, built once. Calling GoogleFonts
/// inside every build would restart a failed font fetch on each keyboard frame
/// while the device is offline and the font is not cached yet.
final Map<FontWeight, TextStyle> _kFontByWeight = {};

/// Registration text style in the app's own font — the theme's Plus Jakarta
/// Sans, through google_fonts (already a dependency).
TextStyle _regText(
  double size,
  FontWeight weight,
  Color color, {
  double? letterSpacing,
}) =>
    (_kFontByWeight[weight] ??=
            GoogleFonts.plusJakartaSans(fontWeight: weight))
        .copyWith(
      fontSize: size,
      color: color,
      letterSpacing: letterSpacing,
    );

/// Card layout metrics, as on the login screen. Phones get a compact set so
/// the single card stays short; tablets (shortest side >= 600) get the larger
/// set.
class _RegMetrics {
  const _RegMetrics({
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
    required this.headingSize,
    required this.gapBeforeFields,
    required this.fieldHeight,
    required this.fieldGap,
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
  final double headingSize;
  final double gapBeforeFields;
  final double fieldHeight;
  final double fieldGap;
  final double gapBeforeButton;
  final double buttonHeight;
  final double buttonTextSize;

  static const phone = _RegMetrics(
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
    headingSize: 20,
    gapBeforeFields: 16,
    fieldHeight: 52,
    // Room for each raised field's soft shadow before the next one.
    fieldGap: 14,
    gapBeforeButton: 20,
    buttonHeight: 50,
    buttonTextSize: 16,
  );

  static const tablet = _RegMetrics(
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
    headingSize: 22,
    gapBeforeFields: 22,
    fieldHeight: 58,
    fieldGap: 18,
    gapBeforeButton: 26,
    buttonHeight: 56,
    buttonTextSize: 16.5,
  );
}

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _msoKeyController = TextEditingController();
  final _usernameController = TextEditingController();
  final _msoKeyFocus = FocusNode();
  final _usernameFocus = FocusNode();

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  String _deviceId = 'Loading...';

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

    _loadDeviceId();

    // Request Bluetooth permissions early — only once, non-blocking
    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _requestBluetoothPermissionsIfNeeded();
      });
    }
  }

  @override
  void dispose() {
    _msoKeyController.dispose();
    _usernameController.dispose();
    _msoKeyFocus.dispose();
    _usernameFocus.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  /// Load or generate the device ID.
  ///
  /// An already-stored `device_uuid` is always reused as-is (older installs
  /// registered with BMS under that value; it must not change until a later
  /// pass re-validates the device with BMS). A new id is derived only when
  /// nothing is stored yet.
  Future<void> _loadDeviceId() async {
    final prefs = ref.read(sharedPreferencesProvider);
    String? deviceId = prefs.getString(kDeviceUuid);

    if (deviceId == null || deviceId.isEmpty) {
      // For web and as fallback: generate a simple UUID-like string
      if (kIsWeb) {
        deviceId = _generateSimpleUuid();
        await prefs.setString(kDeviceUuid, deviceId);
      } else {
        // Android: native ANDROID_ID via MethodChannel (see MainActivity.kt)
        try {
          deviceId = await _getAndroidId();
          if (deviceId != null && deviceId.isNotEmpty) {
            await prefs.setString(kDeviceUuid, deviceId);
          } else {
            deviceId = _generateSimpleUuid();
            await prefs.setString(kDeviceUuid, deviceId);
          }
        } catch (_) {
          deviceId = _generateSimpleUuid();
          await prefs.setString(kDeviceUuid, deviceId);
        }
      }
    }

    if (mounted) {
      setState(() => _deviceId = deviceId!);
    }
  }

  /// Android only: `Settings.Secure.ANDROID_ID` from the native side
  /// (MainActivity.kt, channel `com.itp.ezybill/device`) — the same
  /// identifier the native EzyBill app sends as `imei` on Android 10+.
  /// Returns null on other platforms or when the value is unavailable, so
  /// the caller keeps its existing fallback.
  Future<String?> _getAndroidId() async {
    if (defaultTargetPlatform != TargetPlatform.android) return null;
    try {
      final id = await _deviceChannel.invokeMethod<String>('androidId');
      if (id != null && id.isNotEmpty) return id;
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Generate a simple UUID v4-like string for device identification.
  String _generateSimpleUuid() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final hash = now.hashCode.toRadixString(16).padLeft(8, '0');
    final random = Object().hashCode.toRadixString(16).padLeft(8, '0');
    return '$hash-$random-${now.toRadixString(16)}';
  }

  // ── Bluetooth Permission Request (early, one-shot) ─────────────────────────

  /// Request Bluetooth (and Location for BLE scan) permissions once at
  /// first launch. This ensures system prompts appear early, before the user
  /// tries to use the printer, providing a smooth UX.
  ///
  /// Uses SharedPreferences flag [_kBtPermRequested] so we only ask once.
  static const String _kBtPermRequested = 'bt_permissions_requested';

  Future<void> _requestBluetoothPermissionsIfNeeded() async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final alreadyRequested = prefs.getBool(_kBtPermRequested) ?? false;
      if (alreadyRequested) return;

      // Mark as requested immediately so we don't repeat on orientation change
      await prefs.setBool(_kBtPermRequested, true);

      // Wait a moment for the registration UI to fully render
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      // Request all Bluetooth-related permissions
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ].request();

      debugPrint('[BT Perm] Results: $statuses');
      if (!mounted) return;

      // Check if any are permanently denied — show a gentle info dialog
      final permanentlyDenied = statuses.values
          .any((s) => s == PermissionStatus.permanentlyDenied);

      if (permanentlyDenied) {
        _showBtPermInfoDialog();
      }
    } catch (e) {
      // Never crash on permission failure — log and continue
      debugPrint('[BT Perm] Error requesting permissions: $e');
    }
  }

  /// Shows a gentle, dismissible dialog when Bluetooth permissions are
  /// permanently denied. Does NOT block registration or app usage.
  void _showBtPermInfoDialog() {
    if (!mounted) return;
    final colors = Theme.of(context).extension<AppColors>()!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: colors.card,
        icon: Icon(LucideIcons.bluetooth, color: colors.red, size: 28),
        title: Text(
          'Bluetooth Permission',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: colors.ink,
          ),
        ),
        content: Text(
          'To use the thermal printer for receipts, please allow Bluetooth '
          'access via App Settings → Permissions → Bluetooth.',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 14,
            color: colors.ink60,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Later',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                color: colors.ink40,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Open Settings',
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

  // ── Connectivity Check ─────────────────────────────────────────────────────


  Future<bool> _isConnected() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return !result.contains(ConnectivityResult.none);
    } catch (_) {
      return true;
    }
  }

  // ── Registration Handler ───────────────────────────────────────────────────

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final connected = await _isConnected();
    if (!connected && mounted) {
      _showErrorSnackbar('No internet connection. Please check your network.');
      return;
    }

    await ref.read(bmsProvider.notifier).register(
          msoKey: _msoKeyController.text.trim(),
          username: _usernameController.text.trim(),
          deviceId: _deviceId,
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
                style: const TextStyle(
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

  // ── Success Dialog ─────────────────────────────────────────────────────────

  void _showSuccessDialog() {
    final l = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<AppColors>()!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: colors.card,
        title: Row(
          children: [
            Icon(LucideIcons.checkCircle2, color: colors.green, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l.registrationSuccessful,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: colors.ink,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          l.registrationSuccess,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 14,
            color: colors.ink60,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go(RouteNames.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              l.ok,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── BMS URL Edit Dialog ────────────────────────────────────────────────────

  void _showBmsUrlDialog() {
    final l = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<AppColors>()!;
    final prefs = ref.read(sharedPreferencesProvider);
    final currentUrl =
        prefs.getString(kBmsUrl) ?? BmsRemoteDatasource.defaultBmsUrl;
    final controller = TextEditingController(text: currentUrl);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: colors.card,
        title: Text(
          'BMS Server URL',
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
                hintText: 'http://183.83.216.66:9090/...',
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
                controller.text = BmsRemoteDatasource.defaultBmsUrl;
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
                ref.read(bmsProvider.notifier).setBmsUrl(url);
              }
              Navigator.pop(ctx);
              setState(() {});
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
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Language Selector ──────────────────────────────────────────────────────

  void _showLanguageSelector() {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l = AppLocalizations.of(context)!;
    final currentLocale = ref.read(localeProvider);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: colors.card,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.ink20,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l.language,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.ink,
              ),
            ),
            const SizedBox(height: 16),
            _languageTile(
              'English',
              const Locale('en'),
              currentLocale,
              colors,
            ),
            _languageTile(
              '\u0C24\u0C46\u0C32\u0C41\u0C17\u0C41', // Telugu
              const Locale('te'),
              currentLocale,
              colors,
            ),
            _languageTile(
              '\u0939\u093F\u0928\u094D\u0926\u0940', // Hindi
              const Locale('hi'),
              currentLocale,
              colors,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _languageTile(
    String label,
    Locale locale,
    Locale currentLocale,
    AppColors colors,
  ) {
    final isSelected = locale == currentLocale;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 15,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? colors.red : colors.ink,
        ),
      ),
      trailing: isSelected
          ? Icon(LucideIcons.check, color: colors.red, size: 20)
          : null,
      onTap: () {
        ref.read(localeProvider.notifier).setLocale(locale);
        Navigator.pop(context);
      },
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final bmsState = ref.watch(bmsProvider);
    final isLoading = bmsState.status == BmsStatus.checking ||
        bmsState.status == BmsStatus.registering;
    final screenHeight = MediaQuery.of(context).size.height;
    final prefs = ref.read(sharedPreferencesProvider);
    final bmsUrl =
        prefs.getString(kBmsUrl) ?? BmsRemoteDatasource.defaultBmsUrl;
    final m = MediaQuery.sizeOf(context).shortestSide >= 600
        ? _RegMetrics.tablet
        : _RegMetrics.phone;

    // Listen for state changes
    ref.listen<BmsState>(bmsProvider, (prev, next) {
      if (next.status == BmsStatus.registered &&
          prev?.status != BmsStatus.registered) {
        _showSuccessDialog();
      } else if (next.status == BmsStatus.error &&
          next.error != null &&
          prev?.error != next.error) {
        _showErrorSnackbar(next.error!);
      }
    });

    // Light canvas → dark status-bar icons. This screen only ever leads on to
    // the login screen, which sets the same style, so nothing carries over.
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
          // The backdrop carries its own explicit height, so it stays fixed
          // instead of squashing while the keyboard opens; the Stack clips
          // whatever falls below the shrunken body.
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
                      painter: _BackdropPainter(),
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
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            // Phone: full width minus 24px each side.
                            // Tablet: capped at 560px and centred, as on the
                            // login screen.
                            Center(
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 560),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // ── Language selector ──────────────
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: GestureDetector(
                                        onTap: _showLanguageSelector,
                                        child: _buildGlobeButton(),
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // ── Registration Card ──────────────
                                    // RepaintBoundary gives the card its
                                    // own layer, so scrolling moves it
                                    // without repainting its blurred
                                    // shadows.
                                    RepaintBoundary(
                                      child: _buildRegistrationCard(
                                          l, m, isLoading),
                                    ),
                                    const SizedBox(height: 18),

                                    // ── Device ID ──────────────────────
                                    Text(
                                      '${l.deviceId}: $_deviceId',
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 10,
                                        color: _kInkSoft.withValues(
                                            alpha: 0.8),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    // ── BMS URL indicator (debug/profile
                                    // builds only) ──
                                    // Absent from release: the BMS endpoint
                                    // is a build constant end users must
                                    // not be able to redirect.
                                    if (kDevToolsEnabled) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              bmsUrl,
                                              style: TextStyle(
                                                fontFamily: 'monospace',
                                                fontSize: 9,
                                                color: _kInkSoft.withValues(
                                                    alpha: 0.7),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          GestureDetector(
                                            onTap: _showBmsUrlDialog,
                                            child: Icon(
                                              LucideIcons.pencil,
                                              size: 12,
                                              color: _kRed.withValues(
                                                  alpha: 0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],

                                    const SizedBox(height: 10),

                                    // ── Copyright ──────────────────────
                                    Text(
                                      'itpworld.com, All Rights Reserved',
                                      textAlign: TextAlign.center,
                                      style: _regText(
                                          11, FontWeight.w400, _kInkSoft),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
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
      ),
    );
  }

  // ── Language Button ────────────────────────────────────────────────────────

  /// Raised soft round button behind the globe icon. The tap stays on the
  /// GestureDetector around it, as before.
  Widget _buildGlobeButton() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kSoftFaceTop, _kSoftFaceBottom],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.white,
            offset: Offset(-3, -3),
            blurRadius: 6,
          ),
          BoxShadow(
            color: _kSoftShadow,
            offset: Offset(3, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: const Icon(LucideIcons.globe, color: _kRed, size: 20),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  /// Raised soft tile holding the red brand square with the TV icon.
  Widget _buildLogoTile(_RegMetrics m) {
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
            const Icon(LucideIcons.tv, size: 38, color: Colors.white),
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

  // ── Registration Card ──────────────────────────────────────────────────────

  /// The single soft card holding everything: branding, divider, title,
  /// both fields and Register. All form wiring is unchanged.
  Widget _buildRegistrationCard(
    AppLocalizations l,
    _RegMetrics m,
    bool isLoading,
  ) {
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
                style: _regText(m.titleSize, FontWeight.w800, _kInk,
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
                l.deviceRegistration,
                textAlign: TextAlign.center,
                style: _regText(m.headingSize, FontWeight.w700, _kInk),
              ),
              SizedBox(height: m.gapBeforeFields),

              // Fields fade back while registering, the way the disabled
              // fields used to look. Only the look changes; the disabling
              // itself is the unchanged `enabled` wiring.
              Opacity(
                opacity: isLoading ? 0.6 : 1.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── MSO Key Field ──────────────────────────────────
                    TextFormField(
                      controller: _msoKeyController,
                      focusNode: _msoKeyFocus,
                      enabled: !isLoading,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      maxLength: 4,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_usernameFocus),
                      style: _regText(15, FontWeight.w600, _kInk),
                      cursorColor: _kRed,
                      scrollPadding: _kFieldScrollPadding,
                      decoration: _inputDecoration(
                        m: m,
                        hint: l.enterMsoKey,
                        label: l.msoKey,
                        icon: LucideIcons.key,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l.enterValidDetails;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: m.fieldGap),

                    // ── Username Field ─────────────────────────────────
                    TextFormField(
                      controller: _usernameController,
                      focusNode: _usernameFocus,
                      enabled: !isLoading,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      onFieldSubmitted: (_) => _handleRegister(),
                      style: _regText(15, FontWeight.w600, _kInk),
                      cursorColor: _kRed,
                      scrollPadding: _kFieldScrollPadding,
                      decoration: _inputDecoration(
                        m: m,
                        hint: l.username,
                        label: l.username,
                        icon: LucideIcons.user,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l.enterValidDetails;
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: m.gapBeforeButton),

              // ── Register Button ─────────────────────────────────────
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
                    onPressed: isLoading ? null : _handleRegister,
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
                            l.register,
                            style: _regText(m.buttonTextSize,
                                FontWeight.w600, Colors.white),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Input Decoration Helper ────────────────────────────────────────────────

  /// Raised soft-touch field, as on the login screen: light halo top-left,
  /// warm shadow bottom-right, no visible border line (a faint red ring only
  /// on focus / error), round raised icon well.
  InputDecoration _inputDecoration({
    required _RegMetrics m,
    required String hint,
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: _regText(15, FontWeight.w500, _kPlaceholder),
      prefixIcon: _FieldIconTile(icon: icon),
      prefixIconConstraints: const BoxConstraints(minWidth: 54, minHeight: 36),
      // The face is a gradient painted by _SoftFieldBorder, not a flat fill.
      filled: false,
      counterText: '', // Hide maxLength counter
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
      errorStyle: _regText(11.5, FontWeight.w500, _kRed),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Soft-look building blocks — copies of the login screen's (login_screen.dart),
// kept in this file so the login screen is not touched. Keep the two in step
// by hand when changing either.
// ─────────────────────────────────────────────────────────────────────────────

/// One cluster of the halftone field. All geometry is fractional (0..1 of the
/// canvas), so the composition scales with the viewport.
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

/// The three dot clusters: a dense corner top-right, a band off the left edge
/// mid-screen, and a cluster bottom-left.
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

/// Paints the halftone dot texture behind the content. Static — it rasterises
/// once and is then served from the RepaintBoundary cache.
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

/// The decorative canvas behind the card: a vertical gradient, two soft red
/// glows (top-right, bottom-left), a tilted white panel bottom-right, a faint
/// thin ring and three dot clusters.
///
/// Static — no state, never repaints — so behind its RepaintBoundary it is
/// rasterised once and does not redraw while the keyboard animates.
class _BackdropPainter extends CustomPainter {
  const _BackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;

    // 1. Base gradient, top to bottom.
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
  bool shouldRepaint(covariant _BackdropPainter oldDelegate) => false;
}

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
