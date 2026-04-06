import 'package:freezed_annotation/freezed_annotation.dart';

part 'receipt_range.freezed.dart';
part 'receipt_range.g.dart';

@freezed
sealed class ReceiptRange with _$ReceiptRange {
  const factory ReceiptRange({
    @JsonKey(name: 'rangeId') required String rangeId,
    @JsonKey(name: 'fromNumber') required String fromNumber,
    @JsonKey(name: 'toNumber') required String toNumber,
    @JsonKey(name: 'currentNumber') required String currentNumber,
  }) = _ReceiptRange;

  factory ReceiptRange.fromJson(Map<String, dynamic> json) =>
      _$ReceiptRangeFromJson(json);
}
