// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gender.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Gender _$GenderFromJson(Map<String, dynamic> json) => _Gender(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
);

Map<String, dynamic> _$GenderToJson(_Gender instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};
