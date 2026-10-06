import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';

/// Static key the gateway/result endpoints expect on the V1 (selfcare) path.
/// The native app hardcodes it (PaymentResponseActivity.java:97, :303).
const String _kGatewayAuthKey = 'abcd1234abcd';

/// Native Volley policy for the transaction-response call:
/// DefaultRetryPolicy(100000, 1, 1.0f) (PaymentResponseActivity.java:112-115).
const Duration _kTransactionResponseTimeout = Duration(milliseconds: 100000);

class PaymentRemoteDatasource {
  final DioClient _dio;

  PaymentRemoteDatasource({required DioClient dio}) : _dio = dio;

  /// Get pending amount for a customer
  /// Server: getPendingAmountRest_post
  /// Payload: altCustomerId (required), serial_no (optional for box-wise)
  Future<Map<String, dynamic>> getPendingAmount({
    required String authtoken,
    required String altCustomerId,
    String? serialNo,
  }) async {
    final response = await _dio.post(
      ApiConstants.pendingAmount,
      data: {
        'authtoken': authtoken,
        'altCustomerId': altCustomerId,
        if (serialNo != null) 'serial_no': serialNo,
      },
    );

    final data = response.data as Map<String, dynamic>;
    if (data['status_code'] == 0) {
      return data;
    }
    throw ApiException(
      message: data['status_msg']?.toString() ?? 'Failed to get pending amount',
    );
  }

