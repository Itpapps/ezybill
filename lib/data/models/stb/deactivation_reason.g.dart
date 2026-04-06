// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deactivation_reason.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeactivationReason _$DeactivationReasonFromJson(Map<String, dynamic> json) =>
    _DeactivationReason(
      reasonId: (json['reasonId'] as num?)?.toInt() ?? 0,
      reasonName: json['reasonName'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      actDeactReasonId: (json['act_deact_reason_id'] as num?)?.toInt() ?? 0,
      globalReason: (json['global_reason'] as num?)?.toInt() ?? 0,
      disableForDpo: (json['disable_for_dpo'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$DeactivationReasonToJson(_DeactivationReason instance) =>
    <String, dynamic>{
      'reasonId': instance.reasonId,
      'reasonName': instance.reasonName,
      'display_name': instance.displayName,
      'act_deact_reason_id': instance.actDeactReasonId,
      'global_reason': instance.globalReason,
      'disable_for_dpo': instance.disableForDpo,
    };
