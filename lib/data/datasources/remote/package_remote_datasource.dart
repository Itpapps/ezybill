import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';

class PackageRemoteDatasource {
  final DioClient _dio;

  PackageRemoteDatasource({required DioClient dio}) : _dio = dio;

  /// Get customer's assigned packages (split by category).
  /// Uses customer_service_id for deactivation — NOT product_id.
  Future<Map<String, dynamic>> getCustomerPackages({
    required String authtoken,
    required String customerId,
    required String stbNo,
  }) async {
    final response = await _dio.post(
      ApiConstants.customerPackages,
      data: {
        'authtoken': authtoken,
        'customerId': customerId,
        'boxNumber': stbNo,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get unassigned/available packages (split by category).
  Future<Map<String, dynamic>> getUnassignedPackages({
    required String authtoken,
    required String customerId,
    required String stbNo,
  }) async {
    final response = await _dio.post(
      ApiConstants.unassignedPackages,
      data: {
        'authtoken': authtoken,
        'customerId': customerId,
        'boxNumber': stbNo,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get bill details before activation — REST V2.
  ///
  /// Endpoint: /getbilldetailsRest
  /// Params: authtoken, dealer_id, employee_id, customer_id, package_id
  ///         (comma-separated), serial_number
  Future<Map<String, dynamic>> getBillDetails({
    required String authtoken,
    required String dealerId,
    required String employeeId,
    required String customerId,
    required String packageId,
    required String serialNumber,
  }) async {
    final response = await _dio.post(
      ApiConstants.billDetails,
      data: {
        'authtoken': authtoken,
        'dealer_id': dealerId,
        'employee_id': employeeId,
        'customer_id': customerId,
        'package_id': packageId,
        'serial_number': serialNumber,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Activate service — sends all required params from the Android spec.
  ///
  /// CRITICAL: Uses product_id (comma-separated) NOT customer_service_id.
  /// Package-cycle fields are passed from provider using backend package data.
  Future<Map<String, dynamic>> activateService({
    required String authtoken,
    required String customerId,
    required String customerDeviceId,
    required String productId,
    required String stockId,
    required String quantity,
    required String dateType,
    required String pricingStructureType,
    required String validityDays,
    required String dealerId,
    required String resellerId,
    required String loginEmployeeId,
  }) async {
    final response = await _dio.post(
      ApiConstants.activateService,
      data: {
        'authtoken': authtoken,
        'customerId': customerId,
        'customerDeviceId': customerDeviceId,
        'productId': productId,
        'quantity': quantity,
        'dateType': dateType,
        'pricingStructureType': pricingStructureType,
        'validityDays': validityDays,
        'stockId': stockId,
        'fromMobileApp': '1',
        'login_employee_id': loginEmployeeId,
        'resellerId': resellerId,
        'dealer_id': dealerId,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Deactivate service.
  ///
  /// CRITICAL: Uses customer_service_id (comma-separated) NOT product_id.
  /// Remarks always get suffix: ". Deactivation From Flutter App"
  Future<Map<String, dynamic>> deactivateService({
    required String authtoken,
    required String customerId,
    required String serviceId,
    required String reasonId,
    required String remarks,
    required String dealerId,
    required String resellerId,
    required String loginEmployeeId,
    String? stockId,
  }) async {
    final response = await _dio.post(
      ApiConstants.deactivateService,
      data: {
        'authtoken': authtoken,
        'customerId': customerId,
        'serviceId': serviceId,
        'reasonId': reasonId,
        'remarks': remarks,
        'fromMobileApp': '1',
        'dealer_id': dealerId,
        'resellerId': resellerId,
        'login_employee_id': loginEmployeeId,
        if (stockId != null) 'stock_id': stockId,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Extend customer services
  Future<Map<String, dynamic>> extendService({
    required String authtoken,
    required String customerId,
    required String stbNo,
    required String packageId,
    required String months,
  }) async {
    final response = await _dio.post(
      ApiConstants.extendService,
      data: {
        'authtoken': authtoken,
        'customer_id': customerId,
        'stb_no': stbNo,
        'package_id': packageId,
        'months': months,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get CAS packages
  Future<Map<String, dynamic>> getCasPackages({
    required String authtoken,
    String? boxNumber,
  }) async {
    final response = await _dio.post(
      ApiConstants.casPackages,
      data: {
        'authtoken': authtoken,
        if (boxNumber != null) 'boxNumber': boxNumber,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get channel list
  Future<Map<String, dynamic>> getChannelList({
    required String authtoken,
    required String packageId,
  }) async {
    final response = await _dio.post(
      ApiConstants.channelList,
      data: {
        'authtoken': authtoken,
        'package_id': packageId,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get renewable services list — REST V2.
  ///
  /// Endpoint: /getRenewServicesList
  /// Params: authtoken, dealer_id, customer_id
  Future<Map<String, dynamic>> getRenewServices({
    required String authtoken,
    required String customerId,
    required String dealerId,
  }) async {
    final response = await _dio.post(
      ApiConstants.getRenewServices,
      data: {
        'authtoken': authtoken,
        'dealer_id': dealerId,
        'customer_id': customerId,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Submit renewal — REST V2.
  ///
  /// Endpoint: /renewServicesList
  /// CRITICAL: Sends BOTH customer_service_id AND product_ids
  /// (comma-separated separately).
  Future<Map<String, dynamic>> renewServices({
    required String authtoken,
    required String customerId,
    required String dealerId,
    required String customerServiceIds,
    required String productIds,
  }) async {
    final response = await _dio.post(
      ApiConstants.renewServices,
      data: {
        'authtoken': authtoken,
        'dealer_id': dealerId,
        'customer_id': customerId,
        'customer_service_id': customerServiceIds,
        'product_ids': productIds,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}
