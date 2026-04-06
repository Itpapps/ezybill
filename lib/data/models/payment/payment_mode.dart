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
      _$PaymentModeFromJson(json);
}
