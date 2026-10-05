import 'package:ezybill/core/network/api_exception.dart';
import 'package:ezybill/core/utils/result.dart';
import 'package:ezybill/data/datasources/local/auth_local_datasource.dart';
import 'package:ezybill/data/datasources/remote/auth_remote_datasource.dart';
import 'package:ezybill/data/models/auth/access_control_response.dart';
import 'package:ezybill/data/models/auth/login_response.dart';
import 'package:ezybill/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;
  final AuthLocalDatasource _localDatasource;

  AuthRepositoryImpl(this._remoteDatasource, this._localDatasource);

  @override
  Future<Result<LoginResponse>> login({
    required String username,
    required String password,
    String? mobileNo,
    String? imei,
    String? employeeId,
  }) async {
    try {
      final data = await _remoteDatasource.login(
        username: username,
        password: password,
        mobileNo: mobileNo,
        imei: imei,
        employeeId: employeeId,
      );
      final response = LoginResponse.fromJson(data);

      // Per server docs: status_code == 0 means success for validateLogin.
      if (response.statusCode == 0 && response.token.isNotEmpty) {
        // Persist only the profile fields some screens read directly. The
        // token is deliberately NOT written to disk: the active session is
        // held in memory (appSessionProvider / DioClient) and is never
        // restored on a later launch — native Android parity.
        await _localDatasource.saveUserData(
          dealerId: response.dealerId,
          employeeId: response.employeeId,
          userType: response.userType,
          firstName: response.firstName,
          lastName: response.lastName,
          email: response.email,
          phone: response.phone,
          lcoCode: response.lcoCode,
          businessName: response.businessName,
          parentType: response.employeeParentType,
          parentId: response.employeeParentId,
        );
        return Success(response);
      }
      return Failure(response.statusMsg.isNotEmpty
          ? response.statusMsg
          : 'Login failed');
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<AccessControlResponse>> getAccessControl({
    required String authToken,
    required int dealerId,
    required String usersType,
    required String employeeParentType,
    required String employeeParentId,
  }) async {
    try {
      final data = await _remoteDatasource.getAccessControl(
        authtoken: authToken,
        dealerId: dealerId,
        usersType: usersType,
        employeeParentType: employeeParentType,
        employeeParentId: employeeParentId,
      );
      final response = AccessControlResponse.fromJson(data);

      // CRITICAL: Inverted status codes for this endpoint.
      // status_code 0 = success, status_code 1 = failure.
      if (response.statusCode == 0) {
        return Success(response);
      }
      return Failure(
        response.statusMsg.isNotEmpty
            ? response.statusMsg
            : 'Failed to get access control',
      );
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    await _localDatasource.clearAll();
  }
}
