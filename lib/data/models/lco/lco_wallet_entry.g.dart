// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lco_wallet_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LcoWalletEntry _$LcoWalletEntryFromJson(Map<String, dynamic> json) =>
    _LcoWalletEntry(
      depositeAmount: (json['deposite_amount'] as num?)?.toDouble() ?? 0.0,
      depositDate: json['Deposit_Date'] as String?,
      businessName: json['business_name'] as String?,
      paymentMode: json['payment_mode'] as String?,
      chequeDdnumber: json['cheque_ddnumber'] as String?,
      bank: json['bank'] as String?,
      branch: json['branch'] as String?,
      instrumentDate: json['instrument_date'] as String?,
      creditAmount: (json['credit_amount'] as num?)?.toDouble() ?? 0.0,
      debitAmount: (json['debit_amount'] as num?)?.toDouble() ?? 0.0,
      transactionNo: json['transaction_no'] as String?,
      receiptNo: json['receipt_no'] as String?,
      remarks: json['Remarks'] as String?,
      depositedBy: json['Deposited_By'] as String?,
    );

Map<String, dynamic> _$LcoWalletEntryToJson(_LcoWalletEntry instance) =>
    <String, dynamic>{
      'deposite_amount': instance.depositeAmount,
      'Deposit_Date': instance.depositDate,
      'business_name': instance.businessName,
      'payment_mode': instance.paymentMode,
      'cheque_ddnumber': instance.chequeDdnumber,
      'bank': instance.bank,
      'branch': instance.branch,
      'instrument_date': instance.instrumentDate,
      'credit_amount': instance.creditAmount,
      'debit_amount': instance.debitAmount,
      'transaction_no': instance.transactionNo,
      'receipt_no': instance.receiptNo,
      'Remarks': instance.remarks,
      'Deposited_By': instance.depositedBy,
    };
