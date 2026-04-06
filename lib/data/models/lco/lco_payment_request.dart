import 'package:freezed_annotation/freezed_annotation.dart';

part 'lco_payment_request.freezed.dart';
part 'lco_payment_request.g.dart';

@freezed
sealed class LcoPaymentRequest with _$LcoPaymentRequest {
  const factory LcoPaymentRequest({
    @JsonKey(name: 'authToken') @Default('') String authToken,
    @JsonKey(name: 'lcoEmployeeId') @Default('') String lcoEmployeeId,
    @JsonKey(name: 'lcoBillingId') @Default('') String lcoBillingId,
    @JsonKey(name: 'receiptNumber') @Default('') String receiptNumber,
    @JsonKey(name: 'amount') @Default(0.0) double amount,
    @JsonKey(name: 'mode') @Default('') String mode,
    @JsonKey(name: 'adjustFlag') @Default(0) int adjustFlag,
    @JsonKey(name: 'dabitCredit') @Default('') String dabitCredit,
    @JsonKey(name: 'accept') @Default(0) int accept,
    @JsonKey(name: 'chequeDdnumber') String? chequeDdnumber,
    @JsonKey(name: 'chequeDate') String? chequeDate,
    @JsonKey(name: 'bank') String? bank,
    @JsonKey(name: 'branch') String? branch,
    @JsonKey(name: 'remarks') String? remarks,
  }) = _LcoPaymentRequest;

  factory LcoPaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$LcoPaymentRequestFromJson(_sanitize(json));

  static Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
    final r = Map<String, dynamic>.from(json);
    const doubleFields = ['amount'];
    const intFields = ['adjustFlag', 'accept'];
    for (final key in doubleFields) {
      final v = r[key];
      if (v is String) r[key] = double.tryParse(v) ?? 0.0;
      if (v == null) r[key] = 0.0;
    }
    for (final key in intFields) {
      final v = r[key];
      if (v is String) r[key] = int.tryParse(v) ?? 0;
      if (v == null) r[key] = 0;
    }
    return r;
  }
}
