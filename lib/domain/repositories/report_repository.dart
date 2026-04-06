import 'package:ezybill/core/utils/result.dart';

/// Abstract interface for report data operations.
abstract class ReportRepository {
  /// Get daily report for a given date and dealer.
  Future<Result<Map<String, dynamic>>> getDailyReport({
    required String reportDate,
    required int dealerId,
  });

  /// Get employee collection report for a date range.
  Future<Result<Map<String, dynamic>>> getEmpCollection({
    required String fromDate,
    required String toDate,
    required int dealerId,
  });

  /// Get employee customer collection details.
  Future<Result<Map<String, dynamic>>> getEmpCustomerCollection({
    required String employeeId,
    required String fromDate,
    required String toDate,
    required int dealerId,
  });

  /// Get invoice history for a customer.
  Future<Result<Map<String, dynamic>>> getInvoiceHistory({
    required String customerId,
    required int dealerId,
  });
}
