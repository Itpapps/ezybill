import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_session.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/result.dart';
import '../../data/models/auth/login_response.dart';
import '../../domain/repositories/auth_repository.dart';
import 'core_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Auth State
// ─────────────────────────────────────────────────────────────────────────────

enum AuthStatus { idle, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.idle,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => Object.hash(status, errorMessage);

  @override
  String toString() => 'AuthState(status: $status, error: $errorMessage)';
}

// ─────────────────────────────────────────────────────────────────────────────
// Auth Notifier
// ─────────────────────────────────────────────────────────────────────────────

class AuthNotifier extends Notifier<AuthState> {
  late AuthRepository _authRepository;
  late DioClient _dioClient;

  @override
  AuthState build() {
    _authRepository = ref.watch(authRepositoryProvider);
    _dioClient = ref.watch(dioClientProvider);

    // Attempt session restore on first build (non-blocking).
    _restoreSession();

    return const AuthState();
  }

  // ── Restore Session ──────────────────────────────────────────────────────

  /// Checks local storage for a previously saved session.
  /// If found, rebuilds [AppSession] and transitions to [authenticated].
  /// If not found, transitions to [unauthenticated].
  Future<void> _restoreSession() async {
    final result = await _authRepository.restoreSession();

    switch (result) {
      case Success(data: final loginResponse):
        final rawJson = _loginResponseToRawJson(loginResponse);

        // Build session from persisted login data.
        final session = AppSession.fromLoginResponse(rawJson);

        // Set token on Dio client for subsequent API calls.
        _dioClient.setTokens(
          jwtToken: session.token,
          authToken: session.token,
        );

        // Push session into the global provider.
        ref.read(appSessionProvider.notifier).setSession(session);

        state = const AuthState(status: AuthStatus.authenticated);

      case Failure():
        state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Public entry point for manual session restore (e.g. on app cold start).
  Future<void> restoreSession() async {
    await _restoreSession();
  }

  // ── Login ────────────────────────────────────────────────────────────────

  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    // Read BMS data for SOAP login (live servers need employeeId + imei).
    final prefs = ref.read(sharedPreferencesProvider);
    final bmsEmployeeId = prefs.getString('bms_emp_id') ?? '';
    final deviceImei = prefs.getString('device_uuid') ?? '';

    // Step 1: Call validateLogin via repository.
    final loginResult = await _authRepository.login(
      username: username,
      password: password,
      imei: deviceImei,
      employeeId: bmsEmployeeId,
    );

    switch (loginResult) {
      case Success(data: final loginResponse):
        await _handleLoginSuccess(loginResponse);

      case Failure(message: final message):
        state = AuthState(
          status: AuthStatus.error,
          errorMessage: message,
        );
    }
  }

  /// Processes a successful login response:
  ///  1. Builds AppSession from login data
  ///  2. Sets tokens on DioClient
  ///  3. Fetches access control (non-blocking)
  ///  4. Merges access control into session
  ///  5. Sets appSessionProvider
  ///  6. Transitions to authenticated
  Future<void> _handleLoginSuccess(LoginResponse loginResponse) async {
    final rawJson = _loginResponseToRawJson(loginResponse);

    // Build initial session from login response.
    AppSession session = AppSession.fromLoginResponse(rawJson);

    // Set tokens on Dio client so access-control call can authenticate.
    _dioClient.setTokens(
      jwtToken: session.token,
      authToken: session.token,
    );

    // Step 2: Fetch access control flags (non-blocking — use defaults on failure).
    try {
      final acResult = await _authRepository.getAccessControl(
        authToken: session.token,
        dealerId: session.dealerId,
        usersType: session.userType,
        employeeParentType: session.employeeParentType,
        employeeParentId: session.employeeParentId,
      );

      switch (acResult) {
        case Success(data: final acResponse):
          // Merge access control flags into session.
          session = session.copyWithAccessControl({
            'intBulkPayment': acResponse.intBulkPayment,
            'invoicePageAccess': acResponse.invoicePageAccess,
            'paymentHistPageAccess': acResponse.paymentHistPageAccess,
            'accessForComplaints': acResponse.accessForComplaints,
            'intStbActivation': acResponse.intStbActivation,
            'intStbDeactivation': acResponse.intStbDeactivation,
            'intStbReactivation': acResponse.intStbReactivation,
            'pgtransaction': acResponse.pgtransaction,
          });

        case Failure():
          // Non-blocking: proceed with default access flags (all 1).
          // Session already has sensible defaults from AppSession constructor.
          break;
      }
    } catch (_) {
      // Silently ignore — access control is non-blocking.
    }

    // Step 3: Push final session into global provider.
    ref.read(appSessionProvider.notifier).setSession(session);

    // Step 4: Transition to authenticated — GoRouter redirect handles navigation.
    state = const AuthState(status: AuthStatus.authenticated);
  }

  // ── Logout ───────────────────────────────────────────────────────────────

  Future<void> logout() async {
    // Clear persisted session data.
    await _authRepository.logout();

    // Clear tokens from Dio client.
    _dioClient.setTokens(jwtToken: null, authToken: null);

    // Clear global session.
    ref.read(appSessionProvider.notifier).clear();

    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Converts a [LoginResponse] (freezed model) back to a raw JSON map
  /// suitable for [AppSession.fromLoginResponse].
  ///
  /// AppSession.fromLoginResponse expects the raw server JSON keys (e.g.
  /// `authToken`, `dealerId`, `firstName`, etc.). LoginResponse.toJson()
  /// outputs the `@JsonKey(name:)` keys which are the server-side keys,
  /// so this works directly.
  Map<String, dynamic> _loginResponseToRawJson(LoginResponse response) {
    // LoginResponse uses @JsonKey names that match the server response,
    // so toJson() produces the correct keys for AppSession.fromLoginResponse.
    return {
      'authToken': response.token,
      'dealerId': response.dealerId,
      'employeeId': response.employeeId,
      'userType': response.userType,
      'firstName': response.firstName,
      'lastName': response.lastName,
      'emailId': response.email,
      'phone': response.phone,
      'lcoCode': response.lcoCode,
      'businessName': response.businessName,
      'lcoLocation': response.lcoLocation,
      'employeeParentType': response.employeeParentType,
      'employeeParentId': response.employeeParentId,
      // Config flags
      'useCRF': response.useCRF,
      'useCAF': response.useCAF,
      'useLastName': response.useLastName,
      'useDiscount': response.useDiscount,
      'useDataFromMasterTable': response.useDataFromMasterTable,
      'useMandatoryForHotel': response.useMandatoryForHotel,
      'useAccountNumber': response.useAccountNumber,
      'freezecustomerparamsinapp': response.freezecustomerparamsinapp,
      'blockpayment': response.blockpayment,
      'lco_billtype': response.lcoBilltype,
      'use_lco_deposits': response.useLcoDeposit,
      'customer_billtype': response.customerBilltype,
      'AUTO_RECEIPT_NUMBER': response.autoReceiptNumber,
      'CURRENCY_CODE': response.currencyCode,
      'allowTopUp': response.allowTopUp,
      'showCafMobileValidation': response.showCafMobileValidation,
      'stbPairing': response.stbPairing,
      'stbUnpairing': response.stbUnpairing,
      'showMiaAgreementUpload': response.showMiaAgreementUpload,
      'acceptTermsConditions': response.acceptTermsConditions,
      'agreementDetailsCount': response.agreementDetailsCount,
      'access_distributor_wise': response.accessDistributorWise,
      'is_direct_lco': response.isDirectLco,
      'is_unpaidlco': response.isUnpaidlco,
      'appMenuFormat': response.appMenuFormat,
      'invoicepaymentsearchlimit': response.invoicePaymentSearchLimit,
      'lcoMobileNo': response.lcoMobileNo,
      'patchInformation': response.patchInformation,
      'recurringServiceEdit': response.recurringServiceEdit,
      'showLcoComplaint': response.showLcoComplaint,
      'depositAmount': response.depositAmount,
      'showSerialVc': response.showSerialVc,
      'showServiceExtension': response.showServiceExtension,
      'editQuantity': response.editQuantity,
      'enableBoxWisePayment': response.enableBoxWisePayment,
      'baidLabel': response.baidLabel,
      'defaultCountry': response.defaultCountry,
      'defaultState': response.defaultState,
      'defaultDistrict': response.defaultDistrict,
      'defaultCity': response.defaultCity,
      'appTheme': response.appTheme,
      'appDashboard': response.appDashboard,
      'enableAadhaar': response.enableAadhaar,
      'lcoPaymentFlag': response.lcoPayment,
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
