// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Country _$CountryFromJson(Map<String, dynamic> json) => _Country(
  iso: json['iso'] as String? ?? '',
  name: json['name'] as String? ?? '',
  numcode: (json['numcode'] as num?)?.toInt(),
);

Map<String, dynamic> _$CountryToJson(_Country instance) => <String, dynamic>{
  'iso': instance.iso,
  'name': instance.name,
  'numcode': instance.numcode,
};
