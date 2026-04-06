import 'package:freezed_annotation/freezed_annotation.dart';

part 'channel_model.freezed.dart';
part 'channel_model.g.dart';

@freezed
sealed class ChannelModel with _$ChannelModel {
  const factory ChannelModel({
    @JsonKey(name: 'channel_id') @Default('') String channelId,
    @JsonKey(name: 'channel_name') @Default('') String channelName,
    @JsonKey(name: 'channel_type') String? channelType,
  }) = _ChannelModel;

  factory ChannelModel.fromJson(Map<String, dynamic> json) =>
      _$ChannelModelFromJson(_sanitize(json));

  static Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
    final r = Map<String, dynamic>.from(json);
    // Handle camelCase variants from server
    if (!r.containsKey('channel_id') && r.containsKey('channelId')) {
      r['channel_id'] = r['channelId'];
    }
    if (!r.containsKey('channel_name') && r.containsKey('channelName')) {
      r['channel_name'] = r['channelName'];
    }
    if (!r.containsKey('channel_type') && r.containsKey('channelType')) {
      r['channel_type'] = r['channelType'];
    }
    // channel_id may come as int
    if (r['channel_id'] is int) r['channel_id'] = r['channel_id'].toString();
    return r;
  }
}
