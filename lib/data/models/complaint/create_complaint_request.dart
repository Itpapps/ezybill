import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_complaint_request.freezed.dart';
part 'create_complaint_request.g.dart';

@freezed
sealed class CreateComplaintRequest with _$CreateComplaintRequest {
  const factory CreateComplaintRequest({
    @JsonKey(name: 'customerId') required String customerId,
    @JsonKey(name: 'categoryId') required int categoryId,
    @JsonKey(name: 'subCategoryId') int? subCategoryId,
    @JsonKey(name: 'description') required String description,
    @JsonKey(name: 'assignedEmployeeId') String? assignedEmployeeId,
    @JsonKey(name: 'priority') String? priority,
    @JsonKey(name: 'remarks') String? remarks,
  }) = _CreateComplaintRequest;

  factory CreateComplaintRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateComplaintRequestFromJson(json);
}
