// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_history_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentHistoryItem _$PaymentHistoryItemFromJson(Map<String, dynamic> json) =>
    _PaymentHistoryItem(
      paymentId: json['paymentId'] as String? ?? '',
      paidOn: json['paidOn'] as String? ?? '',
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      receiptNo: json['receiptNo'] as String? ?? '',
      paymentMode: json['paymentMode'] as String? ?? '',
      remarks: json['remarks'] as String?,
      employeeName: json['employeeName'] as String?,
    );

Map<String, dynamic> _$PaymentHistoryItemToJson(_PaymentHistoryItem instance) =>
    <String, dynamic>{
      'paymentId': instance.paymentId,
      'paidOn': instance.paidOn,
      'paidAmount': instance.paidAmount,
      'receiptNo': instance.receiptNo,
      'paymentMode': instance.paymentMode,
      'remarks': instance.remarks,
      'employeeName': instance.employeeName,
    };
