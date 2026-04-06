// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_history_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WalletHistoryEntry _$WalletHistoryEntryFromJson(Map<String, dynamic> json) =>
    _WalletHistoryEntry(
      depositeAmount: (json['deposite_amount'] as num?)?.toDouble() ?? 0.0,
      depositDate: json['deposit_date'] as String?,
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
      remarks: json['remarks'] as String?,
      depositedBy: json['deposited_by'] as String?,
    );

Map<String, dynamic> _$WalletHistoryEntryToJson(_WalletHistoryEntry instance) =>
    <String, dynamic>{
      'deposite_amount': instance.depositeAmount,
      'deposit_date': instance.depositDate,
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
      'remarks': instance.remarks,
      'deposited_by': instance.depositedBy,
    };
