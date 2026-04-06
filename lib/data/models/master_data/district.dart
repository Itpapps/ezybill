import 'package:freezed_annotation/freezed_annotation.dart';

part 'district.freezed.dart';
part 'district.g.dart';

@freezed
sealed class District with _$District {
  const factory District({
    @JsonKey(name: 'district_id') @Default(0) int id,
    @JsonKey(name: 'district_name') @Default('') String name,
    @JsonKey(name: 'iso') String? iso,
    @JsonKey(name: 'state_id') @Default(0) int stateId,
  }) = _District;

  factory District.fromJson(Map<String, dynamic> json) =>
      _$DistrictFromJson(_sanitize(json));
}

Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
  final r = Map<String, dynamic>.from(json);
  const intFields = ['district_id', 'state_id'];
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
