import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';

/// Remote datasource for LCO-specific operations: search, payment, wallet history.
class LcoRemoteDatasource {
  final DioClient _dio;

  LcoRemoteDatasource({required DioClient dio}) : _dio = dio;

  /// Search LCO by code.
  ///
  /// POST to `/getlcoadvanceamountdue` (placeholder — confirm with server team).
  // TODO: Confirm REST endpoint name with server team.
  Future<Map<String, dynamic>> searchLco({
    required String authtoken,
    required int employeeId,
    required String lcoCode,
  }) async {
    final response = await _dio.post(
      _lcoSearchEndpoint,
      data: {
        'authtoken': authtoken,
        'employee_id': employeeId,
        'lco_code': lcoCode,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Make an LCO payment.
  ///
  /// POST to `/lcopaymentfunc` (placeholder — confirm with server team).
  // TODO: Confirm REST endpoint name with server team.
  Future<Map<String, dynamic>> makeLcoPayment({
    required String authtoken,
    required Map<String, dynamic> params,
  }) async {
    final payload = <String, dynamic>{
      'authtoken': authtoken,
      ...params,
    };
    final response = await _dio.post(
      _lcoPaymentEndpoint,
      data: payload,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Fetch LCO wallet history for a date range.
  ///
  /// Uses the existing `/getlcowalletRest` endpoint.
  Future<Map<String, dynamic>> getLcoWalletHistory({
    required String authtoken,
    required int dealerId,
    String? startDate,
    String? endDate,
  }) async {
    final response = await _dio.post(
      ApiConstants.lcoWallet,
      data: {
        'authtoken': authtoken,
        'dealer_id': dealerId,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  // ── Placeholder endpoint paths ────────────────────────────────────────────
  // TODO: Replace with confirmed ApiConstants values once server team confirms.

  static const String _lcoSearchEndpoint = '/getlcoadvanceamountdue';
  static const String _lcoPaymentEndpoint = '/lcopaymentfunc';
}
