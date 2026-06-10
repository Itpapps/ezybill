import 'package:freezed_annotation/freezed_annotation.dart';

part 'city.freezed.dart';
part 'city.g.dart';

@freezed
sealed class City with _$City {
  const factory City({
    @JsonKey(name: 'location_id') @Default(0) int locationId,
    @JsonKey(name: 'location_name') @Default('') String locationName,
    @JsonKey(name: 'state_id') @Default(0) int stateId,
    @JsonKey(name: 'dealer_id') int? dealerId,
    @JsonKey(name: 'location_code') String? locationCode,
  }) = _City;

  factory City.fromJson(Map<String, dynamic> json) =>
      _$CityFromJson(_sanitize(json));
}

Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
  final r = Map<String, dynamic>.from(json);
  // DEBUG: dump ALL raw keys to find correct location_id
  print('[CITY-SANITIZE] RAW KEYS: ${r.keys.toList()}');
  print('[CITY-SANITIZE] RAW VALUES: $r');
  // Server variants: {id/name}, {locationId/locationName}, or district-locations payloads.
  if (!r.containsKey('location_id')) {
    if (r['locationId'] != null) {
      r['location_id'] = r['locationId'];
    } else if (r['location_id_pk'] != null) {
      r['location_id'] = r['location_id_pk'];
    } else if (r['locationid'] != null) {
      r['location_id'] = r['locationid'];
    } else if (r['id'] != null) {
      r['location_id'] = r['id'];
    }
  }
  if (!r.containsKey('location_name')) {
    if (r['locationName'] != null) {
      r['location_name'] = r['locationName'];
    } else if (r['location'] != null) {
      r['location_name'] = r['location'];
    } else if (r['city_name'] != null) {
      r['location_name'] = r['city_name'];
    } else if (r['cityName'] != null) {
      r['location_name'] = r['cityName'];
    } else if (r['name'] != null) {
      r['location_name'] = r['name'];
    }
  }
  if (!r.containsKey('state_id') && r['stateId'] != null) {
    r['state_id'] = r['stateId'];
  } else if (!r.containsKey('state_id') && r['stateid'] != null) {
    r['state_id'] = r['stateid'];
  }
  const intFields = ['location_id', 'state_id', 'dealer_id'];
  for (final key in intFields) {
    final v = r[key];
    if (v is String) {
      r[key] = int.tryParse(v) ?? 0;
    } else if (v == null) {
      r[key] = null;
    }
  }
  return r;
}
