import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';

class AuthRemoteDatasource {
  final DioClient _dio;
  final http.Client _httpClient;

  AuthRemoteDatasource({required DioClient dio, http.Client? httpClient})
      : _dio = dio,
        _httpClient = httpClient ?? http.Client();

  /// Login — auto-selects SOAP (live/wsController) or REST (local) based on
  /// the current environment.
  ///
  /// LIVE:  SOAP to wsController (Android app does the same)
  /// LOCAL: REST to LcoRestServices/validateLogin
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
    String? mobileNo,
    String? imei,
    String? employeeId,
  }) async {
    if (ApiConstants.isWsController) {
      return _loginSoap(
        username: username,
        password: password,
        employeeId: employeeId ?? '',
        imei: imei ?? '',
      );
    }
    return _loginRest(
      username: username,
      password: password,
      mobileNo: mobileNo,
      imei: imei,
    );
  }

  /// REST login — direct POST to LcoRestServices/validateLogin (local/dev).
  Future<Map<String, dynamic>> _loginRest({
    required String username,
    required String password,
    String? mobileNo,
    String? imei,
  }) async {
    final response = await _dio.post(
      ApiConstants.validateLogin,
      data: {
        'UserName': username,
        'PassWord': password,
        if (mobileNo != null) 'mobile_no': mobileNo,
        if (imei != null) 'imei': imei,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final statusCode = data['status_code'];

    final token = data['token']?.toString() ?? '';
    final isSuccess = statusCode == 0 || statusCode == '0';
    if (isSuccess && token.isNotEmpty) return data;

    throw ApiException(
      message: data['status_msg']?.toString() ?? 'Login failed',
      statusCode: statusCode is int ? statusCode : 0,
    );
  }

  /// SOAP login — sends SOAP envelope to wsController/validateLogin (live).
  ///
  /// Matches the Android app's KSoap2 call with `.dotNet = true`,
  /// `.setAddAdornments(false)`, and empty namespace.
  /// See EzyBill_Authentication_Flow.md §7 "Phase 2: Login".
  Future<Map<String, dynamic>> _loginSoap({
    required String username,
    required String password,
    required String employeeId,
    required String imei,
  }) async {
    final url = ApiConstants.baseUrl; // .../index.php/wsController

    // KSoap2 .dotNet=true envelope format (namespace is empty string)
    final soapXml = '''<?xml version="1.0" encoding="utf-8"?>
<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance"
            xmlns:d="http://www.w3.org/2001/XMLSchema"
            xmlns:c="http://schemas.xmlsoap.org/soap/encoding/"
            xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">
  <v:Header />
  <v:Body>
    <validateLogin xmlns="" id="o0" c:root="1">
      <loginInfo>
        <UserName>$username</UserName>
        <PassWord>$password</PassWord>
        <employeeId>$employeeId</employeeId>
        <imei>$imei</imei>
      </loginInfo>
    </validateLogin>
  </v:Body>
</v:Envelope>''';

    debugPrint('[SOAP-LOGIN] URL: $url');
    debugPrint('[SOAP-LOGIN] Body: UserName=$username, employeeId=$employeeId, imei=$imei');

    try {
      final response = await _httpClient
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'text/xml; charset=utf-8',
              'SOAPAction': '/validateLogin',
            },
            body: utf8.encode(soapXml),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('[SOAP-LOGIN] HTTP ${response.statusCode}');
      debugPrint('[SOAP-LOGIN] Response body (first 500): '
          '${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      if (response.statusCode != 200) {
        throw ApiException(
          message: 'Login server returned HTTP ${response.statusCode}',
        );
      }

      // Detect V2 server returning HTML instead of SOAP XML — fall back to REST
      if (response.body.contains('<!DOCTYPE') || response.body.contains('<html')) {
        debugPrint('[SOAP-LOGIN] Server returned HTML — V2 server detected, '
            'switching to REST login');
        // Strip /wsController so isWsController becomes false
        final restBase = url.replaceAll('/wsController', '');
        ApiConstants.setBaseUrl(restBase);
        // Persist so cold starts don't retry SOAP
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('login_url', restBase);
        await prefs.setString('api_base_url', restBase);
        await prefs.setString('bms_version', 'V2');
        return _loginRest(
          username: username,
          password: password,
          imei: imei,
        );
      }

      return _parseSoapLoginResponse(response.body);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Login failed: $e');
    }
  }

  /// Parse SOAP login response into a Map compatible with LoginResponse.fromJson.
  ///
  /// The response is semicolon-separated (same format as BMS registration):
  /// `statusCode=0;authToken=xxx;employeeId=3;dealerId=1;...`
  ///
  /// Maps SOAP field names → REST/JSON field names for LoginResponse compatibility.
  Map<String, dynamic> _parseSoapLoginResponse(String xml) {
    // Extract semicolon-separated string from SOAP XML
    final resultString = _extractSoapResult(xml);
    if (resultString == null || resultString.isEmpty) {
      throw ApiException(message: 'Empty login response from server');
    }

    debugPrint('[SOAP-LOGIN] Parsed result: $resultString');

    // Parse semicolon-separated key=value pairs
    final soapMap = <String, String>{};
    for (final pair in resultString.split(';')) {
      final trimmed = pair.trim();
      if (trimmed.isEmpty) continue;
      final eqIndex = trimmed.indexOf('=');
      if (eqIndex == -1) continue;
      soapMap[trimmed.substring(0, eqIndex).trim()] =
          trimmed.substring(eqIndex + 1).trim();
    }

    // Map SOAP field names → LoginResponse JSON field names
    final data = <String, dynamic>{
      'status_code': int.tryParse(soapMap['statusCode'] ?? '') ?? 1,
      'status_msg': soapMap['statusMessage'] ?? soapMap['statusMsg'] ?? '',
      'token': soapMap['authToken'] ?? soapMap['token'] ?? '',
      'dealerId': int.tryParse(soapMap['dealerId'] ?? '') ?? 0,
      'employeeId': int.tryParse(soapMap['employeeId'] ?? '') ?? 0,
      'userType': soapMap['userType'] ?? '',
      'employeeName': soapMap['employeeName'] ?? '',
      'business_name': soapMap['business_name'] ?? '',
      'first_name': soapMap['first_name'] ?? soapMap['employeeName'] ?? '',
      'employeeParentType': soapMap['employeeParentType'] ?? '',
      'employeeParentId': soapMap['employeeParentId'] ?? '',
    };

    // Copy remaining fields as-is (config flags, defaults, etc.)
    for (final entry in soapMap.entries) {
      data.putIfAbsent(entry.key, () => entry.value);
    }

    final statusCode = data['status_code'];
    final token = data['token']?.toString() ?? '';
    final isSuccess = statusCode == 0;

    if (isSuccess && token.isNotEmpty) return data;

    throw ApiException(
      message: data['status_msg']?.toString() ?? 'Login failed',
      statusCode: statusCode is int ? statusCode : 0,
    );
  }

  /// Extract the result string from a SOAP XML response.
  String? _extractSoapResult(String xml) {
    // Try <return>...</return>
    var match = RegExp(r'<return[^>]*>(.*?)</return>', dotAll: true).firstMatch(xml);
    if (match != null) return match.group(1)?.trim();

    // Try namespaced <ns1:return>...</ns1:return>
    match = RegExp(r'<\w+:return[^>]*>(.*?)</\w+:return>', dotAll: true).firstMatch(xml);
    if (match != null) return match.group(1)?.trim();

    // Try <validateLoginReturn>...</validateLoginReturn>
    match = RegExp(r'<validateLoginReturn[^>]*>(.*?)</validateLoginReturn>', dotAll: true).firstMatch(xml);
    if (match != null) return match.group(1)?.trim();

    // Try structured XML <parameters>...</parameters>
    match = RegExp(r'<parameters[^>]*>(.*?)</parameters>', dotAll: true).firstMatch(xml);
    if (match != null) {
      final inner = match.group(1) ?? '';
      // Convert XML tags to semicolon format
      final pairs = RegExp(r'<(\w+)>([^<]*)</\1>').allMatches(inner);
      return pairs.map((m) => '${m.group(1)}=${m.group(2)}').join(';');
    }

    // Fallback: look for semicolon-separated pattern
    match = RegExp(r'statusCode=\d+;[^<]+', dotAll: true).firstMatch(xml);
    return match?.group(0)?.trim();
  }

  /// Get Access Control - POST /LcoRestServices/getaccesscontrollRest
  Future<Map<String, dynamic>> getAccessControl({
    required String authtoken,
    required int dealerId,
    required String usersType,
    required String employeeParentType,
    required String employeeParentId,
  }) async {
    final response = await _dio.post(
      ApiConstants.getAccessControl,
      data: {
        'authtoken': authtoken,
        'dealer_id': dealerId.toString(),
        'userstype': usersType,
        'employeeParentType': employeeParentType,
        'employeeParentId': employeeParentId,
      },
    );

    return response.data as Map<String, dynamic>;
  }
}
