import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import '../../data/datasources/remote/bms_remote_datasource.dart';
import '../../data/models/auth/bms_registration_response.dart';
import 'core_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BMS State
// ─────────────────────────────────────────────────────────────────────────────

enum BmsStatus {
  idle,
  checking,
  registering,
  registered,
  needsRegistration,
  error,
}

class BmsState {
  final BmsStatus status;
  final String? error;
  final BmsRegistrationResponse? response;

  const BmsState({
    this.status = BmsStatus.idle,
    this.error,
    this.response,
  });

  BmsState copyWith({
    BmsStatus? status,
    String? error,
    BmsRegistrationResponse? response,
  }) {
    return BmsState(
      status: status ?? this.status,
      error: error,
      response: response ?? this.response,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BmsState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          error == other.error;

  @override
  int get hashCode => Object.hash(status, error);

  @override
  String toString() => 'BmsState(status: $status, error: $error)';
}

// ─────────────────────────────────────────────────────────────────────────────
// SharedPreferences keys for BMS data
// ─────────────────────────────────────────────────────────────────────────────

const String kSmsKey = 'smsKey';
const String kBmsAuth = 'bmsAuth';
const String kLoginUrl = 'login_url';
const String kBmsEmployeeId = 'bms_emp_id';
const String kAppThemeColor = 'appThemeColor';
const String kAppDashboard = 'appDashboard';
const String kAppLogoPath = 'appLogoPath';
const String kDeviceUuid = 'device_uuid';
const String kBmsUrl = 'bms_url';

// ─────────────────────────────────────────────────────────────────────────────
// BMS Notifier
// ─────────────────────────────────────────────────────────────────────────────

class BmsNotifier extends Notifier<BmsState> {
  late SharedPreferences _prefs;
  late BmsRemoteDatasource _datasource;

  @override
  BmsState build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    _datasource = ref.watch(bmsRemoteDatasourceProvider);
    return const BmsState();
  }

  /// Get the device ID. For web, use a stored UUID. For Android, use
  /// device_info_plus's Android ID (passed in from the screen).
  String _getStoredDeviceId() {
    return _prefs.getString(kDeviceUuid) ?? 'unknown';
  }

  /// Get BMS URL (custom or default).
  String? _getBmsUrl() {
    return _prefs.getString(kBmsUrl);
  }

  /// Check if the device is already registered with BMS.
  ///
  /// Called on app start. If `smsKey` exists in SharedPreferences, the device
  /// was previously registered. We still verify with the BMS server.
  Future<void> checkRegistration({String? deviceId}) async {
    state = const BmsState(status: BmsStatus.checking);

    final id = deviceId ?? _getStoredDeviceId();
    final bmsUrl = _getBmsUrl();

    try {
      final response = await _datasource.checkRegistration(
        deviceId: id,
        bmsUrl: bmsUrl,
      );

      if (response.isSuccess) {
        await _storeRegistrationData(response, id);
        state = BmsState(
          status: BmsStatus.registered,
          response: response,
        );
      } else {
        state = BmsState(
          status: BmsStatus.needsRegistration,
          error: response.statusMessage,
          response: response,
        );
      }
    } on BmsException catch (e) {
      state = BmsState(
        status: BmsStatus.error,
        error: e.message,
      );
    } catch (e) {
      state = BmsState(
        status: BmsStatus.error,
        error: 'Connection failed: $e',
      );
    }
  }

  /// Register a new device with the BMS server using MSO Key + Username.
  Future<void> register({
    required String msoKey,
    required String username,
    String? deviceId,
  }) async {
    state = state.copyWith(status: BmsStatus.registering, error: null);

    final id = deviceId ?? _getStoredDeviceId();
    final bmsUrl = _getBmsUrl();

    try {
      final response = await _datasource.register(
        msoKey: msoKey,
        username: username,
        deviceId: id,
        bmsUrl: bmsUrl,
      );

      if (response.isSuccess) {
        // Store the smsCode (msoKey + username) as smsKey
        final smsCode = '$msoKey$username';
        await _storeRegistrationData(response, id, smsCode: smsCode);
        state = BmsState(
          status: BmsStatus.registered,
          response: response,
        );
      } else {
        // Map status codes to user-friendly messages
        final errorMsg = _mapStatusError(response.statusCode, response.statusMessage);
        state = BmsState(
          status: BmsStatus.error,
          error: errorMsg,
          response: response,
        );
      }
    } on BmsException catch (e) {
      state = BmsState(
        status: BmsStatus.error,
        error: e.message,
      );
    } catch (e) {
      state = BmsState(
        status: BmsStatus.error,
        error: 'Registration failed: $e',
      );
    }
  }

  /// Store registration data to SharedPreferences and update ApiConstants.
  Future<void> _storeRegistrationData(
    BmsRegistrationResponse response,
    String deviceId, {
    String? smsCode,
  }) async {
    // Store smsKey (marks device as registered)
    if (smsCode != null && smsCode.isNotEmpty) {
      await _prefs.setString(kSmsKey, smsCode);
    } else {
      // For auto-login check, preserve existing smsKey or set a marker
      final existing = _prefs.getString(kSmsKey);
      if (existing == null || existing.isEmpty) {
        await _prefs.setString(kSmsKey, 'auto_registered');
      }
    }

    await _prefs.setBool(kBmsAuth, true);
    await _prefs.setString(kDeviceUuid, deviceId);

    // Store REST API URL from BMS response
    if (response.ipAddress.isNotEmpty) {
      final restUrl = response.restBaseUrl;
      await _prefs.setString(kLoginUrl, restUrl);
      await _prefs.setString('api_base_url', restUrl);
      ApiConstants.setBaseUrl(restUrl);
    }

    // Store other BMS config
    await _prefs.setString(kBmsEmployeeId, response.employeeId);
    await _prefs.setInt(kAppThemeColor, response.appThemeColor);
    await _prefs.setInt(kAppDashboard, response.appDashboard);
    await _prefs.setString(kAppLogoPath, response.appLogoPath);
  }

  /// Map BMS status codes to user-friendly error messages.
  String _mapStatusError(int statusCode, String serverMessage) {
    switch (statusCode) {
      case 1:
        return serverMessage.isNotEmpty
            ? serverMessage
            : 'Please check and enter valid details';
      case 2:
        return 'Maximum registrations reached';
      case 3:
        return 'Your app subscription expired, please renew';
      case 4:
        return 'App does not exist';
      case 5:
        return 'Employee does not exist';
      default:
        return serverMessage.isNotEmpty
            ? serverMessage
            : 'Registration failed (code: $statusCode)';
    }
  }

  /// Update the BMS URL.
  Future<void> setBmsUrl(String url) async {
    await _prefs.setString(kBmsUrl, url);
  }

  /// Check if the device has an existing BMS registration stored locally.
  bool get hasLocalRegistration {
    final smsKey = _prefs.getString(kSmsKey);
    return smsKey != null && smsKey.length > 1;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

/// BMS remote datasource provider.
final bmsRemoteDatasourceProvider = Provider<BmsRemoteDatasource>((ref) {
  return BmsRemoteDatasource();
});

/// BMS registration state provider.
final bmsProvider = NotifierProvider<BmsNotifier, BmsState>(BmsNotifier.new);
