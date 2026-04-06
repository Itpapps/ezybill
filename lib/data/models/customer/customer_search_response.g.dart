// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_search_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CustomerSearchResponse _$CustomerSearchResponseFromJson(
  Map<String, dynamic> json,
) => _CustomerSearchResponse(
  statusCode: (json['statusCode'] as num?)?.toInt() ?? 0,
  statusMsg: json['statusMessage'] as String?,
  customerCount: (json['customerCount'] as num?)?.toInt() ?? 0,
  lcoShare: (json['lco_share'] as num?)?.toDouble() ?? 0.0,
  totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
  msoShare: (json['mso_share'] as num?)?.toDouble() ?? 0.0,
  baidLabel: json['baid_label'] as String?,
  existCustomerDetails:
      (json['customerDetailsList'] as List<dynamic>?)
          ?.map((e) => CustomerModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$CustomerSearchResponseToJson(
  _CustomerSearchResponse instance,
) => <String, dynamic>{
  'statusCode': instance.statusCode,
  'statusMessage': instance.statusMsg,
  'customerCount': instance.customerCount,
  'lco_share': instance.lcoShare,
  'total_amount': instance.totalAmount,
  'mso_share': instance.msoShare,
  'baid_label': instance.baidLabel,
  'customerDetailsList': instance.existCustomerDetails,
};
