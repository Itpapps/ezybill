// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'id_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IdType _$IdTypeFromJson(Map<String, dynamic> json) => _IdType(
  id: (json['id_type_id'] as num?)?.toInt() ?? 0,
  name: json['type'] as String? ?? '',
);

Map<String, dynamic> _$IdTypeToJson(_IdType instance) => <String, dynamic>{
  'id_type_id': instance.id,
  'type': instance.name,
};
