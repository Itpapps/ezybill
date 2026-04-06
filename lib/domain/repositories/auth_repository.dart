import 'package:ezybill/core/utils/result.dart';
import 'package:ezybill/data/models/auth/access_control_response.dart';
import 'package:ezybill/data/models/auth/login_response.dart';

/// Abstract interface for authentication operations.
///
/// Implementations handle remote API calls and local session persistence.
abstract class AuthRepository {
  /// Authenticate user with username/password.
  /// Returns [LoginResponse] on success with token and user details.
  Future<Result<LoginResponse>> login({
    required String username,
    required String password,
    String? mobileNo,
    String? imei,
  });

  /// Fetch access control flags for the current user session.
  ///
  /// CRITICAL: This endpoint uses inverted status codes:
  ///   status_code 0 = success, status_code 1 = failure.
  Future<Result<AccessControlResponse>> getAccessControl({
    required String authToken,
    required int dealerId,
    required String usersType,
    required String employeeParentType,
    required String employeeParentId,
  });

  /// Clear all local session data and tokens.
  Future<void> logout();

  /// Attempt to restore a previously saved session from local storage.
  /// Returns [LoginResponse] if a valid session exists, or [Failure] otherwise.
  Future<Result<LoginResponse>> restoreSession();
}
