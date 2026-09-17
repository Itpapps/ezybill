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
  ///
  /// The server reads `$this->payload->complaintcategory` (LcoRestServices.php
  /// getComplaintsubCategory_post); anything else is ignored and it answers
  /// status_code 1 "Please Enter Category". Android sends exactly this key on
  /// both its REST and V1 paths (Complaint_NewComplint_Fragment
  /// GetSubcategoriesRest / complaintsubcategory).
  Future<Map<String, dynamic>> getComplaintSubCategories({
    required String categoryId,
  }) async {
    final response = await _dio.post(
      ApiConstants.complaintSubCategories,
      data: {
        'authtoken': _authtoken,
        'complaintcategory': categoryId,
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
  ///
  /// `assignedTo` is ALWAYS sent, as `0` when no employee was chosen. Android
  /// does the same (CreateComplaintRest: `payload.put("assignedTo",
  /// String.valueOf(selempid))`, selempid = 0 for "select"). Omitting it is
  /// not neutral: createComplaintRest_post falls back to the LOGGED-IN
  /// employee, so the complaint would be silently assigned to its creator.
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
        'assignedTo': assignedTo ?? 0,
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
  ///
  /// [employeeId] is the customer's reseller id. Android always sends it
  /// (Complaint_NewComplint_Fragment.Getemployeelistrest:
  /// `payload.put("employee_id", reseller_id)`), and the server passes it to
  /// getLcoEmployeeList($dealer_id, $lco_employee_id) to FILTER the list.
  /// Optional so existing callers that only know the dealer keep working.
  Future<Map<String, dynamic>> getLcoEmployeeList({
    required int dealerId,
    int? employeeId,
  }) async {
    final response = await _dio.post(
      ApiConstants.lcoEmployeeList,
      data: {
        'authtoken': _authtoken,
        'dealer_id': dealerId,
        'employee_id': ?employeeId,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}
