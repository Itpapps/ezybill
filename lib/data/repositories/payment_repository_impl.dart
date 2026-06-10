import 'package:ezybill/core/network/api_exception.dart';
import 'package:ezybill/core/network/dio_client.dart';
import 'package:ezybill/core/utils/result.dart';
import 'package:ezybill/data/datasources/remote/payment_remote_datasource.dart';
import 'package:ezybill/data/models/payment/make_payment_response.dart';
import 'package:ezybill/data/models/payment/payment_mode.dart';
import 'package:ezybill/data/models/payment/pending_amount.dart';
import 'package:ezybill/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDatasource _remoteDatasource;
  final DioClient _dio;

  PaymentRepositoryImpl(this._remoteDatasource, this._dio);

  String get _authtoken => _dio.authToken ?? '';

  @override
  Future<Result<PendingAmount>> getPendingAmount({
    required String altCustomerId,
    String? serialNo,
  }) async {
    try {
      final data = await _remoteDatasource.getPendingAmount(
        authtoken: _authtoken,
        altCustomerId: altCustomerId,
        serialNo: serialNo,
      );
      final response = PendingAmount.fromJson(data);
      return Success(response);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<List<PaymentMode>>> getPaymentModes() async {
    try {
      final data = await _remoteDatasource.getPaymentModes(authtoken: _authtoken);
      final list = (data['paymentModes'] as List? ?? data['data'] as List? ?? [])
          .cast<Map<String, dynamic>>();
      final modes = list.map((e) => PaymentMode.fromJson(e)).toList();
      return Success(modes);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
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
  }) async {
    try {
      final data = await _remoteDatasource.makePayment(
        authtoken: _authtoken,
        altCustomerId: altCustomerId,
        amount: amount,
        modeType: modeType,
        receiptNumber: receiptNumber,
        altReceiptNumber: altReceiptNumber,
        remarks: remarks,
        billingId: billingId,
        chequeNo: chequeNo,
        bank: bank,
        branch: branch,
        chequeDate: chequeDate,
        rrnNo: rrnNo,
        cardholderName: cardholderName,
        cardType: cardType,
        voucherCode: voucherCode,
      );
      final response = MakePaymentResponse.fromJson(data);
      return Success(response);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getReceiptRanges() async {
    try {
      final data = await _remoteDatasource.getReceiptRanges(authtoken: _authtoken);
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getBillDetails({
    required String serialNumber,
    required String packageId,
    required String customerId,
    int? billType,
    int? employeeId,
  }) async {
    try {
      final data = await _remoteDatasource.getBillDetails(
        authtoken: _authtoken,
        serialNumber: serialNumber,
        packageId: packageId,
        customerId: customerId,
        billType: billType,
        employeeId: employeeId,
      );
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getPaymentHistory({
    required String customerId,
    required int dealerId,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final data = await _remoteDatasource.getPaymentHistory(
        authtoken: _authtoken,
        customerId: customerId,
        dealerId: dealerId,
        fromDate: fromDate,
        toDate: toDate,
      );
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
