// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_mode.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentMode _$PaymentModeFromJson(Map<String, dynamic> json) => _PaymentMode(
  paymentModeId: json['paymentModeId'] as String? ?? '',
  paymentModeName: json['PaymentModeName'] as String? ?? '',
);

Map<String, dynamic> _$PaymentModeToJson(_PaymentMode instance) =>
    <String, dynamic>{
      'paymentModeId': instance.paymentModeId,
      'PaymentModeName': instance.paymentModeName,
    };
