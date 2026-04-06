// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WalletResponse _$WalletResponseFromJson(Map<String, dynamic> json) =>
    _WalletResponse(
      statusCode: (json['status_code'] as num?)?.toInt() ?? 0,
      lcoDepositAmount: (json['deposit_amount'] as num?)?.toDouble() ?? 0.0,
      customerCount: (json['customerCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$WalletResponseToJson(_WalletResponse instance) =>
    <String, dynamic>{
      'status_code': instance.statusCode,
      'deposit_amount': instance.lcoDepositAmount,
      'customerCount': instance.customerCount,
    };
