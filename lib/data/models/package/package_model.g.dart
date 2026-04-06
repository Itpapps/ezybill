// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PackageModel _$PackageModelFromJson(Map<String, dynamic> json) =>
    _PackageModel(
      packageId: json['product_id'] as String? ?? '',
      packageName: json['pname'] as String? ?? '',
      price: (json['base_price'] as num?)?.toDouble() ?? 0.0,
      isBasePackage: (json['is_base_package'] as num?)?.toInt() ?? 0,
      isBroadcasterPackage:
          (json['is_broadcaster_package'] as num?)?.toInt() ?? 0,
      alacarte: (json['alacarte'] as num?)?.toInt() ?? 0,
      validity: json['monthly_or_yearly'] as String? ?? '',
      validityDays: (json['validity_days'] as num?)?.toInt() ?? 0,
      sdChannels: (json['sd_channels_count'] as num?)?.toInt() ?? 0,
      hdChannels: (json['hd_channels_count'] as num?)?.toInt() ?? 0,
      pricingStructureType: json['pricing_structure_type'] as String? ?? '',
      endDate: json['end_date'] as String?,
      broadcasterId: (json['broadcaster_id'] as num?)?.toInt() ?? 0,
      isTaxable: (json['is_taxble'] as num?)?.toInt() ?? 0,
      tax1: (json['tax1'] as num?)?.toDouble() ?? 0.0,
      tax2: (json['tax2'] as num?)?.toDouble() ?? 0.0,
      tax3: (json['tax3'] as num?)?.toDouble() ?? 0.0,
      tax4: (json['tax4'] as num?)?.toDouble() ?? 0.0,
      tax5: (json['tax5'] as num?)?.toDouble() ?? 0.0,
      tax6: (json['tax6'] as num?)?.toDouble() ?? 0.0,
      serviceId: json['service_id'] as String?,
      customerServiceId: json['customer_service_id'] as String?,
      startDate: json['start_date'] as String?,
      customerName: json['customer_name'] as String?,
      casServerType: json['cas_server_type'] as String?,
      serviceValidityDaysV2: json['service_validity_days_v2'] as String?,
      serviceType: json['service_type'] as String?,
      extendServiceEnddate: json['extend_service_enddate'] as String?,
    );

Map<String, dynamic> _$PackageModelToJson(_PackageModel instance) =>
    <String, dynamic>{
      'product_id': instance.packageId,
      'pname': instance.packageName,
      'base_price': instance.price,
      'is_base_package': instance.isBasePackage,
      'is_broadcaster_package': instance.isBroadcasterPackage,
      'alacarte': instance.alacarte,
      'monthly_or_yearly': instance.validity,
      'validity_days': instance.validityDays,
      'sd_channels_count': instance.sdChannels,
      'hd_channels_count': instance.hdChannels,
      'pricing_structure_type': instance.pricingStructureType,
      'end_date': instance.endDate,
      'broadcaster_id': instance.broadcasterId,
      'is_taxble': instance.isTaxable,
      'tax1': instance.tax1,
      'tax2': instance.tax2,
      'tax3': instance.tax3,
      'tax4': instance.tax4,
      'tax5': instance.tax5,
      'tax6': instance.tax6,
      'service_id': instance.serviceId,
      'customer_service_id': instance.customerServiceId,
      'start_date': instance.startDate,
      'customer_name': instance.customerName,
      'cas_server_type': instance.casServerType,
      'service_validity_days_v2': instance.serviceValidityDaysV2,
      'service_type': instance.serviceType,
      'extend_service_enddate': instance.extendServiceEnddate,
    };
