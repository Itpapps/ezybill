import 'package:freezed_annotation/freezed_annotation.dart';

import 'customer_model.dart';

part 'customer_search_response.freezed.dart';
part 'customer_search_response.g.dart';

@freezed
sealed class CustomerSearchResponse with _$CustomerSearchResponse {
  const factory CustomerSearchResponse({
    @JsonKey(name: 'statusCode') @Default(0) int statusCode,
    @JsonKey(name: 'statusMessage') String? statusMsg,
    @JsonKey(name: 'customerCount') @Default(0) int customerCount,
    @JsonKey(name: 'lco_share') @Default(0.0) double lcoShare,
    @JsonKey(name: 'total_amount') @Default(0.0) double totalAmount,
    @JsonKey(name: 'mso_share') @Default(0.0) double msoShare,
    @JsonKey(name: 'baid_label') String? baidLabel,
    @JsonKey(name: 'customerDetailsList')
    @Default([])
    List<CustomerModel> existCustomerDetails,
  }) = _CustomerSearchResponse;

  factory CustomerSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$CustomerSearchResponseFromJson(_sanitize(json));

  static Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
    final r = Map<String, dynamic>.from(json);

    // Int fields that server may send as String
    for (final key in ['statusCode', 'customerCount']) {
      if (r[key] is String) r[key] = int.tryParse(r[key] as String) ?? 0;
    }
    // Double fields
    for (final key in ['lco_share', 'total_amount', 'mso_share', 'tot_mso_share']) {
      if (r[key] is String) r[key] = double.tryParse(r[key] as String) ?? 0.0;
    }

    // Server may use 'existCustomerDetails' or 'customerDetailsList'
    if (!r.containsKey('customerDetailsList') &&
        r.containsKey('existCustomerDetails')) {
      r['customerDetailsList'] = r['existCustomerDetails'];
    }

    // customerCount may not be present in getCustomerDetailsRest (only in Count endpoint)
    // Derive from list length if missing
    if (!r.containsKey('customerCount') || r['customerCount'] == null) {
      final list = r['customerDetailsList'];
      r['customerCount'] = list is List ? list.length : 0;
    }

    return r;
  }
}
