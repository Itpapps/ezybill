// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_employee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ServiceEmployee _$ServiceEmployeeFromJson(Map<String, dynamic> json) =>
    _ServiceEmployee(
      employeeId: json['employeeId'] as String,
      employeeName: json['employeeName'] as String,
      phone: json['phone'] as String?,
      serviceArea: json['serviceArea'] as String?,
    );

Map<String, dynamic> _$ServiceEmployeeToJson(_ServiceEmployee instance) =>
    <String, dynamic>{
      'employeeId': instance.employeeId,
      'employeeName': instance.employeeName,
      'phone': instance.phone,
      'serviceArea': instance.serviceArea,
    };
