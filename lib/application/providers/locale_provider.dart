import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core_providers.dart';

/// SharedPreferences key for persisted locale selection.
const _kLocaleKey = 'app_locale';

/// Maps a stored string value to [Locale].
Locale _localeFromString(String? value) {
  switch (value) {
    case 'te':
      return const Locale('te');
    case 'hi':
      return const Locale('hi');
    default:
      return const Locale('en');
  }
}

/// Maps a [Locale] to a string for persistence.
String _localeToString(Locale locale) {
  return locale.languageCode;
}

/// Notifier that manages the app-wide [Locale] and persists it
/// to SharedPreferences under the key `app_locale`.
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return _localeFromString(prefs.getString(_kLocaleKey));
  }

  /// Update the locale and persist the choice.
  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_kLocaleKey, _localeToString(locale));
  }
}

/// Global Riverpod provider for the current [Locale].
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);
