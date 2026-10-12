import 'package:ezybill/core/network/api_exception.dart';
import 'package:ezybill/core/utils/result.dart';
import 'package:ezybill/data/datasources/remote/complaint_remote_datasource.dart';
import 'package:ezybill/data/models/complaint/complaint_category.dart';
import 'package:ezybill/data/models/complaint/complaint_subcategory.dart';
import 'package:ezybill/domain/repositories/complaint_repository.dart';

class ComplaintRepositoryImpl implements ComplaintRepository {
  final ComplaintRemoteDatasource _remoteDatasource;

  ComplaintRepositoryImpl(this._remoteDatasource);

  @override
  Future<Result<Map<String, dynamic>>> getComplaintList({
    int serviceEmployeeId = 0,
    String loginUsersType = 'RESELLER',
  }) async {
    try {
      final data = await _remoteDatasource.getComplaintList(
        serviceEmployeeId: serviceEmployeeId,
        loginUsersType: loginUsersType,
      );
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getTotalComplaintsList({
    int serviceEmployeeId = 0,
    String loginUsersType = 'RESELLER',
  }) async {
    try {
      final data = await _remoteDatasource.getTotalComplaintsList(
        serviceEmployeeId: serviceEmployeeId,
        loginUsersType: loginUsersType,
      );
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getCustomerComplaintList({
    required String customerId,
  }) async {
    try {
      final data = await _remoteDatasource.getCustomerComplaintList(
        customerId: customerId,
      );
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<List<ComplaintCategory>>> getComplaintCategories() async {
    try {
      final data = await _remoteDatasource.getComplaintCategories();
      // Server key is `complaintCategories` (complaintCategoriesRest_post). The
      // generic fallbacks are kept for any other tenant shape.
      final list = data['complaintCategories'] as List? ??
          data['data'] as List? ??
          data['categories'] as List? ??
          [];
      final categories =
          list.cast<Map<String, dynamic>>().map((e) => ComplaintCategory.fromJson(e)).toList();
      return Success(categories);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<List<ComplaintSubcategory>>> getComplaintSubCategories({
    required String categoryId,
  }) async {
    try {
      final data = await _remoteDatasource.getComplaintSubCategories(
        categoryId: categoryId,
      );
      // Server key is `complaintSubCategories` (getComplaintsubCategory_post).
      // Android reads the same key (GetSubcategoriesRest).
      final list = data['complaintSubCategories'] as List? ??
          data['data'] as List? ??
          data['subCategories'] as List? ??
          [];
      final subcategories =
          list.cast<Map<String, dynamic>>().map((e) => ComplaintSubcategory.fromJson(e)).toList();
      return Success(subcategories);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getComplaintTypes() async {
    try {
      final data = await _remoteDatasource.getComplaintTypes();
      // complaintTypesRest returns the statuses as
      // complaintStatuses: [{"value": "RESOLVED"}, …] (LcoRestServices.php:2614;
      // native reads `value`, ComplaintHistory_Other_Fragment.java:1369).
      // None of the old keys exist, so the status list used to be empty.
      final list = data['complaintStatuses'] as List? ??
          data['data'] as List? ??
          data['complaintTypes'] as List? ??
          data['closerTypes'] as List? ??
          [];
      return Success(list.whereType<Map<String, dynamic>>().toList());
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> createComplaint({
    required String customerId,
    required String complaint,
    required int category,
    String? error,
    int? assignedTo,
  }) async {
    try {
      final data = await _remoteDatasource.createComplaint(
        customerId: customerId,
        complaint: complaint,
        category: category,
        error: error,
        assignedTo: assignedTo,
      );
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> closeComplaint({
    required String complaintId,
    required String ticketNumber,
    required String comment,
    required String status,
    required String assignedEmp,
    String? closerTicketTypeId,
    String? closerReasonId,
  }) async {
    try {
      final data = await _remoteDatasource.closeComplaint(
        complaintId: complaintId,
        ticketNumber: ticketNumber,
        comment: comment,
        status: status,
        assignedEmp: assignedEmp,
        closerTicketTypeId: closerTicketTypeId,
        closerReasonId: closerReasonId,
      );
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getComplaintHistory({
    required String complaintId,
  }) async {
    try {
      // NOTE: Despite the parameter name, this now sends customer_id
      // to the server as fixed in the datasource.
      final data = await _remoteDatasource.getComplaintHistory(
        customerId: complaintId,
      );
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
