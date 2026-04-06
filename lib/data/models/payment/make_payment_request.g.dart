// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'make_payment_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MakePaymentRequest _$MakePaymentRequestFromJson(Map<String, dynamic> json) =>
    _MakePaymentRequest(
      altCustomerId: json['altCustomerId'] as String,
      amount: (json['amount'] as num).toDouble(),
      modeType: json['modeType'] as String,
      receiptNumber: json['receiptNumber'] as String?,
      altReceiptNumber: json['altReceiptNumber'] as String?,
      remarks: json['remarks'] as String?,
      billingId: json['billingId'] as String?,
      chequeNo: json['chequeNo'] as String?,
      bank: json['bank'] as String?,
      branch: json['branch'] as String?,
      chequeDate: json['chequeDate'] as String?,
      rrnNo: json['rrnNo'] as String?,
      cardholderName: json['cardholderName'] as String?,
      cardType: json['cardType'] as String?,
      voucherCode: json['voucherCode'] as String?,
      imei: json['imei'] as String?,
    );

Map<String, dynamic> _$MakePaymentRequestToJson(_MakePaymentRequest instance) =>
    <String, dynamic>{
      'altCustomerId': instance.altCustomerId,
      'amount': instance.amount,
      'modeType': instance.modeType,
      'receiptNumber': instance.receiptNumber,
      'altReceiptNumber': instance.altReceiptNumber,
      'remarks': instance.remarks,
      'billingId': instance.billingId,
      'chequeNo': instance.chequeNo,
      'bank': instance.bank,
      'branch': instance.branch,
      'chequeDate': instance.chequeDate,
      'rrnNo': instance.rrnNo,
      'cardholderName': instance.cardholderName,
      'cardType': instance.cardType,
      'voucherCode': instance.voucherCode,
      'imei': instance.imei,
    };
