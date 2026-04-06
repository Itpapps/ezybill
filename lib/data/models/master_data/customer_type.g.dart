// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CustomerType _$CustomerTypeFromJson(Map<String, dynamic> json) =>
    _CustomerType(
      customerTypeId: (json['customer_type_id'] as num?)?.toInt() ?? 0,
      customerType: json['customer_type'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: (json['status'] as num?)?.toInt() ?? 0,
      isCommercialMultiBox:
          (json['is_commercial_multi_box'] as num?)?.toInt() ?? 0,
      enableDisplay: (json['enable_display'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$CustomerTypeToJson(_CustomerType instance) =>
    <String, dynamic>{
      'customer_type_id': instance.customerTypeId,
      'customer_type': instance.customerType,
      'description': instance.description,
      'status': instance.status,
      'is_commercial_multi_box': instance.isCommercialMultiBox,
      'enable_display': instance.enableDisplay,
    };
