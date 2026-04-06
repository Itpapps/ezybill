// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mandal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Mandal _$MandalFromJson(Map<String, dynamic> json) => _Mandal(
  districtId: (json['district_id'] as num?)?.toInt() ?? 0,
  mandalId: (json['mandal_id'] as num?)?.toInt() ?? 0,
  mandalName: json['mandal_name'] as String? ?? '',
);

Map<String, dynamic> _$MandalToJson(_Mandal instance) => <String, dynamic>{
  'district_id': instance.districtId,
  'mandal_id': instance.mandalId,
  'mandal_name': instance.mandalName,
};
