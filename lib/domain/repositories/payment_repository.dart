import 'package:ezybill/core/utils/result.dart';
import 'package:ezybill/data/models/payment/make_payment_response.dart';
import 'package:ezybill/data/models/payment/payment_mode.dart';
import 'package:ezybill/data/models/payment/pending_amount.dart';

/// Abstract interface for payment data operations.
abstract class PaymentRepository {
  /// Get pending amount for a customer (optionally box-wise).
  Future<Result<PendingAmount>> getPendingAmount({
    required String altCustomerId,
    String? serialNo,
  });

  /// Get available payment modes.
  Future<Result<List<PaymentMode>>> getPaymentModes();

  /// Make a payment.
  Future<Result<MakePaymentResponse>> makePayment({
    required String altCustomerId,
    required String amount,
    required String modeType,
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
  });

  /// Get receipt ranges.
  Future<Result<Map<String, dynamic>>> getReceiptRanges();

  /// Get bill details for a specific box/package.
  Future<Result<Map<String, dynamic>>> getBillDetails({
    required String serialNumber,
    required String packageId,
    required String customerId,
    int? billType,
    int? employeeId,
  });

  /// Get payment history for a customer.
  Future<Result<Map<String, dynamic>>> getPaymentHistory({
    required String customerId,
    String? fromDate,
    String? toDate,
  });
}
