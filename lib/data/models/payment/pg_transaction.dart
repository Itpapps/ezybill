import 'package:freezed_annotation/freezed_annotation.dart';

part 'pg_transaction.freezed.dart';
part 'pg_transaction.g.dart';

@freezed
sealed class PgTransaction with _$PgTransaction {
  const factory PgTransaction({
    // Server key: 'transactionno' (both V1 customerRestservices and V2 LcoRestServices)
    @JsonKey(name: 'transactionno') @Default('') String transactionId,
    // Server key: 'code' (customer account code in the PG record)
    @JsonKey(name: 'code') @Default('') String customerId,
    @JsonKey(name: 'amount') @Default(0.0) double amount,
    @JsonKey(name: 'status') @Default('') String status,
    // Server key: 'displayname' (payment gateway display name, e.g. "Razorpay")
    @JsonKey(name: 'displayname') @Default('') String gateway,
    // Server key: 'transaction_id' (gateway-assigned external transaction ID)
    @JsonKey(name: 'transaction_id') @Default('') String orderId,
    // Server key: 'paydate' (payment date)
    @JsonKey(name: 'paydate') @Default('') String transactionDate,
  }) = _PgTransaction;

  factory PgTransaction.fromJson(Map<String, dynamic> json) =>
      _$PgTransactionFromJson(_sanitize(json));

  static Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
    final r = Map<String, dynamic>.from(json);
    const doubleFields = ['amount'];
    for (final key in doubleFields) {
      final v = r[key];
      if (v is String) r[key] = double.tryParse(v) ?? 0.0;
      if (v == null) r[key] = 0.0;
    }
    return r;
  }
}
