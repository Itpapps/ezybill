import 'package:freezed_annotation/freezed_annotation.dart';

part 'id_type.freezed.dart';
part 'id_type.g.dart';

@freezed
sealed class IdType with _$IdType {
  const factory IdType({
    @JsonKey(name: 'id_type_id') @Default(0) int id,
    @JsonKey(name: 'type') @Default('') String name,
  }) = _IdType;

  factory IdType.fromJson(Map<String, dynamic> json) =>
      _$IdTypeFromJson(_sanitize(json));
}

Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
  final r = Map<String, dynamic>.from(json);
  // Server variants: {id, name} and {id_type_id, type}
  if (!r.containsKey('id_type_id') && r['id'] != null) {
    r['id_type_id'] = r['id'];
  }
  if (!r.containsKey('type') && r['name'] != null) {
    r['type'] = r['name'];
  }
  const intFields = ['id_type_id'];
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
