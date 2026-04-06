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
      final list = data['data'] as List? ?? data['categories'] as List? ?? [];
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
      final list = data['data'] as List? ?? data['subCategories'] as List? ?? [];
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
      final list = data['data'] as List? ??
          data['complaintTypes'] as List? ??
          data['closerTypes'] as List? ??
          [];
      return Success(list.cast<Map<String, dynamic>>());
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
    String? remarks,
  }) async {
    try {
      final data = await _remoteDatasource.closeComplaint(
        complaintId: complaintId,
        remarks: remarks,
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
