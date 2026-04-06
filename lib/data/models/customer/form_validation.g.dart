// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'form_validation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FormValidation _$FormValidationFromJson(Map<String, dynamic> json) =>
    _FormValidation(
      columnName: json['column_name'] as String,
      isMandatory: json['is_mandatory'] as String,
    );

Map<String, dynamic> _$FormValidationToJson(_FormValidation instance) =>
    <String, dynamic>{
      'column_name': instance.columnName,
      'is_mandatory': instance.isMandatory,
    };
