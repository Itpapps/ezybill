import 'package:freezed_annotation/freezed_annotation.dart';

part 'emp_collection_detail.freezed.dart';
part 'emp_collection_detail.g.dart';

@freezed
sealed class EmpCollectionDetail with _$EmpCollectionDetail {
  const factory EmpCollectionDetail({
    @JsonKey(name: 'customerId') @Default('') String customerId,
    @JsonKey(name: 'customerName') @Default('') String customerName,
    @JsonKey(name: 'paidAmount') @Default(0.0) double paidAmount,
    @JsonKey(name: 'paidOn') @Default('') String paidOn,
    @JsonKey(name: 'paymentMode') @Default('') String paymentMode,
    @JsonKey(name: 'paymentId') @Default('') String paymentId,
  }) = _EmpCollectionDetail;

  factory EmpCollectionDetail.fromJson(Map<String, dynamic> json) =>
      _$EmpCollectionDetailFromJson(_sanitize(json));
}

Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
  final r = Map<String, dynamic>.from(json);
  const doubleFields = ['paidAmount'];
  for (final key in doubleFields) {
    final v = r[key];
    if (v is String) {
      r[key] = double.tryParse(v) ?? 0.0;
    } else if (v is int) {
      r[key] = v.toDouble();
    } else if (v == null) {
      r[key] = null;
    }
  }
  // Ensure String fields handle non-string values
  for (final key in ['customerId', 'customerName', 'paidOn', 'paymentMode', 'paymentId']) {
    if (r[key] != null && r[key] is! String) {
      r[key] = r[key].toString();
    }
  }
  return r;
}
