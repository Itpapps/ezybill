// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_City _$CityFromJson(Map<String, dynamic> json) => _City(
  locationId: (json['location_id'] as num?)?.toInt() ?? 0,
  locationName: json['location_name'] as String? ?? '',
  stateId: (json['state_id'] as num?)?.toInt() ?? 0,
  dealerId: (json['dealer_id'] as num?)?.toInt(),
  locationCode: json['location_code'] as String?,
);

Map<String, dynamic> _$CityToJson(_City instance) => <String, dynamic>{
  'location_id': instance.locationId,
  'location_name': instance.locationName,
  'state_id': instance.stateId,
  'dealer_id': instance.dealerId,
  'location_code': instance.locationCode,
};
