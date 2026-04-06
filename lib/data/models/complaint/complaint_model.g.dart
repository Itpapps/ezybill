// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complaint_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ComplaintModel _$ComplaintModelFromJson(Map<String, dynamic> json) =>
    _ComplaintModel(
      complaintId: json['simple_complaint_id'] as String,
      ticketNumber: json['tkt_number'] as String,
      customerId: json['customer_id'] as String,
      customerName: json['customer_name'] as String,
      customerAccountId: json['customer_account_id'] as String?,
      cafNumber: json['CAF'] as String?,
      category: json['complaint'] as String,
      categoryName: json['categoryName'] as String?,
      subCategory: json['subCategory'] as String?,
      complaint: json['description'] as String,
      status: json['status'] as String,
      assignedTo: json['assigned_employee_id'] as String?,
      assignedToName: json['assigned_name'] as String?,
      createdDate: json['date'] as String,
      closedDate: json['closedDate'] as String?,
      remarks: json['remarks'] as String?,
    );

Map<String, dynamic> _$ComplaintModelToJson(_ComplaintModel instance) =>
    <String, dynamic>{
      'simple_complaint_id': instance.complaintId,
      'tkt_number': instance.ticketNumber,
      'customer_id': instance.customerId,
      'customer_name': instance.customerName,
      'customer_account_id': instance.customerAccountId,
      'CAF': instance.cafNumber,
      'complaint': instance.category,
      'categoryName': instance.categoryName,
      'subCategory': instance.subCategory,
      'description': instance.complaint,
      'status': instance.status,
      'assigned_employee_id': instance.assignedTo,
      'assigned_name': instance.assignedToName,
      'date': instance.createdDate,
      'closedDate': instance.closedDate,
      'remarks': instance.remarks,
    };
