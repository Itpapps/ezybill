import 'package:freezed_annotation/freezed_annotation.dart';

part 'pending_amount.freezed.dart';
part 'pending_amount.g.dart';

@freezed
sealed class PendingAmount with _$PendingAmount {
  const factory PendingAmount({
    @JsonKey(name: 'status_code') @Default(0) int statusCode,
    @JsonKey(name: 'pendingAmount') @Default(0.0) double pendingAmount,
    @JsonKey(name: 'customerName') @Default('') String customerName,
    @JsonKey(name: 'mobileNumber') @Default('') String mobileNumber,
    @JsonKey(name: 'msoShare') @Default(0.0) double msoShare,
    @JsonKey(name: 'lcoShare') @Default(0.0) double lcoShare,
    @JsonKey(name: 'billingId') @Default('') String billingId,
  }) = _PendingAmount;

  factory PendingAmount.fromJson(Map<String, dynamic> json) =>
      _$PendingAmountFromJson(_sanitize(json));

  static Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
    final r = Map<String, dynamic>.from(json);
    for (final key in ['status_code', 'statusCode']) {
      if (r[key] is String) r[key] = int.tryParse(r[key] as String) ?? 0;
    }
    // Also check both key variants
    if (!r.containsKey('status_code') && r.containsKey('statusCode')) {
      r['status_code'] = r['statusCode'];
    }
    for (final key in ['pendingAmount', 'msoShare', 'lcoShare']) {
      final v = r[key];
      if (v is String) r[key] = double.tryParse(v) ?? 0.0;
      if (v == null) r[key] = 0.0;
    }
    // SOAP _smartConvert may turn numeric strings into int/double;
    // ensure String fields stay String to avoid TypeError in generated fromJson.
    for (final key in ['customerName', 'mobileNumber', 'billingId']) {
      if (r[key] is num) r[key] = r[key].toString();
    }
    return r;
  }
}
