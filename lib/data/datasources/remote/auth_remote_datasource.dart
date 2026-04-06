import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';

class AuthRemoteDatasource {
  final DioClient _dio;

  AuthRemoteDatasource({required DioClient dio}) : _dio = dio;

  /// Login - POST /LcoRestServices/validateLogin
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
    String? mobileNo,
    String? imei,
  }) async {
    final response = await _dio.post(
      ApiConstants.validateLogin,
      data: {
        'UserName': username,
        'PassWord': password,
        if (mobileNo != null) 'mobile_no': mobileNo,
        if (imei != null) 'imei': imei,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final statusCode = data['status_code'];

    if (statusCode == 1 || data['token'] != null) {
      return data;
    } else {
      throw ApiException(
        message: data['status_msg']?.toString() ?? 'Login failed',
        statusCode: statusCode is int ? statusCode : 0,
      );
    }
  }

  /// Get Access Control - POST /LcoRestServices/getaccesscontrollRest
  Future<Map<String, dynamic>> getAccessControl({
    required String authtoken,
    required int dealerId,
    required String usersType,
    required String employeeParentType,
    required String employeeParentId,
  }) async {
    final response = await _dio.post(
      ApiConstants.getAccessControl,
      data: {
        'authtoken': authtoken,
        'dealer_id': dealerId.toString(),
        'userstype': usersType,
        'employeeParentType': employeeParentType,
        'employeeParentId': employeeParentId,
      },
    );

    return response.data as Map<String, dynamic>;
  }
}
