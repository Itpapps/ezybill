import 'package:freezed_annotation/freezed_annotation.dart';

part 'bill_detail.freezed.dart';
part 'bill_detail.g.dart';

@freezed
sealed class BillDetail with _$BillDetail {
  const factory BillDetail({
    @JsonKey(name: 'lcoShare') @Default(0.0) double lcoShare,
    @JsonKey(name: 'msoShare') @Default(0.0) double msoShare,
    @JsonKey(name: 'totalAmount') @Default(0.0) double totalAmount,
    @JsonKey(name: 'ncfDisplayName') String? ncfDisplayName,
    @JsonKey(name: 'ncfTotalAmount') @Default(0.0) double ncfTotalAmount,
    @JsonKey(name: 'encfDisplayName') String? encfDisplayName,
    @JsonKey(name: 'encfTotalAmount') @Default(0.0) double encfTotalAmount,
    @JsonKey(name: 'enumAddOnAfterBase') @Default(0) int enumAddOnAfterBase,
    @JsonKey(name: 'enableProrataDiscount') @Default(0) int enableProrataDiscount,
  }) = _BillDetail;

  factory BillDetail.fromJson(Map<String, dynamic> json) =>
      _$BillDetailFromJson(_sanitize(json));

  /// Normalises both snake_case (server) and camelCase (local) keys,
  /// then coerces string-typed numbers into native Dart types.
  static Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
    final r = Map<String, dynamic>.from(json);

    // The REST response from /getbilldetailsRest returns snake_case keys
    // inside a "basePrice" wrapper object.  Normalise to camelCase so
    // freezed-generated fromJson works.
    void _alias(String snakeKey, String camelKey) {
      if (r.containsKey(snakeKey) && !r.containsKey(camelKey)) {
        r[camelKey] = r[snakeKey];
      }
    }

    _alias('lco_share', 'lcoShare');
    _alias('mso_share', 'msoShare');
    _alias('total_amount', 'totalAmount');
    _alias('ncf_display_name', 'ncfDisplayName');
    _alias('ncf_total_amount', 'ncfTotalAmount');
    _alias('encf_display_name', 'encfDisplayName');
    _alias('encf_total_amount', 'encfTotalAmount');
    _alias('enum_add_on_after_base', 'enumAddOnAfterBase');
    _alias('enable_prorata_discount', 'enableProrataDiscount');
    _alias('ENABLE_PRORATA_DISCOUNT', 'enableProrataDiscount');

    const doubleFields = [
      'lcoShare', 'msoShare', 'totalAmount',
      'ncfTotalAmount', 'encfTotalAmount',
    ];
    const intFields = ['enumAddOnAfterBase', 'enableProrataDiscount'];
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
