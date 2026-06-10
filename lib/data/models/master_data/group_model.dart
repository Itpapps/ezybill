import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_model.freezed.dart';
part 'group_model.g.dart';

@freezed
sealed class GroupModel with _$GroupModel {
  const factory GroupModel({
    @JsonKey(name: 'group_id') @Default(0) int groupId,
    @JsonKey(name: 'group_name') @Default('') String groupName,
  }) = _GroupModel;

  factory GroupModel.fromJson(Map<String, dynamic> json) =>
      _$GroupModelFromJson(_sanitize(json));
}

Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
  final r = Map<String, dynamic>.from(json);
  // Server variants: snake_case, camelCase, or generic id/name payloads.
  if (!r.containsKey('group_id')) {
    if (r['groupId'] != null) {
      r['group_id'] = r['groupId'];
    } else if (r['groupid'] != null) {
      r['group_id'] = r['groupid'];
    } else if (r['id'] != null) {
      r['group_id'] = r['id'];
    }
  }
  if (!r.containsKey('group_name')) {
    if (r['groupName'] != null) {
      r['group_name'] = r['groupName'];
    } else if (r['groupname'] != null) {
      r['group_name'] = r['groupname'];
    } else if (r['name'] != null) {
      r['group_name'] = r['name'];
    }
  }
  const intFields = ['group_id'];
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
