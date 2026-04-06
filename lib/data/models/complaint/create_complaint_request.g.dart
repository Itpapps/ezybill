// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_complaint_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateComplaintRequest _$CreateComplaintRequestFromJson(
  Map<String, dynamic> json,
) => _CreateComplaintRequest(
  customerId: json['customerId'] as String,
  categoryId: (json['categoryId'] as num).toInt(),
  subCategoryId: (json['subCategoryId'] as num?)?.toInt(),
  description: json['description'] as String,
  assignedEmployeeId: json['assignedEmployeeId'] as String?,
  priority: json['priority'] as String?,
  remarks: json['remarks'] as String?,
);

Map<String, dynamic> _$CreateComplaintRequestToJson(
  _CreateComplaintRequest instance,
) => <String, dynamic>{
  'customerId': instance.customerId,
  'categoryId': instance.categoryId,
  'subCategoryId': instance.subCategoryId,
  'description': instance.description,
  'assignedEmployeeId': instance.assignedEmployeeId,
  'priority': instance.priority,
  'remarks': instance.remarks,
};
