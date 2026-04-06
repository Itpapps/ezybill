import 'package:freezed_annotation/freezed_annotation.dart';

part 'lco_wallet_entry.freezed.dart';
part 'lco_wallet_entry.g.dart';

@freezed
sealed class LcoWalletEntry with _$LcoWalletEntry {
  const factory LcoWalletEntry({
    @JsonKey(name: 'depositeAmount') @Default(0.0) double depositeAmount,
    @JsonKey(name: 'depositDate') String? depositDate,
    @JsonKey(name: 'businessName') String? businessName,
    @JsonKey(name: 'paymentMode') String? paymentMode,
    @JsonKey(name: 'chequeDdnumber') String? chequeDdnumber,
    @JsonKey(name: 'bank') String? bank,
    @JsonKey(name: 'branch') String? branch,
    @JsonKey(name: 'instrumentDate') String? instrumentDate,
    @JsonKey(name: 'creditAmount') @Default(0.0) double creditAmount,
    @JsonKey(name: 'debitAmount') @Default(0.0) double debitAmount,
    @JsonKey(name: 'transactionNo') String? transactionNo,
    @JsonKey(name: 'receiptNo') String? receiptNo,
    @JsonKey(name: 'remarks') String? remarks,
    @JsonKey(name: 'depositedBy') String? depositedBy,
  }) = _LcoWalletEntry;

  factory LcoWalletEntry.fromJson(Map<String, dynamic> json) =>
      _$LcoWalletEntryFromJson(_sanitize(json));

  static Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
    final r = Map<String, dynamic>.from(json);
    const doubleFields = ['depositeAmount', 'creditAmount', 'debitAmount'];
    for (final key in doubleFields) {
      final v = r[key];
      if (v is String) r[key] = double.tryParse(v) ?? 0.0;
      if (v == null) r[key] = 0.0;
    }
    return r;
  }
}
