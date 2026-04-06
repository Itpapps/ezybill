// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_amount.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PendingAmount _$PendingAmountFromJson(Map<String, dynamic> json) =>
    _PendingAmount(
      statusCode: (json['status_code'] as num?)?.toInt() ?? 0,
      pendingAmount: (json['pendingAmount'] as num?)?.toDouble() ?? 0.0,
      customerName: json['customerName'] as String? ?? '',
      mobileNumber: json['mobileNumber'] as String? ?? '',
      msoShare: (json['msoShare'] as num?)?.toDouble() ?? 0.0,
      lcoShare: (json['lcoShare'] as num?)?.toDouble() ?? 0.0,
      billingId: json['billingId'] as String? ?? '',
    );

Map<String, dynamic> _$PendingAmountToJson(_PendingAmount instance) =>
    <String, dynamic>{
      'status_code': instance.statusCode,
      'pendingAmount': instance.pendingAmount,
      'customerName': instance.customerName,
      'mobileNumber': instance.mobileNumber,
      'msoShare': instance.msoShare,
      'lcoShare': instance.lcoShare,
      'billingId': instance.billingId,
    };
