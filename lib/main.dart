import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'application/providers/core_providers.dart';
import 'application/providers/locale_provider.dart';
import 'application/providers/theme_provider.dart';
import 'core/constants/api_constants.dart';
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
  final loginUrl = prefs.getString('login_url');
  final savedUrl = prefs.getString('api_base_url');
  if (loginUrl != null && loginUrl.isNotEmpty) {
    ApiConstants.setBaseUrl(loginUrl);
  } else if (savedUrl != null && savedUrl.isNotEmpty) {
    ApiConstants.setBaseUrl(savedUrl);
  }

  // Restore debug logging preference
  final debugEnabled = prefs.getBool('debug_logging_enabled') ?? false;
  DebugLogService().enabled = debugEnabled;

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const EzyBillApp(),
    ),
  );
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
