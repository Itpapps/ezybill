// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emp_collection_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EmpCollectionDetail _$EmpCollectionDetailFromJson(Map<String, dynamic> json) =>
    _EmpCollectionDetail(
      customerId: json['customer_id'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? '',
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      paidOn: json['paid_on'] as String? ?? '',
      paymentMode: json['payment_mode'] as String? ?? '',
      paymentId: json['payment_id'] as String? ?? '',
    );

Map<String, dynamic> _$EmpCollectionDetailToJson(
  _EmpCollectionDetail instance,
) => <String, dynamic>{
  'customer_id': instance.customerId,
  'customer_name': instance.customerName,
  'paid_amount': instance.paidAmount,
  'paid_on': instance.paidOn,
  'payment_mode': instance.paymentMode,
  'payment_id': instance.paymentId,
};
