// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_range.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReceiptRange _$ReceiptRangeFromJson(Map<String, dynamic> json) =>
    _ReceiptRange(
      rangeId: json['rangeId'] as String,
      fromNumber: json['fromNumber'] as String,
      toNumber: json['toNumber'] as String,
      currentNumber: json['currentNumber'] as String,
    );

Map<String, dynamic> _$ReceiptRangeToJson(_ReceiptRange instance) =>
    <String, dynamic>{
      'rangeId': instance.rangeId,
      'fromNumber': instance.fromNumber,
      'toNumber': instance.toNumber,
      'currentNumber': instance.currentNumber,
    };
