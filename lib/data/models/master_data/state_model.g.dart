// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StateModel _$StateModelFromJson(Map<String, dynamic> json) => _StateModel(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  countryCode: json['country_code'] as String? ?? '',
  abbrev: json['abbrev'] as String?,
);

Map<String, dynamic> _$StateModelToJson(_StateModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'country_code': instance.countryCode,
      'abbrev': instance.abbrev,
    };
