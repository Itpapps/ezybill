import 'package:freezed_annotation/freezed_annotation.dart';

part 'stb_replacement_request.freezed.dart';
part 'stb_replacement_request.g.dart';

@freezed
sealed class StbReplacementRequest with _$StbReplacementRequest {
  const factory StbReplacementRequest({
    @JsonKey(name: 'customerId') required String customerId,
    @JsonKey(name: 'serialNumber') required String serialNumber,
    @JsonKey(name: 'accountNumber') required String accountNumber,
    @JsonKey(name: 'replacementTypeId') required int replacementTypeId,
    @JsonKey(name: 'amount') required double amount,
    @JsonKey(name: 'receiptNumber') required String receiptNumber,
    @JsonKey(name: 'remarks') required String remarks,
    @JsonKey(name: 'replaceSerialNumber') required String replaceSerialNumber,
    @JsonKey(name: 'replaceVcNumber') required String replaceVcNumber,
    @JsonKey(name: 'isPermanentSurrender') required int isPermanentSurrender,
    @JsonKey(name: 'pairCondition') required int pairCondition,
  }) = _StbReplacementRequest;

  factory StbReplacementRequest.fromJson(Map<String, dynamic> json) =>
      _$StbReplacementRequestFromJson(json);
}
