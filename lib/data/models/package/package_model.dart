import 'package:freezed_annotation/freezed_annotation.dart';

part 'package_model.freezed.dart';
part 'package_model.g.dart';

@freezed
sealed class PackageModel with _$PackageModel {
  const factory PackageModel({
    @JsonKey(name: 'product_id') @Default('') String packageId,
    @JsonKey(name: 'pname') @Default('') String packageName,
    @JsonKey(name: 'base_price') @Default(0.0) double price,
    @JsonKey(name: 'is_base_package') @Default(0) int isBasePackage,
    @JsonKey(name: 'is_broadcaster_package') @Default(0) int isBroadcasterPackage,
    @JsonKey(name: 'alacarte') @Default(0) int alacarte,
    @JsonKey(name: 'monthly_or_yearly') @Default('') String validity,
    @JsonKey(name: 'validity_days') @Default(0) int validityDays,
    @JsonKey(name: 'sd_channels_count') @Default(0) int sdChannels,
    @JsonKey(name: 'hd_channels_count') @Default(0) int hdChannels,
    @JsonKey(name: 'pricing_structure_type') @Default('') String pricingStructureType,
    @JsonKey(name: 'end_date') String? endDate,
    @JsonKey(name: 'broadcaster_id') @Default(0) int broadcasterId,
    @JsonKey(name: 'is_taxble') @Default(0) int isTaxable,
    @JsonKey(name: 'tax1') @Default(0.0) double tax1,
    @JsonKey(name: 'tax2') @Default(0.0) double tax2,
    @JsonKey(name: 'tax3') @Default(0.0) double tax3,
    @JsonKey(name: 'tax4') @Default(0.0) double tax4,
    @JsonKey(name: 'tax5') @Default(0.0) double tax5,
    @JsonKey(name: 'tax6') @Default(0.0) double tax6,
    // For assigned packages (getCustomerPackages_splitRest)
    @JsonKey(name: 'service_id') String? serviceId,
    @JsonKey(name: 'customer_service_id') String? customerServiceId,
    @JsonKey(name: 'start_date') String? startDate,
    // New fields from server
    @JsonKey(name: 'customer_name') String? customerName,
    @JsonKey(name: 'cas_server_type') String? casServerType,
    @JsonKey(name: 'service_validity_days_v2') String? serviceValidityDaysV2,
    @JsonKey(name: 'service_type') String? serviceType,
    @JsonKey(name: 'extend_service_enddate') String? extendServiceEnddate,
  }) = _PackageModel;

  factory PackageModel.fromJson(Map<String, dynamic> json) =>
      _$PackageModelFromJson(_sanitize(json));

  static Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
    final r = Map<String, dynamic>.from(json);

    // Alias: if pname is missing, use product_name
    if (r['pname'] == null && r['product_name'] != null) {
      r['pname'] = r['product_name'];
    }

    // Alias: service_start_date -> start_date
    if (r['start_date'] == null && r['service_start_date'] != null) {
      r['start_date'] = r['service_start_date'];
    }

    // Alias: service_end_date -> end_date
    if (r['end_date'] == null && r['service_end_date'] != null) {
      r['end_date'] = r['service_end_date'];
    }

    // Alias: is_taxable -> is_taxble
    if (r['is_taxble'] == null && r['is_taxable'] != null) {
      r['is_taxble'] = r['is_taxable'];
    }

    // Int fields server sends as String
    const intFields = [
      'is_base_package', 'is_broadcaster_package', 'alacarte',
      'validity_days', 'sd_channels_count', 'hd_channels_count',
      'broadcaster_id', 'is_taxble',
    ];
    // Double fields server sends as String
    const doubleFields = [
      'base_price', 'tax1', 'tax2', 'tax3', 'tax4', 'tax5', 'tax6',
    ];

    for (final key in intFields) {
      final v = r[key];
      if (v is String) r[key] = int.tryParse(v) ?? 0;
      if (v == null) r[key] = 0;
    }
    for (final key in doubleFields) {
      final v = r[key];
      if (v is String) r[key] = double.tryParse(v) ?? 0.0;
      if (v == null) r[key] = 0.0;
    }

    // product_id may come as int
    if (r['product_id'] is int) r['product_id'] = r['product_id'].toString();
    if (r['pricing_structure_type'] is int) {
      r['pricing_structure_type'] = r['pricing_structure_type'].toString();
    }

    return r;
  }
}
