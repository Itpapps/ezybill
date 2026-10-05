import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

class AuthLocalDatasource {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  AuthLocalDatasource({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences prefs,
  })  : _secureStorage = secureStorage,
        _prefs = prefs;

  // JWT Token
  Future<void> saveJwtToken(String token) async {
    await _secureStorage.write(
        key: AppConstants.prefKeyJwtToken, value: token);
  }

  Future<String?> getJwtToken() async {
    return _secureStorage.read(key: AppConstants.prefKeyJwtToken);
  }

  // Auth Token
  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(
        key: AppConstants.prefKeyToken, value: token);
  }

  Future<String?> getAuthToken() async {
    return _secureStorage.read(key: AppConstants.prefKeyToken);
  }

  // User Data
  //
  // Profile fields only. No token, no "logged in" flag and no copy of the
  // login response are written: a session is never restored from disk
  // (native Android parity — see AuthNotifier.build).
  Future<void> saveUserData({
    required int dealerId,
    required int employeeId,
    required String userType,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String lcoCode,
    required String businessName,
    required String parentType,
    required String parentId,
  }) async {
    await _prefs.setInt(AppConstants.prefKeyDealerId, dealerId);
    await _prefs.setInt(AppConstants.prefKeyEmployeeId, employeeId);
    await _prefs.setString(AppConstants.prefKeyUserType, userType);
    await _prefs.setString(AppConstants.prefKeyFirstName, firstName);
    await _prefs.setString(AppConstants.prefKeyLastName, lastName);
    await _prefs.setString(AppConstants.prefKeyEmail, email);
    await _prefs.setString(AppConstants.prefKeyPhone, phone);
    await _prefs.setString(AppConstants.prefKeyLcoCode, lcoCode);
    await _prefs.setString(AppConstants.prefKeyBusinessName, businessName);
    await _prefs.setString(AppConstants.prefKeyParentType, parentType);
    await _prefs.setString(AppConstants.prefKeyParentId, parentId);
    await _prefs.setString(
        AppConstants.prefKeyEmployeeName, '$firstName $lastName');
  }

  int get dealerId => _prefs.getInt(AppConstants.prefKeyDealerId) ?? 0;
  int get employeeId => _prefs.getInt(AppConstants.prefKeyEmployeeId) ?? 0;
  String get userType =>
      _prefs.getString(AppConstants.prefKeyUserType) ?? '';
  String get firstName =>
      _prefs.getString(AppConstants.prefKeyFirstName) ?? '';
  String get lastName =>
      _prefs.getString(AppConstants.prefKeyLastName) ?? '';
  String get employeeName =>
      _prefs.getString(AppConstants.prefKeyEmployeeName) ?? '';
  String get email => _prefs.getString(AppConstants.prefKeyEmail) ?? '';
  String get phone => _prefs.getString(AppConstants.prefKeyPhone) ?? '';
  String get lcoCode =>
      _prefs.getString(AppConstants.prefKeyLcoCode) ?? '';
  String get businessName =>
      _prefs.getString(AppConstants.prefKeyBusinessName) ?? '';
  String get parentType =>
      _prefs.getString(AppConstants.prefKeyParentType) ?? '';
  String get parentId =>
      _prefs.getString(AppConstants.prefKeyParentId) ?? '';

  /// Clears application login/session state only.
  ///
  /// BMS/device registration state is deliberately preserved, matching the
  /// native Android app where logout clears no preferences at all. The keys
  /// left intact — smsKey, bmsAuth, login_url, api_base_url, bms_url,
  /// bms_version, device_uuid, bms_emp_id and the BMS-supplied
  /// theme/dashboard/logo config — are what the registration and environment
  /// lifecycle depend on; wiping them forced a full BMS re-registration on
  /// every logout.
  ///
  /// Secure storage holds only jwt_token and auth_token, both session-scoped,
  /// so it is still cleared wholesale.
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();

    // The keys written by saveUserData(), plus the legacy is_logged_in /
    // login_response_json keys that older builds persisted (kept here so an
    // upgraded install is cleaned on its first logout).
    const sessionKeys = <String>[
      AppConstants.prefKeyDealerId,
      AppConstants.prefKeyEmployeeId,
      AppConstants.prefKeyUserType,
      AppConstants.prefKeyFirstName,
      AppConstants.prefKeyLastName,
      AppConstants.prefKeyEmail,
      AppConstants.prefKeyPhone,
      AppConstants.prefKeyLcoCode,
      AppConstants.prefKeyBusinessName,
      AppConstants.prefKeyParentType,
      AppConstants.prefKeyParentId,
      AppConstants.prefKeyEmployeeName,
      AppConstants.prefKeyIsLoggedIn,
      AppConstants.prefKeyLoginResponse,
    ];
    for (final key in sessionKeys) {
      await _prefs.remove(key);
    }
  }
}
