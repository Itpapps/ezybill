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
