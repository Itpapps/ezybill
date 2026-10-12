import 'package:freezed_annotation/freezed_annotation.dart';

part 'emp_collection_detail.freezed.dart';
part 'emp_collection_detail.g.dart';

/// One row of empCustomerCollectionDetailsRest's `collectionList`. JSON keys
/// are the server's snake_case columns — the ones native reads in
/// Reports_Emp_Collection_List_Fragment.java:474-485.
@freezed
sealed class EmpCollectionDetail with _$EmpCollectionDetail {
  const factory EmpCollectionDetail({
    @JsonKey(name: 'customer_id') @Default('') String customerId,
    @JsonKey(name: 'customer_name') @Default('') String customerName,
    @JsonKey(name: 'paid_amount') @Default(0.0) double paidAmount,
    @JsonKey(name: 'paid_on') @Default('') String paidOn,
    @JsonKey(name: 'payment_mode') @Default('') String paymentMode,
    @JsonKey(name: 'payment_id') @Default('') String paymentId,
  }) = _EmpCollectionDetail;

  factory EmpCollectionDetail.fromJson(Map<String, dynamic> json) =>
      _$EmpCollectionDetailFromJson(_sanitize(json));
}

Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
  final r = Map<String, dynamic>.from(json);
  // Raw JSON keys — this runs before fromJson maps them to fields.
  const doubleFields = ['paid_amount'];
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
  for (final key in [
    'customer_id',
    'customer_name',
    'paid_on',
    'payment_mode',
    'payment_id',
  ]) {
    if (r[key] != null && r[key] is! String) {
      r[key] = r[key].toString();
    }
  }
  return r;
}
