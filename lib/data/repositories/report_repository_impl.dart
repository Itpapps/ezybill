import 'package:ezybill/core/network/api_exception.dart';
import 'package:ezybill/core/utils/result.dart';
import 'package:ezybill/data/datasources/remote/report_remote_datasource.dart';
import 'package:ezybill/domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDatasource _remoteDatasource;

  ReportRepositoryImpl(this._remoteDatasource);

  @override
  Future<Result<Map<String, dynamic>>> getDailyReport({
    required String reportDate,
    required int dealerId,
  }) async {
    try {
      final data = await _remoteDatasource.getDailyReport(
        reportDate: reportDate,
        dealerId: dealerId,
      );
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getEmpCollection({
    required String fromDate,
    required String toDate,
    required int dealerId,
  }) async {
    try {
      final data = await _remoteDatasource.getEmpCollection(
        fromDate: fromDate,
        toDate: toDate,
        dealerId: dealerId,
      );
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getEmpCustomerCollection({
    required String employeeId,
    required String fromDate,
    required String toDate,
    required int dealerId,
  }) async {
    try {
      // Note: employeeId is accepted by the interface but NOT sent to the
      // server per the API contract.
      final data = await _remoteDatasource.getEmpCustomerCollection(
        fromDate: fromDate,
        toDate: toDate,
        dealerId: dealerId,
      );
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getInvoiceHistory({
    required String customerId,
    required int dealerId,
  }) async {
    try {
      final data = await _remoteDatasource.getInvoiceHistory(
        customerId: customerId,
        dealerId: dealerId,
      );
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
