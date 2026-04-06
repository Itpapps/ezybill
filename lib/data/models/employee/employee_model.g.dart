// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EmployeeModel _$EmployeeModelFromJson(Map<String, dynamic> json) =>
    _EmployeeModel(
      employeeId: json['employeeId'] as String,
      employeeName: json['employeeName'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      status: json['status'] as String?,
    );

Map<String, dynamic> _$EmployeeModelToJson(_EmployeeModel instance) =>
    <String, dynamic>{
      'employeeId': instance.employeeId,
      'employeeName': instance.employeeName,
      'phone': instance.phone,
      'email': instance.email,
      'status': instance.status,
    };
