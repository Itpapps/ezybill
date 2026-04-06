import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet_response.freezed.dart';
part 'wallet_response.g.dart';

@freezed
sealed class WalletResponse with _$WalletResponse {
  const factory WalletResponse({
    @JsonKey(name: 'status_code') @Default(0) int statusCode,
    @JsonKey(name: 'deposit_amount') @Default(0.0) double lcoDepositAmount,
    @JsonKey(name: 'customerCount') @Default(0) int customerCount,
  }) = _WalletResponse;

  factory WalletResponse.fromJson(Map<String, dynamic> json) =>
      _$WalletResponseFromJson(_sanitize(json));

  static Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
    final r = Map<String, dynamic>.from(json);
    // deposit_amount comes as String "0.00" or "-42.48"
    if (r['deposit_amount'] is String) {
      r['deposit_amount'] = double.tryParse(r['deposit_amount'] as String) ?? 0.0;
    }
    if (r['status_code'] is String) {
      r['status_code'] = int.tryParse(r['status_code'] as String) ?? 0;
    }
    if (r['customerCount'] is String) {
      r['customerCount'] = int.tryParse(r['customerCount'] as String) ?? 0;
    }
    return r;
  }
}
