import 'package:freezed_annotation/freezed_annotation.dart';

part 'expiry_services_response.freezed.dart';
part 'expiry_services_response.g.dart';

@freezed
sealed class ExpiryServicesResponse with _$ExpiryServicesResponse {
  const factory ExpiryServicesResponse({
    @JsonKey(name: 'status_code') @Default(0) int statusCode,
    @JsonKey(name: 'status_msg') @Default('') String statusMsg,
    @JsonKey(name: 'getExpiryServicesList')
    @Default([])
    List<ExpiryDateCount> expiryServicesList,
  }) = _ExpiryServicesResponse;

  factory ExpiryServicesResponse.fromJson(Map<String, dynamic> json) =>
      _$ExpiryServicesResponseFromJson(_sanitize(json));

  static Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
    final r = Map<String, dynamic>.from(json);
    if (r['status_code'] is String) {
      r['status_code'] = int.tryParse(r['status_code'] as String) ?? 0;
    }
    return r;
  }
}

@freezed
sealed class ExpiryDateCount with _$ExpiryDateCount {
  const factory ExpiryDateCount({
    @JsonKey(name: 'date') @Default('') String date,
    @JsonKey(name: 'stb_count') @Default(0) int stbCount,
  }) = _ExpiryDateCount;

  factory ExpiryDateCount.fromJson(Map<String, dynamic> json) =>
      _$ExpiryDateCountFromJson(_sanitizeCount(json));
}

Map<String, dynamic> _sanitizeCount(Map<String, dynamic> json) {
  final r = Map<String, dynamic>.from(json);
  if (r['stb_count'] is String) {
    r['stb_count'] = int.tryParse(r['stb_count'] as String) ?? 0;
  }
  return r;
}
