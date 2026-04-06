// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lco_payment_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LcoPaymentRequest _$LcoPaymentRequestFromJson(Map<String, dynamic> json) =>
    _LcoPaymentRequest(
      authToken: json['authToken'] as String? ?? '',
      lcoEmployeeId: json['lcoEmployeeId'] as String? ?? '',
      lcoBillingId: json['lcoBillingId'] as String? ?? '',
      receiptNumber: json['receiptNumber'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      mode: json['mode'] as String? ?? '',
      adjustFlag: (json['adjustFlag'] as num?)?.toInt() ?? 0,
      dabitCredit: json['dabitCredit'] as String? ?? '',
      accept: (json['accept'] as num?)?.toInt() ?? 0,
      chequeDdnumber: json['chequeDdnumber'] as String?,
      chequeDate: json['chequeDate'] as String?,
      bank: json['bank'] as String?,
      branch: json['branch'] as String?,
      remarks: json['remarks'] as String?,
    );

Map<String, dynamic> _$LcoPaymentRequestToJson(_LcoPaymentRequest instance) =>
    <String, dynamic>{
      'authToken': instance.authToken,
      'lcoEmployeeId': instance.lcoEmployeeId,
      'lcoBillingId': instance.lcoBillingId,
      'receiptNumber': instance.receiptNumber,
      'amount': instance.amount,
      'mode': instance.mode,
      'adjustFlag': instance.adjustFlag,
      'dabitCredit': instance.dabitCredit,
      'accept': instance.accept,
      'chequeDdnumber': instance.chequeDdnumber,
      'chequeDate': instance.chequeDate,
      'bank': instance.bank,
      'branch': instance.branch,
      'remarks': instance.remarks,
    };
