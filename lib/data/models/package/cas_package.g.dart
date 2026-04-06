// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cas_package.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CasPackage _$CasPackageFromJson(Map<String, dynamic> json) => _CasPackage(
  productId: json['product_id'] as String? ?? '',
  productName: json['pname'] as String? ?? '',
  pricingStructureType: json['pricing_structure_type'] as String? ?? '',
  price: (json['price'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$CasPackageToJson(_CasPackage instance) =>
    <String, dynamic>{
      'product_id': instance.productId,
      'pname': instance.productName,
      'pricing_structure_type': instance.pricingStructureType,
      'price': instance.price,
    };
