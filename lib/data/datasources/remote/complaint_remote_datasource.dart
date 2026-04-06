import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';

class ComplaintRemoteDatasource {
  final DioClient _dio;

  ComplaintRemoteDatasource({required DioClient dio}) : _dio = dio;

  /// Convenience getter — injects the stored authtoken into every payload.
  String get _authtoken => _dio.authToken ?? '';

  /// Get open complaints list
  /// Server: getComplaintList_post
  /// Payload: authtoken, serviceemployeeid, login_users_type
  Future<Map<String, dynamic>> getComplaintList({
    int serviceEmployeeId = 0,
    String loginUsersType = 'RESELLER',
  }) async {
    final response = await _dio.post(
      ApiConstants.complaintList,
      data: {
        'authtoken': _authtoken,
        'serviceemployeeid': serviceEmployeeId,
        'login_users_type': loginUsersType,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get all complaints (including closed)
  /// Server: gettotalcomplaintslist_post
  Future<Map<String, dynamic>> getTotalComplaintsList({
    int serviceEmployeeId = 0,
    String loginUsersType = 'RESELLER',
  }) async {
    final response = await _dio.post(
      ApiConstants.totalComplaintsList,
      data: {
        'authtoken': _authtoken,
        'serviceemployeeid': serviceEmployeeId,
        'login_users_type': loginUsersType,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get complaints for a specific customer
  /// Server: getCustomerComplaintListRest_post
  Future<Map<String, dynamic>> getCustomerComplaintList({
    required String customerId,
  }) async {
    final response = await _dio.post(
      ApiConstants.customerComplaintList,
      data: {
        'authtoken': _authtoken,
        'customerId': customerId,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get complaint categories
  /// Server: complaintCategoriesRest_post
  Future<Map<String, dynamic>> getComplaintCategories() async {
    final response = await _dio.post(
      ApiConstants.complaintCategories,
      data: {
        'authtoken': _authtoken,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get complaint sub-categories
  /// Server: getComplaintsubCategory_post
  Future<Map<String, dynamic>> getComplaintSubCategories({
    required String categoryId,
  }) async {
    final response = await _dio.post(
      ApiConstants.complaintSubCategories,
      data: {
        'authtoken': _authtoken,
        'categoryId': categoryId,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get complaint types / closer categories
  /// Server: complaintTypesRest_post
  Future<Map<String, dynamic>> getComplaintTypes() async {
    final response = await _dio.post(
      ApiConstants.complaintTypes,
      data: {
        'authtoken': _authtoken,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Create a new complaint
  /// Server: createComplaintRest_post
  Future<Map<String, dynamic>> createComplaint({
    required String customerId,
    required String complaint,
    required int category,
    String? error,
    int? assignedTo,
  }) async {
    final response = await _dio.post(
      ApiConstants.createComplaint,
      data: {
        'authtoken': _authtoken,
        'customerId': customerId,
        'complaint': complaint,
        'category': category,
        if (error != null) 'error': error,
        if (assignedTo != null) 'assignedTo': assignedTo,
      },
    );

    final data = response.data as Map<String, dynamic>;
    if (data['status_code'] == 0) {
      return data;
    }
    throw ApiException(
      message: data['status_msg']?.toString() ?? 'Failed to create complaint',
    );
  }

  /// Close / update a complaint
  /// Server: closeComplaintRest_post
  Future<Map<String, dynamic>> closeComplaint({
    required String complaintId,
    String? remarks,
  }) async {
    final response = await _dio.post(
      ApiConstants.closeComplaint,
      data: {
        'authtoken': _authtoken,
        'complaintId': complaintId,
        if (remarks != null) 'remarks': remarks,
      },
    );

    final data = response.data as Map<String, dynamic>;
    if (data['status_code'] == 0) {
      return data;
    }
    throw ApiException(
      message: data['status_msg']?.toString() ?? 'Failed to close complaint',
    );
  }

  /// Get complaint history for a customer
  /// Server: ComplaintHistoryRest_post
  /// FIX: uses customer_id (not complaintId) as per spec
  Future<Map<String, dynamic>> getComplaintHistory({
    required String customerId,
  }) async {
    final response = await _dio.post(
      ApiConstants.complaintHistory,
      data: {
        'authtoken': _authtoken,
        'customer_id': customerId,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get LCO employee list (used for assignment dropdowns)
  /// Server: getLcoEmployeeList_post
  Future<Map<String, dynamic>> getLcoEmployeeList({
    required int dealerId,
  }) async {
    final response = await _dio.post(
      ApiConstants.lcoEmployeeList,
      data: {
        'authtoken': _authtoken,
        'dealer_id': dealerId,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}
