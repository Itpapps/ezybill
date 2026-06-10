import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';

class ReportRemoteDatasource {
  final DioClient _dio;

  ReportRemoteDatasource({required DioClient dio}) : _dio = dio;

  /// Get daily report.
  /// Fix: param name is `date` (not `report_date`).
  Future<Map<String, dynamic>> getDailyReport({
    required String reportDate,
    required int dealerId,
  }) async {
    final response = await _dio.post(
      ApiConstants.dailyReport,
      data: {
        'date': reportDate,
        'dealer_id': dealerId,
      },
      options: Options(receiveTimeout: const Duration(seconds: 60)),
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get employee collection report.
  /// Fix: param names are camelCase `fromDate`/`toDate`.
  Future<Map<String, dynamic>> getEmpCollection({
    required String fromDate,
    required String toDate,
    required int dealerId,
  }) async {
    final response = await _dio.post(
      ApiConstants.empCollection,
      data: {
        'fromDate': fromDate,
        'toDate': toDate,
        'dealer_id': dealerId,
      },
      options: Options(receiveTimeout: const Duration(seconds: 60)),
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get employee customer collection details.
  /// Note: employee_id is NOT sent per server contract — the server returns
  /// all customer collections for the dealer/date range.
  Future<Map<String, dynamic>> getEmpCustomerCollection({
    required String fromDate,
    required String toDate,
    required int dealerId,
  }) async {
    final response = await _dio.post(
      ApiConstants.empCustomerCollection,
      data: {
        'fromDate': fromDate,
        'toDate': toDate,
        'dealer_id': dealerId,
      },
      options: Options(receiveTimeout: const Duration(seconds: 60)),
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get invoice history
  Future<Map<String, dynamic>> getInvoiceHistory({
    required String customerId,
    required int dealerId,
  }) async {
    final response = await _dio.post(
      ApiConstants.invoiceHistory,
      data: {
        'customer_id': customerId,
        'dealer_id': dealerId,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}
