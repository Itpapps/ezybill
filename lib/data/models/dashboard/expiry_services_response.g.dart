// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expiry_services_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExpiryServicesResponse _$ExpiryServicesResponseFromJson(
  Map<String, dynamic> json,
) => _ExpiryServicesResponse(
  statusCode: (json['status_code'] as num?)?.toInt() ?? 0,
  statusMsg: json['status_msg'] as String? ?? '',
  expiryServicesList:
      (json['getExpiryServicesList'] as List<dynamic>?)
          ?.map((e) => ExpiryDateCount.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ExpiryServicesResponseToJson(
  _ExpiryServicesResponse instance,
) => <String, dynamic>{
  'status_code': instance.statusCode,
  'status_msg': instance.statusMsg,
  'getExpiryServicesList': instance.expiryServicesList,
};

_ExpiryDateCount _$ExpiryDateCountFromJson(Map<String, dynamic> json) =>
    _ExpiryDateCount(
      date: json['date'] as String? ?? '',
      stbCount: (json['stb_count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ExpiryDateCountToJson(_ExpiryDateCount instance) =>
    <String, dynamic>{'date': instance.date, 'stb_count': instance.stbCount};
