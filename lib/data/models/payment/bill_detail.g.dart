// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BillDetail _$BillDetailFromJson(Map<String, dynamic> json) => _BillDetail(
  lcoShare: (json['lcoShare'] as num?)?.toDouble() ?? 0.0,
  msoShare: (json['msoShare'] as num?)?.toDouble() ?? 0.0,
  totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
  ncfDisplayName: json['ncfDisplayName'] as String?,
  ncfTotalAmount: (json['ncfTotalAmount'] as num?)?.toDouble() ?? 0.0,
  encfDisplayName: json['encfDisplayName'] as String?,
  encfTotalAmount: (json['encfTotalAmount'] as num?)?.toDouble() ?? 0.0,
  enumAddOnAfterBase: (json['enumAddOnAfterBase'] as num?)?.toInt() ?? 0,
  enableProrataDiscount: (json['enableProrataDiscount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$BillDetailToJson(_BillDetail instance) =>
    <String, dynamic>{
      'lcoShare': instance.lcoShare,
      'msoShare': instance.msoShare,
      'totalAmount': instance.totalAmount,
      'ncfDisplayName': instance.ncfDisplayName,
      'ncfTotalAmount': instance.ncfTotalAmount,
      'encfDisplayName': instance.encfDisplayName,
      'encfTotalAmount': instance.encfTotalAmount,
      'enumAddOnAfterBase': instance.enumAddOnAfterBase,
      'enableProrataDiscount': instance.enableProrataDiscount,
    };
