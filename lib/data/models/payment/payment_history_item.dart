import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_history_item.freezed.dart';
part 'payment_history_item.g.dart';

@freezed
sealed class PaymentHistoryItem with _$PaymentHistoryItem {
  const factory PaymentHistoryItem({
    @JsonKey(name: 'paymentId') @Default('') String paymentId,
    @JsonKey(name: 'paidOn') @Default('') String paidOn,
    @JsonKey(name: 'paidAmount') @Default(0.0) double paidAmount,
    @JsonKey(name: 'receiptNo') @Default('') String receiptNo,
    @JsonKey(name: 'paymentMode') @Default('') String paymentMode,
    @JsonKey(name: 'remarks') String? remarks,
    @JsonKey(name: 'employeeName') String? employeeName,
  }) = _PaymentHistoryItem;

  factory PaymentHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$PaymentHistoryItemFromJson(_sanitize(json));

  static Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
    final r = Map<String, dynamic>.from(json);
    const doubleFields = ['paidAmount'];
    for (final key in doubleFields) {
      final v = r[key];
      if (v is String) r[key] = double.tryParse(v) ?? 0.0;
      if (v == null) r[key] = 0.0;
    }
    return r;
  }
}
