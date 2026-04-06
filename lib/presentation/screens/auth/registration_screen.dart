import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../application/providers/bms_provider.dart';
import '../../../application/providers/core_providers.dart';
import '../../../application/providers/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/datasources/remote/bms_remote_datasource.dart';
import '../../../l10n/app_localizations.dart';
import '../../router/route_names.dart';

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
  Future<void> _loadDeviceId() async {
    final prefs = ref.read(sharedPreferencesProvider);
    String? deviceId = prefs.getString(kDeviceUuid);

    if (deviceId == null || deviceId.isEmpty) {
      // For web and as fallback: generate a simple UUID-like string
      if (kIsWeb) {
        deviceId = _generateSimpleUuid();
        await prefs.setString(kDeviceUuid, deviceId);
      } else {
        // Try to get Android ID via device_info_plus
        try {
          // Dynamically import to avoid web build issues
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

  /// Get Android ID using device_info_plus.
  Future<String?> _getAndroidId() async {
    try {
      // ignore: depend_on_referenced_packages
      final deviceInfo =
          await _importDeviceInfo();
      return deviceInfo;
    } catch (_) {
      return null;
    }
  }

  /// Dynamic import for device_info_plus to avoid web build issues.
  Future<String?> _importDeviceInfo() async {
    try {
      final plugin =
          // ignore: depend_on_referenced_packages
          (await Future.value(null)); // Placeholder - see note below
      // NOTE: For production, use:
      //   import 'package:device_info_plus/device_info_plus.dart';
      //   final deviceInfo = DeviceInfoPlugin();
      //   final androidInfo = await deviceInfo.androidInfo;
      //   return androidInfo.id;
      //
      // For now we return null and fall back to UUID generation.
      // The device_info_plus import should be added once the package is in pubspec.
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
    final colors = Theme.of(context).extension<AppColors>()!;
    final screenHeight = MediaQuery.of(context).size.height;
    final prefs = ref.read(sharedPreferencesProvider);
    final bmsUrl =
        prefs.getString(kBmsUrl) ?? BmsRemoteDatasource.defaultBmsUrl;

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

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.red, colors.redDark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
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
                      const SizedBox(height: 20),

                      // ── Language selector ──────────────────────────────
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: _showLanguageSelector,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              LucideIcons.globe,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Logo / Branding ────────────────────────────────
                      _buildHeader(colors, l),

                      const SizedBox(height: 36),

                      // ── Registration Card ──────────────────────────────
                      _buildRegistrationCard(colors, isLoading, l),

                      const SizedBox(height: 16),

                      // ── Device ID ──────────────────────────────────────
                      Text(
                        '${l.deviceId}: $_deviceId',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 9,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // ── BMS URL indicator ──────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              bmsUrl,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 9,
                                color: Colors.white.withValues(alpha: 0.4),
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
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ── Copyright ──────────────────────────────────────
                      Text(
                        'itpworld.com, All Rights Reserved',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.4),
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
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(AppColors colors, AppLocalizations l) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            LucideIcons.tv,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          l.appName,
          style: const TextStyle(
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

  // ── Registration Card ──────────────────────────────────────────────────────

  Widget _buildRegistrationCard(
    AppColors colors,
    bool isLoading,
    AppLocalizations l,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, 12),
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
              l.deviceRegistration,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: colors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l.registerDevice,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colors.ink40,
              ),
            ),
            const SizedBox(height: 24),

            // ── MSO Key Field ────────────────────────────────────────
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
              decoration: _inputDecoration(
                colors: colors,
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
            const SizedBox(height: 16),

            // ── Username Field ───────────────────────────────────────
            TextFormField(
              controller: _usernameController,
              focusNode: _usernameFocus,
              enabled: !isLoading,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.text,
              autocorrect: false,
              onFieldSubmitted: (_) => _handleRegister(),
              decoration: _inputDecoration(
                colors: colors,
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
            const SizedBox(height: 24),

            // ── Register Button ──────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: AppRadius.pillBR,
                  boxShadow: isLoading
                      ? []
                      : [
                          BoxShadow(
                            color: colors.red.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                ),
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.red,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: colors.red.withValues(alpha: 0.7),
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
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
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

  // ── Input Decoration Helper ────────────────────────────────────────────────

  InputDecoration _inputDecoration({
    required AppColors colors,
    required String hint,
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: colors.ink20),
      filled: true,
      fillColor: colors.bg,
      counterText: '', // Hide maxLength counter
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: AppRadius.pillBR,
        borderSide: BorderSide(color: colors.ink10, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.pillBR,
        borderSide: BorderSide(color: colors.ink10, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.pillBR,
        borderSide: BorderSide(color: colors.red, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.pillBR,
        borderSide: BorderSide(color: colors.redDot, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppRadius.pillBR,
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
