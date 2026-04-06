// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emp_collection_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EmpCollectionDetail _$EmpCollectionDetailFromJson(Map<String, dynamic> json) =>
    _EmpCollectionDetail(
      customerId: json['customerId'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      paidOn: json['paidOn'] as String? ?? '',
      paymentMode: json['paymentMode'] as String? ?? '',
      paymentId: json['paymentId'] as String? ?? '',
    );

Map<String, dynamic> _$EmpCollectionDetailToJson(
  _EmpCollectionDetail instance,
) => <String, dynamic>{
  'customerId': instance.customerId,
  'customerName': instance.customerName,
  'paidAmount': instance.paidAmount,
  'paidOn': instance.paidOn,
  'paymentMode': instance.paymentMode,
  'paymentId': instance.paymentId,
};
