// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stb_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StbModel _$StbModelFromJson(Map<String, dynamic> json) => _StbModel(
  stbNo: json['serial_number'] as String? ?? '',
  vcNo: json['vc_number'] as String? ?? '',
  customerId: json['customer_id'] as String?,
  status: json['status'] as String? ?? '',
  casType: json['cas_display_name'] as String? ?? '',
  boxNumber: json['box_number'] as String?,
  macAddress: json['mac_address'] as String?,
  stockId: json['stock_id'] as String?,
  deviceId: json['device_id'] as String?,
  backendSetupId: json['backend_setup_id'] as String?,
  stockStatus: json['stock_status'] as String?,
  activatedDate: json['activation_date'] as String?,
  assignedDate: json['assigned_date'] as String?,
  isAssigned: (json['is_assigned'] as num?)?.toInt() ?? 0,
  installationAddress: json['installation_address'] as String?,
  isTempDeactivated: (json['is_temp_deactivated'] as num?)?.toInt() ?? 0,
  stbType: json['stb_type'] as String?,
  stbModel: json['stb_model'] as String?,
  stockLocation: json['stock_location'] as String?,
  customerName: json['customer_name'] as String?,
  mobileNo: json['mobile_no'] as String?,
);

Map<String, dynamic> _$StbModelToJson(_StbModel instance) => <String, dynamic>{
  'serial_number': instance.stbNo,
  'vc_number': instance.vcNo,
  'customer_id': instance.customerId,
  'status': instance.status,
  'cas_display_name': instance.casType,
  'box_number': instance.boxNumber,
  'mac_address': instance.macAddress,
  'stock_id': instance.stockId,
  'device_id': instance.deviceId,
  'backend_setup_id': instance.backendSetupId,
  'stock_status': instance.stockStatus,
  'activation_date': instance.activatedDate,
  'assigned_date': instance.assignedDate,
  'is_assigned': instance.isAssigned,
  'installation_address': instance.installationAddress,
  'is_temp_deactivated': instance.isTempDeactivated,
  'stb_type': instance.stbType,
  'stb_model': instance.stbModel,
  'stock_location': instance.stockLocation,
  'customer_name': instance.customerName,
  'mobile_no': instance.mobileNo,
};
