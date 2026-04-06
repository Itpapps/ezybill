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
