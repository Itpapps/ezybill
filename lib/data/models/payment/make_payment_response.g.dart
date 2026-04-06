// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'make_payment_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MakePaymentResponse _$MakePaymentResponseFromJson(Map<String, dynamic> json) =>
    _MakePaymentResponse(
      statusCode: (json['status_code'] as num?)?.toInt() ?? 0,
      statusMsg: json['status_msg'] as String? ?? '',
      receiptNumber: json['receipt_number'] as String? ?? '',
      voucherCode: json['voucherCode'] as String?,
      paymentRecords: (json['payment_records'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$MakePaymentResponseToJson(
  _MakePaymentResponse instance,
) => <String, dynamic>{
  'status_code': instance.statusCode,
  'status_msg': instance.statusMsg,
  'receipt_number': instance.receiptNumber,
  'voucherCode': instance.voucherCode,
  'payment_records': instance.paymentRecords,
};
