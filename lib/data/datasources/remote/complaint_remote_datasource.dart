import 'package:flutter/foundation.dart';

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
  ///
  /// The server reads the customer as `altCustomerId` (LcoRestServices.php,
  /// getCustomerComplaintListRest_post), which is what native sends
  /// (Complaint_Operations_Fragment.java:504). It used to go out as
  /// `customerId`, which the server never reads.
  Future<Map<String, dynamic>> getCustomerComplaintList({
    required String customerId,
  }) async {
    final response = await _dio.post(
      ApiConstants.customerComplaintList,
      data: {
        'authtoken': _authtoken,
        'altCustomerId': customerId,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Service employees a complaint update can be assigned to.
  /// Server: getServiceEmployeeList_post (LcoRestServices.php:8117) — reads
  /// `dealer_id`; returns `getServiceEmployeeList` [{employee_id, first_name}]
  /// or status_code 1 "No Services Employees.". Native's update screen uses
  /// this list (ComplaintHistory_Other_Fragment.GetServiceemployeelistRest),
  /// not the LCO employee list used when creating a complaint.
  Future<Map<String, dynamic>> getServiceEmployeeList({
    required int dealerId,
  }) async {
    final response = await _dio.post(
      ApiConstants.serviceEmployeeList,
      data: {
        'authtoken': _authtoken,
        'dealer_id': dealerId,
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
  /// Server: closeComplaintRest_post (LcoRestServices.php:6928)
  ///
  /// complaintId, ticketNumber, comment, status and assignedemp are all
  /// `isRequired` on the server (:6934), and native sends exactly these five
  /// (ComplaintHistory_Other_Fragment.java:1601-1605). The old call sent only
  /// complaintId plus `remarks`, so every update failed validation.
  /// The closer ids are optional — the server reads them only for RESOLVED
  /// with ticket closure enabled — and go out only when one was chosen.
  Future<Map<String, dynamic>> closeComplaint({
    required String complaintId,
    required String ticketNumber,
    required String comment,
    required String status,
    required String assignedEmp,
    String? closerTicketTypeId,
    String? closerReasonId,
  }) async {
    if (kDebugMode) {
      // Plain values for comparison with native's `updatecomp` log line
      // (ComplaintHistory_Other_Fragment.java:1606). No token, no comment.
      debugPrint('[COMPLAINT-UPDATE] complaintId=$complaintId '
          'ticketNumber=$ticketNumber status=$status assignedemp=$assignedEmp');
    }
    final response = await _dio.post(
      ApiConstants.closeComplaint,
      data: {
        // Native's V2 payload is exactly the five fields below — identity
        // comes from the JWT header. The server hands this WHOLE payload to
        // Simplecomplaints_model->insertstatus() (LcoRestServices.php:7033),
        // so an extra `authtoken` key is not harmless here the way it is for
        // calls that read named fields only. V1 (wsController) keeps it.
        if (ApiConstants.isWsController) 'authtoken': _authtoken,
        'complaintId': complaintId,
        'ticketNumber': ticketNumber,
        'comment': comment,
        'status': status,
        'assignedemp': assignedEmp,
        if (closerTicketTypeId != null && closerTicketTypeId.isNotEmpty)
          'closer_ticket_type_id': closerTicketTypeId,
        if (closerReasonId != null && closerReasonId.isNotEmpty)
          'closer_reason_id': closerReasonId,
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
