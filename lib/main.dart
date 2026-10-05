import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'application/providers/core_providers.dart';
import 'application/providers/locale_provider.dart';
import 'application/providers/theme_provider.dart';
import 'core/constants/api_constants.dart';
import 'core/constants/app_constants.dart';
import 'core/services/debug_log_service.dart';
import 'core/theme/app_theme.dart';
import 'presentation/common/widgets/offline_banner.dart';
import 'presentation/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Restore saved API base URL if any.
  // Priority: login_url from BMS > api_base_url manual override > default
  var loginUrl = prefs.getString('login_url');
  final savedUrl = prefs.getString('api_base_url');
  debugPrint('[STARTUP] login_url="${loginUrl ?? "null"}" api_base_url="${savedUrl ?? "null"}"');

  // Migration: BMS always returns URLs ending with /wsController for V1 clients.
  // Old code stripped /wsController before storing. Fix stale values.
  // V2 clients intentionally store WITHOUT /wsController (they use LcoRestServices).
  final bmsVersion = prefs.getString('bms_version') ?? 'V1';
  if (bmsVersion.toUpperCase() != 'V2' &&
      loginUrl != null &&
      loginUrl.isNotEmpty &&
      loginUrl.endsWith('/index.php') &&
      !loginUrl.endsWith('/wsController')) {
    loginUrl = '$loginUrl/wsController';
    debugPrint('[STARTUP] Migration (V1): re-appended /wsController → $loginUrl');
    await prefs.setString('login_url', loginUrl);
    await prefs.setString('api_base_url', loginUrl);
  }

  if (loginUrl != null && loginUrl.isNotEmpty) {
    ApiConstants.setBaseUrl(loginUrl);
  } else if (savedUrl != null && savedUrl.isNotEmpty) {
    ApiConstants.setBaseUrl(savedUrl);
  }
  debugPrint('[STARTUP] Final baseUrl="${ApiConstants.baseUrl}"');

  // Restore debug logging preference
  final debugEnabled = prefs.getBool('debug_logging_enabled') ?? false;
  DebugLogService().enabled = debugEnabled;

  await _purgeLegacySessionData(prefs);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const EzyBillApp(),
    ),
  );
}

/// One-time cleanup for installs upgraded from builds that persisted the
/// login session (token in secure storage, `login_response_json` /
/// `is_logged_in` in prefs) and restored it on launch. Sessions are no longer
/// written to disk or restored (native Android parity), so leftover copies
/// are removed once. Runs before the first frame, awaited, and never blocks
/// startup on a storage failure (e.g. a Keystore reset after a device
/// restore); an unfinished purge simply retries on the next launch.
Future<void> _purgeLegacySessionData(SharedPreferences prefs) async {
  const purgedFlag = 'legacy_session_purged_v1';
  if (prefs.getBool(purgedFlag) ?? false) return;
  try {
    // Same store the app's secureStorageProvider uses (default options).
    const secure = FlutterSecureStorage();
    await secure.delete(key: AppConstants.prefKeyToken);
    await secure.delete(key: AppConstants.prefKeyJwtToken);
    await prefs.remove(AppConstants.prefKeyLoginResponse);
    await prefs.remove(AppConstants.prefKeyIsLoggedIn);
    await prefs.setBool(purgedFlag, true);
  } catch (e) {
    debugPrint('[STARTUP] Legacy session purge deferred: $e');
  }
}

class EzyBillApp extends ConsumerWidget {
  const EzyBillApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'EzyBill',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      builder: (context, child) {
        // Wrap the entire navigator output with the offline banner so it
        // appears above every screen regardless of route.
        return OfflineBanner(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
