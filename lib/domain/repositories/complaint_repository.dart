import 'package:ezybill/core/utils/result.dart';
import 'package:ezybill/data/models/complaint/complaint_category.dart';
import 'package:ezybill/data/models/complaint/complaint_subcategory.dart';

/// Abstract interface for complaint data operations.
abstract class ComplaintRepository {
  /// Get open complaints list.
  Future<Result<Map<String, dynamic>>> getComplaintList({
    int serviceEmployeeId = 0,
    String loginUsersType = 'RESELLER',
  });

  /// Get all complaints including closed.
  Future<Result<Map<String, dynamic>>> getTotalComplaintsList({
    int serviceEmployeeId = 0,
    String loginUsersType = 'RESELLER',
  });

  /// Get complaints for a specific customer.
  Future<Result<Map<String, dynamic>>> getCustomerComplaintList({
    required String customerId,
  });

  /// Get complaint categories.
  Future<Result<List<ComplaintCategory>>> getComplaintCategories();

  /// Get complaint sub-categories for a given category.
  Future<Result<List<ComplaintSubcategory>>> getComplaintSubCategories({
    required String categoryId,
  });

  /// Get complaint types/statuses.
  Future<Result<List<Map<String, dynamic>>>> getComplaintTypes();

  /// Create a new complaint.
  Future<Result<Map<String, dynamic>>> createComplaint({
    required String customerId,
    required String complaint,
    required int category,
    String? error,
    int? assignedTo,
  });

  /// Close a complaint.
  Future<Result<Map<String, dynamic>>> closeComplaint({
    required String complaintId,
    String? remarks,
  });

  /// Get complaint history.
  Future<Result<Map<String, dynamic>>> getComplaintHistory({
    required String complaintId,
  });
}
