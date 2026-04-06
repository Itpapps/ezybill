import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/dio_client.dart';
import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

// Re-export AppSession so other providers can import a single file.
export '../../core/config/app_session.dart' show appSessionProvider, AppSession;

// ─────────────────────────────────────────────────────────────────────────────
// Core infrastructure providers
// ─────────────────────────────────────────────────────────────────────────────

/// SharedPreferences — must be initialised before app starts and overridden
/// in the root [ProviderScope].
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

/// Secure Storage for tokens and sensitive data.
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
});

/// Dio HTTP client — singleton for the app lifetime.
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

// ─────────────────────────────────────────────────────────────────────────────
// Local datasource providers
// ─────────────────────────────────────────────────────────────────────────────

/// Auth local datasource — SharedPreferences + SecureStorage wrapper.
final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  return AuthLocalDatasource(
    secureStorage: ref.watch(secureStorageProvider),
    prefs: ref.watch(sharedPreferencesProvider),
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Remote datasource providers
// ─────────────────────────────────────────────────────────────────────────────

/// Auth remote datasource — login + access control API calls.
final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(dio: ref.watch(dioClientProvider));
});

// ─────────────────────────────────────────────────────────────────────────────
// Repository providers
// ─────────────────────────────────────────────────────────────────────────────

/// Auth repository — login, logout, session restore, access control.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDatasourceProvider),
    ref.watch(authLocalDatasourceProvider),
  );
});

// appSessionProvider is re-exported via the export directive at the top of this file.
