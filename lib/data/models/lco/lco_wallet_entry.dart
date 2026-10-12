import 'package:freezed_annotation/freezed_annotation.dart';

part 'lco_wallet_entry.freezed.dart';
part 'lco_wallet_entry.g.dart';

/// One row of `getLcoWalletReport`. JSON keys are the server's own column
/// names (mixed case included) — the ones native reads in
/// Report_EmpCollect_Fragment.java:291-304 (LcoRestServices.php:8036).
@freezed
sealed class LcoWalletEntry with _$LcoWalletEntry {
  const factory LcoWalletEntry({
    @JsonKey(name: 'deposite_amount') @Default(0.0) double depositeAmount,
    @JsonKey(name: 'Deposit_Date') String? depositDate,
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
    @JsonKey(name: 'Remarks') String? remarks,
    @JsonKey(name: 'Deposited_By') String? depositedBy,
  }) = _LcoWalletEntry;

  factory LcoWalletEntry.fromJson(Map<String, dynamic> json) =>
      _$LcoWalletEntryFromJson(_sanitize(json));

  static Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
    final r = Map<String, dynamic>.from(json);
    // Raw JSON keys — this runs before fromJson maps them to fields.
    const doubleFields = ['deposite_amount', 'credit_amount', 'debit_amount'];
    for (final key in doubleFields) {
      final v = r[key];
      if (v is String) r[key] = double.tryParse(v) ?? 0.0;
      if (v == null) r[key] = 0.0;
    }
    // Native reads every other column with getString(), which accepts any
    // JSON scalar; mirror that so one numeric column cannot fail the list.
    for (final e in json.entries) {
      final v = e.value;
      if (!doubleFields.contains(e.key) && v != null && v is! String) {
        r[e.key] = v.toString();
      }
    }
    return r;
  }
}
