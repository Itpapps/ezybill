import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_mode.freezed.dart';
part 'payment_mode.g.dart';

@freezed
sealed class PaymentMode with _$PaymentMode {
  const factory PaymentMode({
    @JsonKey(name: 'paymentModeId') @Default('') String paymentModeId,
    @JsonKey(name: 'PaymentModeName') @Default('') String paymentModeName,
  }) = _PaymentMode;

  factory PaymentMode.fromJson(Map<String, dynamic> json) =>
      _$PaymentModeFromJson(_sanitize(json));

  static Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
    final r = Map<String, dynamic>.from(json);
    // SOAP _smartConvert turns numeric IDs into int; ensure String for fromJson.
    for (final key in ['paymentModeId', 'PaymentModeName']) {
      if (r[key] is num) r[key] = r[key].toString();
    }
    return r;
  }
}
