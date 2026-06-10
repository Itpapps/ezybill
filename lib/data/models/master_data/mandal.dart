import 'package:freezed_annotation/freezed_annotation.dart';

part 'mandal.freezed.dart';
part 'mandal.g.dart';

@freezed
sealed class Mandal with _$Mandal {
  const factory Mandal({
    @JsonKey(name: 'district_id') @Default(0) int districtId,
    @JsonKey(name: 'mandal_id') @Default(0) int mandalId,
    @JsonKey(name: 'mandal_name') @Default('') String mandalName,
  }) = _Mandal;

  factory Mandal.fromJson(Map<String, dynamic> json) =>
      _$MandalFromJson(_sanitize(json));
}

Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
  final r = Map<String, dynamic>.from(json);
  // Server variants: {id, name, districtId} or district/location payloads.
  if (!r.containsKey('mandal_id')) {
    if (r['mandalId'] != null) {
      r['mandal_id'] = r['mandalId'];
    } else if (r['mandalid'] != null) {
      r['mandal_id'] = r['mandalid'];
    } else if (r['location_id'] != null) {
      r['mandal_id'] = r['location_id'];
    } else if (r['locationId'] != null) {
      r['mandal_id'] = r['locationId'];
    } else if (r['id'] != null) {
      r['mandal_id'] = r['id'];
    }
  }
  if (!r.containsKey('mandal_name')) {
    if (r['mandalName'] != null) {
      r['mandal_name'] = r['mandalName'];
    } else if (r['mandal'] != null) {
      r['mandal_name'] = r['mandal'];
    } else if (r['location_name'] != null) {
      r['mandal_name'] = r['location_name'];
    } else if (r['locationName'] != null) {
      r['mandal_name'] = r['locationName'];
    } else if (r['name'] != null) {
      r['mandal_name'] = r['name'];
    }
  }
  if (!r.containsKey('district_id') && r['districtId'] != null) {
    r['district_id'] = r['districtId'];
  } else if (!r.containsKey('district_id') && r['districtid'] != null) {
    r['district_id'] = r['districtid'];
  }
  const intFields = ['district_id', 'mandal_id'];
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
