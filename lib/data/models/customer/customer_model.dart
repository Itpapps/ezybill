import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_model.freezed.dart';
part 'customer_model.g.dart';

@freezed
sealed class CustomerModel with _$CustomerModel {
  const factory CustomerModel({
    @JsonKey(name: 'customer_id') @Default('') String customerId,
    @JsonKey(name: 'customerName') @Default('') String customerName,
    @JsonKey(name: 'caf_no') String? cafNumber,
    @JsonKey(name: 'mobile_no') String? mobileNumber,
    @JsonKey(name: 'status') @Default('') String status,
    @JsonKey(name: 'billing_address') String? billingAddress,
    @JsonKey(name: 'installation_address') String? installationAddress,
    @JsonKey(name: 'pin_code') String? pinCode,
    @JsonKey(name: 'crf_number') String? crfNumber,
    @JsonKey(name: 'pending_amount') @Default(0.0) double pendingAmount,
    @JsonKey(name: 'online_customer') @Default(0) int onlineCustomer,
    @JsonKey(name: 'checkaddserviceaccess') int? checkAddServiceAccess,
    @JsonKey(name: 'ADDON_AFTER_BASEPACK') int? addonAfterBasepack,
    @JsonKey(name: 'reseller_id') String? resellerId,
    @JsonKey(name: 'bill_type') String? billType,
    @JsonKey(name: 'is_direct_lco') @Default(0) int isDirectLco,
    @JsonKey(name: 'account_number') String? accountNumber,
    @JsonKey(name: 'latitude') @Default(0.0) double latitude,
    @JsonKey(name: 'longitude') @Default(0.0) double longitude,
    @JsonKey(name: 'serial_number') String? serialNumber,
    @JsonKey(name: 'vc_number') String? vcNumber,
    @JsonKey(name: 'stb_count') @Default(0) int stbCount,
    @JsonKey(name: 'baid') String? baid,
  }) = _CustomerModel;

  factory CustomerModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerModelFromJson(_sanitize(json));

  static Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
    final r = Map<String, dynamic>.from(json);

    // Server sends int/double fields as various types
    const intFields = [
      'online_customer', 'is_direct_lco', 'stb_count', 'status',
      'checkaddserviceaccess', 'ADDON_AFTER_BASEPACK',
    ];
    const doubleFields = ['pending_amount', 'latitude', 'longitude'];

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

    // Ensure customer_id is String (server may send int)
    if (r['customer_id'] is int) {
      r['customer_id'] = r['customer_id'].toString();
    }
    if (r['reseller_id'] is int) {
      r['reseller_id'] = r['reseller_id'].toString();
    }
    // status may come as int (1=active, 0=inactive)
    if (r['status'] is int) {
      r['status'] = r['status'].toString();
    }

    return r;
  }
}
