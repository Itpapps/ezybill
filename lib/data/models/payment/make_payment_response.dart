import 'package:freezed_annotation/freezed_annotation.dart';

part 'make_payment_response.freezed.dart';
part 'make_payment_response.g.dart';

@freezed
sealed class MakePaymentResponse with _$MakePaymentResponse {
  const factory MakePaymentResponse({
    @JsonKey(name: 'status_code') @Default(0) int statusCode,
    @JsonKey(name: 'status_msg') @Default('') String statusMsg,
    @JsonKey(name: 'receipt_number') @Default('') String receiptNumber,
    @JsonKey(name: 'voucherCode') String? voucherCode,
    @JsonKey(name: 'payment_records') List<Map<String, dynamic>>? paymentRecords,
  }) = _MakePaymentResponse;

  factory MakePaymentResponse.fromJson(Map<String, dynamic> json) =>
      _$MakePaymentResponseFromJson(_sanitize(json));

  static Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
    final r = Map<String, dynamic>.from(json);
    for (final key in ['status_code', 'statusCode']) {
      if (r[key] is String) r[key] = int.tryParse(r[key] as String) ?? 0;
    }
    if (!r.containsKey('status_code') && r.containsKey('statusCode')) {
      r['status_code'] = r['statusCode'];
    }
    if (!r.containsKey('receipt_number') && r.containsKey('receiptNumber')) {
      r['receipt_number'] = r['receiptNumber'];
    }
    if (!r.containsKey('status_msg') && r.containsKey('statusMsg')) {
      r['status_msg'] = r['statusMsg'];
    }
    if (!r.containsKey('payment_records') && r.containsKey('paymentRecords')) {
      r['payment_records'] = r['paymentRecords'];
    }
    return r;
  }
}
