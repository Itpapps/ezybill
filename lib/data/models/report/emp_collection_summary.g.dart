// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emp_collection_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EmpCollectionSummary _$EmpCollectionSummaryFromJson(
  Map<String, dynamic> json,
) => _EmpCollectionSummary(
  employeeId: json['employee_id'] as String? ?? '',
  name: json['name'] as String? ?? '',
  amt: (json['Amt'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$EmpCollectionSummaryToJson(
  _EmpCollectionSummary instance,
) => <String, dynamic>{
  'employee_id': instance.employeeId,
  'name': instance.name,
  'Amt': instance.amt,
};