  /// Get available payment modes
  /// Server: getPaymentModesRest_post
  Future<Map<String, dynamic>> getPaymentModes({
    required String authtoken,
  }) async {
    final response = await _dio.post(
      ApiConstants.paymentModes,
      data: {
        'authtoken': authtoken,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Make a payment
  /// Server: makePaymentsRest_post
  Future<Map<String, dynamic>> makePayment({
    required String authtoken,
    required String altCustomerId,
    required String amount,
    required String modeType,
    String? imei,
    String? receiptNumber,
    String? altReceiptNumber,
    String? remarks,
    String? billingId,
    String? chequeNo,
    String? bank,
    String? branch,
    String? chequeDate,
    String? rrnNo,
    String? cardholderName,
    String? cardType,
    String? voucherCode,
  }) async {
    final response = await _dio.post(
      ApiConstants.makePayment,
      data: {
        'authtoken': authtoken,
        'altCustomerId': altCustomerId,
        'amount': amount,
        'modeType': modeType,
        if (imei != null) 'imei': imei,
        if (receiptNumber != null) 'receipt_number': receiptNumber,
        if (altReceiptNumber != null) 'altReceiptNumber': altReceiptNumber,
        if (remarks != null) 'remarks': remarks,
        if (billingId != null) 'billingId': billingId,
        if (chequeNo != null) 'chequeNo': chequeNo,
        if (bank != null) 'bank': bank,
        if (branch != null) 'branch': branch,
        if (chequeDate != null) 'chequeDate': chequeDate,
        if (rrnNo != null) 'rrnNo': rrnNo,
        if (cardholderName != null) 'cardholderName': cardholderName,
        if (cardType != null) 'cardType': cardType,
        if (voucherCode != null) 'voucherCode': voucherCode,
      },
    );

    final data = response.data as Map<String, dynamic>;
    if (data['status_code'] == 0) {
      return data;
    }
    throw ApiException(
      message: data['status_msg']?.toString() ?? 'Payment failed',
    );
  }

  /// Get receipt ranges
  /// Server: getReceiptRanges_post
  Future<Map<String, dynamic>> getReceiptRanges({
    required String authtoken,
  }) async {
    final response = await _dio.post(
      ApiConstants.receiptRanges,
      data: {
        'authtoken': authtoken,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get bill details
  /// Server: getbilldetailsRest_post
  Future<Map<String, dynamic>> getBillDetails({
    required String authtoken,
    required String serialNumber,
    required String packageId,
    required String customerId,
    int? billType,
    int? employeeId,
  }) async {
    final response = await _dio.post(
      ApiConstants.billDetails,
      data: {
        'authtoken': authtoken,
        'serial_number': serialNumber,
        'package_id': packageId,
        'customer_id': customerId,
        if (billType != null) 'bill_type': billType,
        if (employeeId != null) 'employee_id': employeeId,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get PG transaction logs
  /// Server: pgTransactionLogs_post
  Future<Map<String, dynamic>> getPgTransactionLogs({
    required String authtoken,
    required int dealerId,
    String paymentStatus = '-1',
  }) async {
    final response = await _dio.post(
      ApiConstants.pgTransactionLogs,
      data: {
        'authtoken': authtoken,
        'dealer_id': dealerId.toString(),
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get payment history
  /// Server: PaymentServiceRest_post
  Future<Map<String, dynamic>> getPaymentHistory({
    required String authtoken,
    required String customerId,
    required int dealerId,
    String? fromDate,
    String? toDate,
  }) async {
    final response = await _dio.post(
      ApiConstants.paymentHistory,
      data: {
        'authtoken': authtoken,
        'customer_id': customerId,
        'dealer_id': dealerId,
        if (fromDate != null) 'fromDate': fromDate,
        if (toDate != null) 'toDate': toDate,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get invoice history for a customer
  /// Server: InvoiceServiceRest_post
  Future<Map<String, dynamic>> getInvoiceHistory({
    required String authtoken,
    required String customerId,
    required int dealerId,
  }) async {
    final response = await _dio.post(
      ApiConstants.invoiceHistory,
      data: {
        'authtoken': authtoken,
        'customer_id': customerId,
        'dealer_id': dealerId,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get customer transaction response (PG outcome).
  ///
  /// Mirrors the native PaymentResponseActivity, which picks the endpoint by
  /// the BMS-supplied version (PaymentResponseActivity.java:77-82):
  ///  * V1 (login_url still ends in /wsController) → plain JSON POST to
  ///    `<base>/selfcare_rest_mobileapp/customer_transaction_reponse`
  ///    (configg.properties:56), params employee_id, dealer_id,
  ///    customer_id="0", auth_key="abcd1234abcd" (:293-306).
  ///  * V2 → encrypted {payload,hash} POST to
  ///    `/LcoRestServices/customer_transaction_reponseRest` with the Bearer
  ///    header (configg.properties:133, :87-116).
  ///
  /// Without the V1 branch the generic routing would wrap this call into a
  /// wsController SOAP envelope, which the native app never does.
  ///
  /// Timeout/retry follow the native Volley policy for this screen:
  /// DefaultRetryPolicy(100000, 1, 1.0f) — 100 s, one transport retry.
  Future<Map<String, dynamic>> getCustomerTransactionResponse({
    required String authtoken,
    required String employeeId,
    required int dealerId,
    required String customerId,
  }) async {
    final isV1 = ApiConstants.isWsController;
    final options = Options(
      receiveTimeout: _kTransactionResponseTimeout,
      sendTimeout: _kTransactionResponseTimeout,
      extra: isV1
          // Bypasses the SOAP routing: the native V1 call is plain REST on a
          // different controller.
          ? {'customBaseUrl': ApiConstants.selfcareBase}
          : null,
    );
    final path = isV1
        ? '/customer_transaction_reponse'
        : ApiConstants.customerTransaction;
    final data = isV1
        ? {
            'employee_id': employeeId,
            'dealer_id': dealerId.toString(),
            'customer_id': customerId.isEmpty ? '0' : customerId,
            'auth_key': _kGatewayAuthKey,
          }
        : {
            'authtoken': authtoken,
            'employee_id': employeeId,
            'dealer_id': dealerId.toString(),
            'customer_id': customerId,
          };

    Future<Response<dynamic>> send() =>
        _dio.post(path, data: data, options: options);

    Response<dynamic> response;
    try {
      response = await send();
    } on DioException catch (e) {
      // One automatic retry on transport failure only — the native policy's
      // maxNumRetries = 1. A server reply (badResponse) is not retried.
      if (!_isTransportFailure(e)) rethrow;
      response = await send();
    }
    return response.data as Map<String, dynamic>;
  }

  static bool _isTransportFailure(DioException e) =>
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.connectionError;
}
