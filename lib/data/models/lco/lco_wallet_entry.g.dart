// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lco_wallet_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LcoWalletEntry _$LcoWalletEntryFromJson(Map<String, dynamic> json) =>
    _LcoWalletEntry(
      depositeAmount: (json['depositeAmount'] as num?)?.toDouble() ?? 0.0,
      depositDate: json['depositDate'] as String?,
      businessName: json['businessName'] as String?,
      paymentMode: json['paymentMode'] as String?,
      chequeDdnumber: json['chequeDdnumber'] as String?,
      bank: json['bank'] as String?,
      branch: json['branch'] as String?,
      instrumentDate: json['instrumentDate'] as String?,
      creditAmount: (json['creditAmount'] as num?)?.toDouble() ?? 0.0,
      debitAmount: (json['debitAmount'] as num?)?.toDouble() ?? 0.0,
      transactionNo: json['transactionNo'] as String?,
      receiptNo: json['receiptNo'] as String?,
      remarks: json['remarks'] as String?,
      depositedBy: json['depositedBy'] as String?,
    );

Map<String, dynamic> _$LcoWalletEntryToJson(_LcoWalletEntry instance) =>
    <String, dynamic>{
      'depositeAmount': instance.depositeAmount,
      'depositDate': instance.depositDate,
      'businessName': instance.businessName,
      'paymentMode': instance.paymentMode,
      'chequeDdnumber': instance.chequeDdnumber,
      'bank': instance.bank,
      'branch': instance.branch,
      'instrumentDate': instance.instrumentDate,
      'creditAmount': instance.creditAmount,
      'debitAmount': instance.debitAmount,
      'transactionNo': instance.transactionNo,
      'receiptNo': instance.receiptNo,
      'remarks': instance.remarks,
      'depositedBy': instance.depositedBy,
    };
