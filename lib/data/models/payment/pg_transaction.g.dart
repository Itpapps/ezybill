// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pg_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PgTransaction _$PgTransactionFromJson(Map<String, dynamic> json) =>
    _PgTransaction(
      transactionId: json['transactionId'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? '',
      gateway: json['gateway'] as String? ?? '',
      orderId: json['orderId'] as String? ?? '',
      transactionDate: json['transactionDate'] as String? ?? '',
    );

Map<String, dynamic> _$PgTransactionToJson(_PgTransaction instance) =>
    <String, dynamic>{
      'transactionId': instance.transactionId,
      'customerId': instance.customerId,
      'amount': instance.amount,
      'status': instance.status,
      'gateway': instance.gateway,
      'orderId': instance.orderId,
      'transactionDate': instance.transactionDate,
    };
