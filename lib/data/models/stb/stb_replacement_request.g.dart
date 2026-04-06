// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stb_replacement_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StbReplacementRequest _$StbReplacementRequestFromJson(
  Map<String, dynamic> json,
) => _StbReplacementRequest(
  customerId: json['customerId'] as String,
  serialNumber: json['serialNumber'] as String,
  accountNumber: json['accountNumber'] as String,
  replacementTypeId: (json['replacementTypeId'] as num).toInt(),
  amount: (json['amount'] as num).toDouble(),
  receiptNumber: json['receiptNumber'] as String,
  remarks: json['remarks'] as String,
  replaceSerialNumber: json['replaceSerialNumber'] as String,
  replaceVcNumber: json['replaceVcNumber'] as String,
  isPermanentSurrender: (json['isPermanentSurrender'] as num).toInt(),
  pairCondition: (json['pairCondition'] as num).toInt(),
);

Map<String, dynamic> _$StbReplacementRequestToJson(
  _StbReplacementRequest instance,
) => <String, dynamic>{
  'customerId': instance.customerId,
  'serialNumber': instance.serialNumber,
  'accountNumber': instance.accountNumber,
  'replacementTypeId': instance.replacementTypeId,
  'amount': instance.amount,
  'receiptNumber': instance.receiptNumber,
  'remarks': instance.remarks,
  'replaceSerialNumber': instance.replaceSerialNumber,
  'replaceVcNumber': instance.replaceVcNumber,
  'isPermanentSurrender': instance.isPermanentSurrender,
  'pairCondition': instance.pairCondition,
};
