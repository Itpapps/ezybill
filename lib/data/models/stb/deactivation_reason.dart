import 'package:freezed_annotation/freezed_annotation.dart';

part 'deactivation_reason.freezed.dart';
part 'deactivation_reason.g.dart';

@freezed
sealed class DeactivationReason with _$DeactivationReason {
  const factory DeactivationReason({
    @JsonKey(name: 'reasonId') @Default(0) int reasonId,
    @JsonKey(name: 'reasonName') @Default('') String reasonName,
    @JsonKey(name: 'display_name') @Default('') String displayName,
    @JsonKey(name: 'act_deact_reason_id') @Default(0) int actDeactReasonId,
    @JsonKey(name: 'global_reason') @Default(0) int globalReason,
    @JsonKey(name: 'disable_for_dpo') @Default(0) int disableForDpo,
  }) = _DeactivationReason;

  factory DeactivationReason.fromJson(Map<String, dynamic> json) =>
      _$DeactivationReasonFromJson(_sanitize(json));
}

Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
  final r = Map<String, dynamic>.from(json);
  const intFields = [
    'reasonId',
    'act_deact_reason_id',
    'global_reason',
    'disable_for_dpo',
  ];
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
