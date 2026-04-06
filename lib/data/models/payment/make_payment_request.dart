import 'package:freezed_annotation/freezed_annotation.dart';

part 'make_payment_request.freezed.dart';
part 'make_payment_request.g.dart';

@freezed
sealed class MakePaymentRequest with _$MakePaymentRequest {
  const factory MakePaymentRequest({
    @JsonKey(name: 'altCustomerId') required String altCustomerId,
    @JsonKey(name: 'amount') required double amount,
    @JsonKey(name: 'modeType') required String modeType,
    @JsonKey(name: 'receiptNumber') String? receiptNumber,
    @JsonKey(name: 'altReceiptNumber') String? altReceiptNumber,
    @JsonKey(name: 'remarks') String? remarks,
    @JsonKey(name: 'billingId') String? billingId,
    @JsonKey(name: 'chequeNo') String? chequeNo,
    @JsonKey(name: 'bank') String? bank,
    @JsonKey(name: 'branch') String? branch,
    @JsonKey(name: 'chequeDate') String? chequeDate,
    @JsonKey(name: 'rrnNo') String? rrnNo,
    @JsonKey(name: 'cardholderName') String? cardholderName,
    @JsonKey(name: 'cardType') String? cardType,
    @JsonKey(name: 'voucherCode') String? voucherCode,
    @JsonKey(name: 'imei') String? imei,
  }) = _MakePaymentRequest;

  factory MakePaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$MakePaymentRequestFromJson(json);
}
