// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CustomerModel _$CustomerModelFromJson(Map<String, dynamic> json) =>
    _CustomerModel(
      customerId: json['customer_id'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      cafNumber: json['caf_no'] as String?,
      mobileNumber: json['mobile_no'] as String?,
      status: json['status'] as String? ?? '',
      billingAddress: json['billing_address'] as String?,
      installationAddress: json['installation_address'] as String?,
      pinCode: json['pin_code'] as String?,
      crfNumber: json['crf_number'] as String?,
      pendingAmount: (json['pending_amount'] as num?)?.toDouble() ?? 0.0,
      onlineCustomer: (json['online_customer'] as num?)?.toInt() ?? 0,
      checkAddServiceAccess: (json['checkaddserviceaccess'] as num?)?.toInt(),
      addonAfterBasepack: (json['ADDON_AFTER_BASEPACK'] as num?)?.toInt(),
      resellerId: json['reseller_id'] as String?,
      billType: json['bill_type'] as String?,
      isDirectLco: (json['is_direct_lco'] as num?)?.toInt() ?? 0,
      accountNumber: json['account_number'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      serialNumber: json['serial_number'] as String?,
      vcNumber: json['vc_number'] as String?,
      stbCount: (json['stb_count'] as num?)?.toInt() ?? 0,
      baid: json['baid'] as String?,
    );

Map<String, dynamic> _$CustomerModelToJson(_CustomerModel instance) =>
    <String, dynamic>{
      'customer_id': instance.customerId,
      'customerName': instance.customerName,
      'caf_no': instance.cafNumber,
      'mobile_no': instance.mobileNumber,
      'status': instance.status,
      'billing_address': instance.billingAddress,
      'installation_address': instance.installationAddress,
      'pin_code': instance.pinCode,
      'crf_number': instance.crfNumber,
      'pending_amount': instance.pendingAmount,
      'online_customer': instance.onlineCustomer,
      'checkaddserviceaccess': instance.checkAddServiceAccess,
      'ADDON_AFTER_BASEPACK': instance.addonAfterBasepack,
      'reseller_id': instance.resellerId,
      'bill_type': instance.billType,
      'is_direct_lco': instance.isDirectLco,
      'account_number': instance.accountNumber,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'serial_number': instance.serialNumber,
      'vc_number': instance.vcNumber,
      'stb_count': instance.stbCount,
      'baid': instance.baid,
    };
