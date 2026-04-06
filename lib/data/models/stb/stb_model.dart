import 'package:freezed_annotation/freezed_annotation.dart';

part 'stb_model.freezed.dart';
part 'stb_model.g.dart';

@freezed
sealed class StbModel with _$StbModel {
  const factory StbModel({
    @JsonKey(name: 'serial_number') @Default('') String stbNo,
    @JsonKey(name: 'vc_number') @Default('') String vcNo,
    @JsonKey(name: 'customer_id') String? customerId,
    @JsonKey(name: 'status') @Default('') String status,
    @JsonKey(name: 'cas_display_name') @Default('') String casType,
    @JsonKey(name: 'box_number') String? boxNumber,
    @JsonKey(name: 'mac_address') String? macAddress,
    @JsonKey(name: 'stock_id') String? stockId,
    @JsonKey(name: 'device_id') String? deviceId,
    @JsonKey(name: 'backend_setup_id') String? backendSetupId,
    @JsonKey(name: 'stock_status') String? stockStatus,
    @JsonKey(name: 'activation_date') String? activatedDate,
    @JsonKey(name: 'assigned_date') String? assignedDate,
    @JsonKey(name: 'is_assigned') @Default(0) int isAssigned,
    @JsonKey(name: 'installation_address') String? installationAddress,
    @JsonKey(name: 'is_temp_deactivated') @Default(0) int isTempDeactivated,
    // New fields from server
    @JsonKey(name: 'stb_type') String? stbType,
    @JsonKey(name: 'stb_model') String? stbModel,
    @JsonKey(name: 'stock_location') String? stockLocation,
    @JsonKey(name: 'customer_name') String? customerName,
    @JsonKey(name: 'mobile_no') String? mobileNo,
  }) = _StbModel;

  factory StbModel.fromJson(Map<String, dynamic> json) =>
      _$StbModelFromJson(_sanitize(json));

  static Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
    final r = Map<String, dynamic>.from(json);

    // Handle int fields that server may send as String
    const intFields = ['is_assigned', 'is_temp_deactivated'];
    for (final key in intFields) {
      final v = r[key];
      if (v is String) r[key] = int.tryParse(v) ?? 0;
      if (v == null) r[key] = 0;
    }

    // Ensure stock_id, device_id, backend_setup_id are String
    for (final key in ['stock_id', 'device_id', 'backend_setup_id']) {
      final v = r[key];
      if (v is int) r[key] = v.toString();
    }

    return r;
  }
}
