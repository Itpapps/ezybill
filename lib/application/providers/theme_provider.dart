import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core_providers.dart';

/// SharedPreferences key for persisted theme selection.
const _kThemeKey = 'ezyquick-theme';

/// Maps a stored string value to [ThemeMode].
ThemeMode _themeModeFromString(String? value) {
  switch (value) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

/// Maps a [ThemeMode] to a string for persistence.
String _themeModeToString(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'light';
    case ThemeMode.dark:
      return 'dark';
    case ThemeMode.system:
      return 'system';
  }
}

/// Notifier that manages the app-wide [ThemeMode] and persists it
/// to SharedPreferences under the key `ezyquick-theme`.
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return _themeModeFromString(prefs.getString(_kThemeKey));
  }

  /// Update the theme mode and persist the choice.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_kThemeKey, _themeModeToString(mode));
  }
}

/// Global Riverpod provider for the current [ThemeMode].
///
/// Usage in MaterialApp:
/// ```dart
/// final themeMode = ref.watch(themeProvider);
/// MaterialApp(themeMode: themeMode, ...)
/// ```
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);
