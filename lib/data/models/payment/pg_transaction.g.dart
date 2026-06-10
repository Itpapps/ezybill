// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pg_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PgTransaction _$PgTransactionFromJson(Map<String, dynamic> json) =>
    _PgTransaction(
      transactionId: json['transactionno'] as String? ?? '',
      customerId: json['code'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? '',
      gateway: json['displayname'] as String? ?? '',
      orderId: json['transaction_id'] as String? ?? '',
      transactionDate: json['paydate'] as String? ?? '',
    );

Map<String, dynamic> _$PgTransactionToJson(_PgTransaction instance) =>
    <String, dynamic>{
      'transactionno': instance.transactionId,
      'code': instance.customerId,
      'amount': instance.amount,
      'status': instance.status,
      'displayname': instance.gateway,
      'transaction_id': instance.orderId,
      'paydate': instance.transactionDate,
    };
