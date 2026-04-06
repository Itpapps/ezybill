import 'package:freezed_annotation/freezed_annotation.dart';

part 'cas_package.freezed.dart';
part 'cas_package.g.dart';

@freezed
sealed class CasPackage with _$CasPackage {
  const factory CasPackage({
    @JsonKey(name: 'product_id') @Default('') String productId,
    @JsonKey(name: 'pname') @Default('') String productName,
    @JsonKey(name: 'pricing_structure_type') @Default('') String pricingStructureType,
    @JsonKey(name: 'price') @Default(0.0) double price,
  }) = _CasPackage;

  factory CasPackage.fromJson(Map<String, dynamic> json) =>
      _$CasPackageFromJson(_sanitize(json));

  static Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
    final r = Map<String, dynamic>.from(json);
    // Handle camelCase variants from server
    if (!r.containsKey('product_id') && r.containsKey('productId')) {
      r['product_id'] = r['productId'];
    }
    if (!r.containsKey('pname') && r.containsKey('productName')) {
      r['pname'] = r['productName'];
    }
    if (!r.containsKey('pricing_structure_type') && r.containsKey('pricingStructureType')) {
      r['pricing_structure_type'] = r['pricingStructureType'];
    }
    // product_id may come as int
    if (r['product_id'] is int) r['product_id'] = r['product_id'].toString();
    if (r['pricing_structure_type'] is int) {
      r['pricing_structure_type'] = r['pricing_structure_type'].toString();
    }
    const doubleFields = ['price'];
    for (final key in doubleFields) {
      final v = r[key];
      if (v is String) r[key] = double.tryParse(v) ?? 0.0;
      if (v == null) r[key] = 0.0;
    }
    return r;
  }
}
