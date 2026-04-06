import 'package:flutter/foundation.dart';
import 'package:ezybill/core/network/api_exception.dart';
import 'package:ezybill/core/network/dio_client.dart';
import 'package:ezybill/core/utils/result.dart';
import 'package:ezybill/data/datasources/remote/customer_remote_datasource.dart';
import 'package:ezybill/data/models/customer/customer_search_response.dart';
import 'package:ezybill/domain/repositories/customer_repository.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDatasource _remoteDatasource;
  final DioClient _dio;

  CustomerRepositoryImpl(this._remoteDatasource, this._dio);

  String get _authtoken => _dio.authToken ?? '';

  @override
  Future<Result<Map<String, dynamic>>> getCustomerDetailsCount({
    String? customerNumber,
    String? customerName,
    String? mobileNumber,
    String? boxNumber,
    String? lcoCustomerId,
  }) async {
    try {
      debugPrint('[REPO] authtoken=${_authtoken.isNotEmpty ? "${_authtoken.substring(0, 10)}..." : "EMPTY!"}');
      debugPrint('[REPO] getCustomerDetailsCount: name=$customerName, mobile=$mobileNumber, number=$customerNumber, box=$boxNumber, lcoId=$lcoCustomerId');
      final data = await _remoteDatasource.getCustomerDetailsCount(
        authtoken: _authtoken,
        customerNumber: customerNumber,
        customerName: customerName,
        mobileNumber: mobileNumber,
        boxNumber: boxNumber,
        lcoCustomerId: lcoCustomerId,
      );
      // status_code: 0 = success, 1 = error
      final statusCode = data['status_code'] ?? data['statusCode'];
      if (statusCode == 1) {
        final msg = data['status_msg'] ?? data['statusMessage'] ?? 'Not found';
        debugPrint('[REPO] Count failed: $msg');
        // Return success with 0 count instead of failure — "not found" is valid
        return Success({'customerCount': 0, 'status_msg': msg});
      }
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<CustomerSearchResponse>> searchCustomers({
    String? customerNumber,
    String? customerName,
    String? mobileNumber,
    String? boxNumber,
    String? lcoCustomerId,
    String? cafNumber,
    int startValue = 0,
    int endValue = 20,
  }) async {
    try {
      final data = await _remoteDatasource.getCustomerDetails(
        authtoken: _authtoken,
        customerNumber: customerNumber,
        customerName: customerName,
        mobileNumber: mobileNumber,
        boxNumber: boxNumber,
        lcoCustomerId: lcoCustomerId,
        cafNumber: cafNumber,
        startValue: startValue,
        endValue: endValue,
      );
      final response = CustomerSearchResponse.fromJson(data);
      return Success(response);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> checkExistingCustomer({
    required String mobileNumber,
  }) async {
    try {
      final data = await _remoteDatasource.checkExistingCustomer(
        authtoken: _authtoken,
        mobileNumber: mobileNumber,
      );
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> saveCustomer({
    required Map<String, dynamic> customerData,
  }) async {
    try {
      final data = await _remoteDatasource.saveCustomer(
        authtoken: _authtoken,
        customerData: customerData,
      );
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> editCustomer({
    required Map<String, dynamic> customerData,
  }) async {
    try {
      final data = await _remoteDatasource.editCustomer(
        authtoken: _authtoken,
        customerData: customerData,
      );
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> updateCustomerLocation({
    required String customerId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final data = await _remoteDatasource.updateCustomerLocation(
        authtoken: _authtoken,
        customerId: customerId,
        latitude: latitude,
        longitude: longitude,
      );
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
