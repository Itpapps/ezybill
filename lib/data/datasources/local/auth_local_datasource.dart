import 'dart:convert';
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
    required Map<String, dynamic> fullResponse,
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
    await _prefs.setBool(AppConstants.prefKeyIsLoggedIn, true);
    await _prefs.setString(
        AppConstants.prefKeyLoginResponse, jsonEncode(fullResponse));
  }

  bool get isLoggedIn =>
      _prefs.getBool(AppConstants.prefKeyIsLoggedIn) ?? false;

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

  Map<String, dynamic>? get loginResponse {
    final json = _prefs.getString(AppConstants.prefKeyLoginResponse);
    if (json == null) return null;
    return jsonDecode(json) as Map<String, dynamic>;
  }

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs.clear();
  }
}
