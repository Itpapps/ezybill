import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';

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
        'payment_status': paymentStatus,
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

  /// Get customer transaction response (PG outcome)
  /// Server: customer_transaction_reponseRest_post
  Future<Map<String, dynamic>> getCustomerTransactionResponse({
    required String authtoken,
    required String employeeId,
    required int dealerId,
    required String customerId,
  }) async {
    final response = await _dio.post(
      ApiConstants.customerTransaction,
      data: {
        'authtoken': authtoken,
        'employee_id': employeeId,
        'dealer_id': dealerId.toString(),
        'customer_id': customerId,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}
