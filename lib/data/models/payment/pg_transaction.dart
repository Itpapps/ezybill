import 'package:freezed_annotation/freezed_annotation.dart';

part 'pg_transaction.freezed.dart';
part 'pg_transaction.g.dart';

@freezed
sealed class PgTransaction with _$PgTransaction {
  const factory PgTransaction({
    @JsonKey(name: 'transactionId') @Default('') String transactionId,
    @JsonKey(name: 'customerId') @Default('') String customerId,
    @JsonKey(name: 'amount') @Default(0.0) double amount,
    @JsonKey(name: 'status') @Default('') String status,
    @JsonKey(name: 'gateway') @Default('') String gateway,
    @JsonKey(name: 'orderId') @Default('') String orderId,
    @JsonKey(name: 'transactionDate') @Default('') String transactionDate,
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
