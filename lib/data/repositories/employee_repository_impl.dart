import 'package:ezybill/core/network/api_exception.dart';
import 'package:ezybill/core/utils/result.dart';
import 'package:ezybill/data/datasources/remote/employee_remote_datasource.dart';
import 'package:ezybill/domain/repositories/employee_repository.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeRemoteDatasource _remoteDatasource;

  EmployeeRepositoryImpl(this._remoteDatasource);

  @override
  Future<Result<Map<String, dynamic>>> getLcoEmployeeList({
    required int dealerId,
  }) async {
    try {
      final data = await _remoteDatasource.getLcoEmployeeList(
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
  Future<Result<Map<String, dynamic>>> getServiceEmployeeList({
    required int dealerId,
  }) async {
    try {
      final data = await _remoteDatasource.getServiceEmployeeList(
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
