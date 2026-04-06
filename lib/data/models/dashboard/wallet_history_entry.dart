import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet_history_entry.freezed.dart';
part 'wallet_history_entry.g.dart';

/// Represents a single entry from the `paymentresult` array
/// returned by `POST /LcoRestServices/getlcowalletRest`.
@freezed
sealed class WalletHistoryEntry with _$WalletHistoryEntry {
  const factory WalletHistoryEntry({
    @JsonKey(name: 'deposite_amount') @Default(0.0) double depositeAmount,
    @JsonKey(name: 'deposit_date') String? depositDate,
    @JsonKey(name: 'business_name') String? businessName,
    @JsonKey(name: 'payment_mode') String? paymentMode,
    @JsonKey(name: 'cheque_ddnumber') String? chequeDdnumber,
    @JsonKey(name: 'bank') String? bank,
    @JsonKey(name: 'branch') String? branch,
    @JsonKey(name: 'instrument_date') String? instrumentDate,
    @JsonKey(name: 'credit_amount') @Default(0.0) double creditAmount,
    @JsonKey(name: 'debit_amount') @Default(0.0) double debitAmount,
    @JsonKey(name: 'transaction_no') String? transactionNo,
    @JsonKey(name: 'receipt_no') String? receiptNo,
    @JsonKey(name: 'remarks') String? remarks,
    @JsonKey(name: 'deposited_by') String? depositedBy,
  }) = _WalletHistoryEntry;

  factory WalletHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$WalletHistoryEntryFromJson(_sanitize(json));

  static Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
    final r = Map<String, dynamic>.from(json);
    const doubleFields = ['deposite_amount', 'credit_amount', 'debit_amount'];
    for (final key in doubleFields) {
      final v = r[key];
      if (v is String) r[key] = double.tryParse(v) ?? 0.0;
      if (v == null) r[key] = 0.0;
    }
    return r;
  }
}
