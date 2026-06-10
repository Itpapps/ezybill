import 'dart:convert';

import '../../../core/constants/api_constants.dart';
import '../../../core/utils/parse_utils.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/payload_encryption.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class CustomerRemoteDatasource {
  final DioClient _dio;

  CustomerRemoteDatasource({required DioClient dio}) : _dio = dio;

  /// Get customer count matching search criteria
  /// Server: getCustomerDetailsCountRest_post
  Future<Map<String, dynamic>> getCustomerDetailsCount({
    required String authtoken,
    String? customerNumber,
    String? customerName,
    String? mobileNumber,
    String? boxNumber,
    String? lcoCustomerId,
    String? cafNumber,
  }) async {
    final response = await _dio.post(
      ApiConstants.customerDetailsCount,
      data: {
        'authtoken': authtoken,
        if (customerNumber != null) 'customerNumber': customerNumber,
        if (customerName != null) 'customerName': customerName,
        if (mobileNumber != null) 'mobileNumber': mobileNumber,
        if (boxNumber != null) 'boxNumber': boxNumber,
        if (lcoCustomerId != null) 'lcoCustomerId': lcoCustomerId,
        if (cafNumber != null) 'cafNumber': cafNumber,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get customer details list with pagination
  /// Server: getCustomerDetailsRest_post
  Future<Map<String, dynamic>> getCustomerDetails({
    required String authtoken,
    String? customerNumber,
    String? customerName,
    String? mobileNumber,
    String? boxNumber,
    String? lcoCustomerId,
    String? cafNumber,
    int startValue = 0,
    int endValue = 20,
  }) async {
    final response = await _dio.post(
      ApiConstants.customerDetails,
      data: {
        'authtoken': authtoken,
        if (customerNumber != null) 'customerNumber': customerNumber,
        if (customerName != null) 'customerName': customerName,
        if (mobileNumber != null) 'mobileNumber': mobileNumber,
        if (boxNumber != null) 'boxNumber': boxNumber,
        if (lcoCustomerId != null) 'lcoCustomerId': lcoCustomerId,
        if (cafNumber != null) 'cafNumber': cafNumber,
        'startValue': startValue,
        'endValue': endValue,
      },
    );

    final data = response.data as Map<String, dynamic>;
    debugPrint('[CUST-DS] getCustomerDetails response keys: ${data.keys.toList()}');

    // Note: Server may return statusCode: 1 ("Customer does not exist") but
    // still include customerDetailsList with actual data (e.g., when using '%' wildcard).
    // Only throw if there's genuinely no data.
    final rawListVal = data['customerDetailsList'] ?? data['existCustomerDetails'];
    // parseMapList handles all three shapes:
    //   REST array      → [{customer_obj}, ...]
    //   PHP indexed Map → {"0":{customer_obj}} → unwrapped to [{customer_obj}]
    //   SOAP bare Map   → {customer_id:1413,...} → wrapped to [{customer_id:1413,...}]
    final list = parseMapList(rawListVal);
    debugPrint('[CUST-DS] list type: ${rawListVal.runtimeType}, '
        'length: ${list is List ? list.length : 'N/A'}');

    if (list is List && list.isNotEmpty && list.first is Map) {
      final first = list.first as Map;
      debugPrint('[CUST-DS] first item keys: ${first.keys.toList()}');

      // Check for customer ID under both snake_case and camelCase keys.
      // The DB query may return either form depending on the SQL aliases.
      final custId = first['customer_id'] ?? first['customerId'];
      final hasRealData = custId != null && custId.toString().isNotEmpty;

      if (hasRealData) {
        // Write the normalised list back so downstream fromJson sees a List.
        // Filter to Map-only elements: PHP may append integer metadata (e.g.
        // lco_deposits, deposits) alongside customer objects in the same array.
        if (rawListVal is Map) {
          data['customerDetailsList'] = (list as List)
              .whereType<Map<String, dynamic>>()
              .toList();
        }
        return data; // Real customer data found — return regardless of statusCode
      }
    }

    // Fallback: if statusCode is success, return data even without validated customer_id
    final statusCode = data['statusCode'] ?? data['status_code'];
    if (statusCode == 0 || statusCode == '0') {
      return data;
    }

    // If the response contains ANY list data, return it and let the UI decide
    // (server sometimes sets statusCode:1 but still includes data)
    if (list is List && list.isNotEmpty) {
      debugPrint('[CUST-DS] statusCode=$statusCode but list has ${list.length} items — returning data');
      return data;
    }

    throw ApiException(
      message: data['statusMessage']?.toString() ??
          data['status_msg']?.toString() ??
          'Customer search failed',
    );
  }

  /// Check if customer already exists
  /// Server: existingCustomerRest_post
  Future<Map<String, dynamic>> checkExistingCustomer({
    required String authtoken,
    required String mobileNumber,
  }) async {
    final response = await _dio.post(
      ApiConstants.existingCustomer,
      data: {
        'authtoken': authtoken,
        'mobileNumber': mobileNumber,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Save new customer
  /// Server: saveCustomerRest_post
  Future<Map<String, dynamic>> saveCustomer({
    required String authtoken,
    required Map<String, dynamic> customerData,
  }) async {
    if (authtoken.trim().isEmpty) {
      throw UnauthorizedException(message: 'Session missing. Please login again.');
    }
    // ── FULL payload dump — copy ALL lines between ▼▼▼ and ▲▲▲ ─────
    print('▼▼▼ SAVE_CUSTOMER FULL PAYLOAD ▼▼▼');
    customerData.forEach((key, value) {
      print('  $key = $value');
    });
    print('▲▲▲ SAVE_CUSTOMER FULL PAYLOAD ▲▲▲');
    // ────────────────────────────────────────────────────────────────
    final response = await _dio.post(
      ApiConstants.saveCustomer,
      data: {
        'authtoken': authtoken,
        ...customerData,
      },
      options: Options(
        headers: {'Authorization': 'Bearer $authtoken'},
      ),
    );

    final data = response.data as Map<String, dynamic>;
    final status = data['status_code'] ?? data['statusCode'];
    if (status == 0 || status == '0') {
      return data;
    }
    if (kDebugMode) {
      debugPrint('[SAVE_CUSTOMER] Failed response keys: ${data.keys.toList()}');
      debugPrint('[SAVE_CUSTOMER] Failed response: $data');
    }
    throw ApiException(
      message: (data['status_msg'] ?? data['statusMessage'])?.toString() ??
          'Failed to save customer',
      statusCode: status is int ? status : int.tryParse(status?.toString() ?? ''),
      data: data,
    );
  }

  /// Edit existing customer
  /// Server: editCustomerRest_post
  Future<Map<String, dynamic>> editCustomer({
    required String authtoken,
    required Map<String, dynamic> customerData,
  }) async {
    if (authtoken.trim().isEmpty) {
      throw UnauthorizedException(message: 'Session missing. Please login again.');
    }
    // ── Pre-request diagnostic logging ──────────────────────────────
    debugPrint('[EDIT_CUST_REQ] token(first20): ${authtoken.length > 20 ? authtoken.substring(0, 20) : authtoken}');
    debugPrint('[EDIT_CUST_REQ] customerId  : ${customerData["customerId"]}');
    debugPrint('[EDIT_CUST_REQ] dealer_id   : ${customerData["dealer_id"]}');
    debugPrint('[EDIT_CUST_REQ] employee_id : ${customerData["employee_id"]}');
    debugPrint('[EDIT_CUST_REQ] reseller_id : ${customerData["reseller_id"]}');
    debugPrint('[EDIT_CUST_REQ] group       : ${customerData["group"]}');
    debugPrint('[EDIT_CUST_REQ] ALL keys    : ${(["authtoken"] + customerData.keys.toList())}');
    // ────────────────────────────────────────────────────────────────
    final response = await _dio.post(
      ApiConstants.editCustomer,
      data: {
        'authtoken': authtoken,
        ...customerData,
      },
      options: Options(
        headers: {'Authorization': 'Bearer $authtoken'},
      ),
    );

    final data = response.data as Map<String, dynamic>;
    final status = data['status_code'] ?? data['statusCode'];
    if (status == 0 || status == '0') {
      return data;
    }
    if (kDebugMode) {
      debugPrint('[EDIT_CUSTOMER] Failed response keys: ${data.keys.toList()}');
      debugPrint('[EDIT_CUSTOMER] Failed response: $data');
    }
    throw ApiException(
      message: (data['status_msg'] ?? data['statusMessage'])?.toString() ??
          'Failed to update customer',
      statusCode: status is int ? status : int.tryParse(status?.toString() ?? ''),
      data: data,
    );
  }

  /// Update customer GPS location
  /// Server: updateCustomerLocation_post
  Future<Map<String, dynamic>> updateCustomerLocation({
    required String authtoken,
    required String customerId,
    required double latitude,
    required double longitude,
  }) async {
    final response = await _dio.post(
      ApiConstants.updateCustomerLocation,
      data: {
        'authtoken': authtoken,
        'customer_id': int.tryParse(customerId) ?? 0,
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      },
    );
    var data = response.data;

    // If response is a String, try to JSON-decode it
    if (data is String) {
      try {
        data = jsonDecode(data);
      } catch (_) {
        throw ApiException(message: 'Invalid server response (not JSON)');
      }
    }
    if (data is! Map<String, dynamic>) {
      throw ApiException(message: 'Invalid server response format');
    }

    // If interceptor missed decryption (status_code absent but hash present),
    // try manual decryption as fallback.
    if (!data.containsKey('status_code') &&
        data.containsKey('hash') &&
        data['hash'] is String) {
      final decrypted = PayloadEncryption.decryptHash(data['hash'] as String);
      if (decrypted != null) {
        data = decrypted;
      }
    }

    final status = data['status_code'];
    debugPrint('[LOC UPDATE] status_code=$status status_msg=${data['status_msg']}');
    if (status == 0 || status == '0') {
      return data;
    }
    throw ApiException(
      message: data['status_msg']?.toString() ??
          'Location update failed (status_code: $status)',
      statusCode: status is int ? status : int.tryParse(status?.toString() ?? ''),
      data: data,
    );
  }
}
