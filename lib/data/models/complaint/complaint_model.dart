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
      _$ComplaintModelFromJson(_sanitize(json));

  /// The lists differ in which columns they send: the customer list
  /// (getCustomerComplaintListRest) has no `description`, for one — native
  /// reads only the columns it shows (Complaint_Operations_Fragment.java:
  /// 540-575). Missing required text becomes '' instead of failing the whole
  /// list, and non-string scalars are stringified (server values are strings
  /// by convention, but a number must not break a row).
  static Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
    final r = Map<String, dynamic>.from(json);
    const requiredText = [
      'simple_complaint_id', 'tkt_number', 'customer_id', 'customer_name',
      'complaint', 'description', 'status', 'date',
    ];
    for (final key in requiredText) {
      r[key] ??= '';
    }
    r.updateAll((_, v) => (v == null || v is String) ? v : v.toString());
    return r;
  }
}
