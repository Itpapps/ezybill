// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'close_complaint_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CloseComplaintRequest _$CloseComplaintRequestFromJson(
  Map<String, dynamic> json,
) => _CloseComplaintRequest(
  complaintId: json['complaintId'] as String,
  ticketNumber: json['ticketNumber'] as String?,
  status: json['status'] as String,
  comment: json['comment'] as String?,
  assignedemp: json['assignedemp'] as String?,
  closerTicketTypeId: json['closer_ticket_type_id'] as String?,
  closerReasonId: json['closer_reason_id'] as String?,
);

Map<String, dynamic> _$CloseComplaintRequestToJson(
  _CloseComplaintRequest instance,
) => <String, dynamic>{
  'complaintId': instance.complaintId,
  'ticketNumber': instance.ticketNumber,
  'status': instance.status,
  'comment': instance.comment,
  'assignedemp': instance.assignedemp,
  'closer_ticket_type_id': instance.closerTicketTypeId,
  'closer_reason_id': instance.closerReasonId,
};
