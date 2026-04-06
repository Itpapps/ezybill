// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'district.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_District _$DistrictFromJson(Map<String, dynamic> json) => _District(
  id: (json['district_id'] as num?)?.toInt() ?? 0,
  name: json['district_name'] as String? ?? '',
  iso: json['iso'] as String?,
  stateId: (json['state_id'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$DistrictToJson(_District instance) => <String, dynamic>{
  'district_id': instance.id,
  'district_name': instance.name,
  'iso': instance.iso,
  'state_id': instance.stateId,
};
