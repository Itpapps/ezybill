import 'package:freezed_annotation/freezed_annotation.dart';

part 'close_complaint_request.freezed.dart';
part 'close_complaint_request.g.dart';

@freezed
sealed class CloseComplaintRequest with _$CloseComplaintRequest {
  const factory CloseComplaintRequest({
    @JsonKey(name: 'complaintId') required String complaintId,
    @JsonKey(name: 'ticketNumber') String? ticketNumber,
    @JsonKey(name: 'status') required String status,
    @JsonKey(name: 'comment') String? comment,
    @JsonKey(name: 'assignedemp') String? assignedemp,
    @JsonKey(name: 'closer_ticket_type_id') String? closerTicketTypeId,
    @JsonKey(name: 'closer_reason_id') String? closerReasonId,
  }) = _CloseComplaintRequest;

  factory CloseComplaintRequest.fromJson(Map<String, dynamic> json) =>
      _$CloseComplaintRequestFromJson(json);
}
