import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';

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
    // Note: Server may return statusCode: 1 ("Customer does not exist") but
    // still include customerDetailsList with actual data (e.g., when using '%' wildcard).
    // Only throw if there's genuinely no data.
    final list = data['customerDetailsList'] ?? data['existCustomerDetails'];
    final hasData = list is List && list.isNotEmpty && list.first is Map &&
        (list.first as Map)['customer_id'] != null &&
        (list.first as Map)['customer_id'].toString().isNotEmpty;
    if (hasData) {
      return data; // Return data regardless of statusCode
    }
    final statusCode = data['statusCode'] ?? data['status_code'];
    if (statusCode == 0 || statusCode == '0') {
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
    final response = await _dio.post(
      ApiConstants.saveCustomer,
      data: {
        'authtoken': authtoken,
        ...customerData,
      },
    );

    final data = response.data as Map<String, dynamic>;
    if (data['status_code'] == 0) {
      return data;
    }
    throw ApiException(
      message: data['status_msg']?.toString() ?? 'Failed to save customer',
    );
  }

  /// Edit existing customer
  /// Server: editCustomerRest_post
  Future<Map<String, dynamic>> editCustomer({
    required String authtoken,
    required Map<String, dynamic> customerData,
  }) async {
    final response = await _dio.post(
      ApiConstants.editCustomer,
      data: {
        'authtoken': authtoken,
        ...customerData,
      },
    );

    final data = response.data as Map<String, dynamic>;
    if (data['status_code'] == 0) {
      return data;
    }
    throw ApiException(
      message: data['status_msg']?.toString() ?? 'Failed to update customer',
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
        'customerId': customerId,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}
