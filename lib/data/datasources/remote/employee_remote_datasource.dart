import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';

class EmployeeRemoteDatasource {
  final DioClient _dio;

  EmployeeRemoteDatasource({required DioClient dio}) : _dio = dio;

  /// Convenience getter — injects the stored authtoken into every payload.
  String get _authtoken => _dio.authToken ?? '';

  /// Get LCO employee list
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

  /// Get service employee list
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

  /// Get employee GPS track info for the map view.
  Future<Map<String, dynamic>> getEmployeeTrackInfo({
    required String employeeId,
  }) async {
    final response = await _dio.post(
      ApiConstants.employeeTrackInfo,
      data: {
        'authtoken': _authtoken,
        'employee_id': employeeId,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}
