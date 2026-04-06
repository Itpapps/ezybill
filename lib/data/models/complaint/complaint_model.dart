import 'package:freezed_annotation/freezed_annotation.dart';

part 'complaint_model.freezed.dart';
part 'complaint_model.g.dart';

@freezed
sealed class ComplaintModel with _$ComplaintModel {
  const factory ComplaintModel({
    @JsonKey(name: 'simple_complaint_id') required String complaintId,
    @JsonKey(name: 'tkt_number') required String ticketNumber,
    @JsonKey(name: 'customer_id') required String customerId,
    @JsonKey(name: 'customer_name') required String customerName,
    @JsonKey(name: 'customer_account_id') String? customerAccountId,
    @JsonKey(name: 'CAF') String? cafNumber,
    @JsonKey(name: 'complaint') required String category,
    @JsonKey(name: 'categoryName') String? categoryName,
    @JsonKey(name: 'subCategory') String? subCategory,
    @JsonKey(name: 'description') required String complaint,
    @JsonKey(name: 'status') required String status,
    @JsonKey(name: 'assigned_employee_id') String? assignedTo,
    @JsonKey(name: 'assigned_name') String? assignedToName,
    @JsonKey(name: 'date') required String createdDate,
    @JsonKey(name: 'closedDate') String? closedDate,
    @JsonKey(name: 'remarks') String? remarks,
  }) = _ComplaintModel;

  factory ComplaintModel.fromJson(Map<String, dynamic> json) =>
      _$ComplaintModelFromJson(json);
}
