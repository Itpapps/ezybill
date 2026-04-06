import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_response.freezed.dart';
part 'login_response.g.dart';

@freezed
sealed class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    @JsonKey(name: 'status_code') @Default(0) int statusCode,
    @JsonKey(name: 'status_msg') @Default('') String statusMsg,
    @JsonKey(name: 'token') @Default('') String token,
    @JsonKey(name: 'dealerId') @Default(0) int dealerId,
    @JsonKey(name: 'employeeId') @Default(0) int employeeId,
    @JsonKey(name: 'userType') @Default('') String userType,
    @JsonKey(name: 'first_name') @Default('') String firstName,
    @JsonKey(name: 'last_name') @Default('') String lastName,
    @JsonKey(name: 'email') @Default('') String email,
    @JsonKey(name: 'phone') @Default('') String phone,
    @JsonKey(name: 'lcoCode') @Default('') String lcoCode,
    @JsonKey(name: 'business_name') @Default('') String businessName,
    @JsonKey(name: 'employeeParentType') @Default('') String employeeParentType,
    @JsonKey(name: 'employeeParentId') @Default('') String employeeParentId,
    @JsonKey(name: 'username') String? username,
    @JsonKey(name: 'user_image') String? logoImg,
    @JsonKey(name: 'address1') @Default('') String address1,
    @JsonKey(name: 'address2') @Default('') String address2,
    @JsonKey(name: 'address3') @Default('') String address3,
    @JsonKey(name: 'copy_rights') @Default('') String copyRights,
    @JsonKey(name: 'short_name') @Default('') String shortName,
    @JsonKey(name: 'pin_code') @Default('') String pinCode,
    @JsonKey(name: 'country') @Default('') String country,
    @JsonKey(name: 'state') @Default('') String state,
    @JsonKey(name: 'district') @Default('') String district,
    @JsonKey(name: 'city') @Default('') String city,
    @JsonKey(name: 'dob') @Default('') String dob,
    @JsonKey(name: 'adate') @Default('') String adate,
    @JsonKey(name: 'employeeName') @Default('') String employeeName,
    @JsonKey(name: 'lcoLocation') @Default('') String lcoLocation,
    @JsonKey(name: 'country_name') @Default('') String countryName,

    // Config flags
    @JsonKey(name: 'useCRF') @Default(0) int useCRF,
    @JsonKey(name: 'useCAF') @Default('0') String useCAF,
    @JsonKey(name: 'useLastName') @Default(0) int useLastName,
    @JsonKey(name: 'useDiscount') @Default(0) int useDiscount,
    @JsonKey(name: 'useDataFromMasterTable') @Default(0) int useDataFromMasterTable,
    @JsonKey(name: 'useMandatoryForHotel') @Default(0) int useMandatoryForHotel,
    @JsonKey(name: 'useAccountNumber') @Default(0) int useAccountNumber,
    @JsonKey(name: 'freezecustomerparamsinapp') @Default(0) int freezecustomerparamsinapp,
    @JsonKey(name: 'blockpayment') @Default(0) int blockpayment,
    @JsonKey(name: 'lco_billtype') @Default(0) int lcoBilltype,
    @JsonKey(name: 'use_lco_deposits') @Default(0) int useLcoDeposit,
    @JsonKey(name: 'customer_billtype') @Default(0) int customerBilltype,
    @JsonKey(name: 'AUTO_RECEIPT_NUMBER') @Default(0) int autoReceiptNumber,
    @JsonKey(name: 'CURRENCY_CODE') @Default('INR') String currencyCode,
    @JsonKey(name: 'allow_top_up') @Default(0) int allowTopUp,
    @JsonKey(name: 'show_caf_mobile_validation') @Default(0) int showCafMobileValidation,
    @JsonKey(name: 'stb_pairing') @Default(0) int stbPairing,
    @JsonKey(name: 'stb_unpairing') @Default(0) int stbUnpairing,
    @JsonKey(name: 'show_mia_agreement_upload') @Default(0) int showMiaAgreementUpload,
    @JsonKey(name: 'accept_terms_condtions') @Default(0) int acceptTermsConditions,
    @JsonKey(name: 'agreement_details_count') @Default(0) int agreementDetailsCount,
    @JsonKey(name: 'access_distributor_wise') @Default(0) int accessDistributorWise,
    @JsonKey(name: 'is_direct_lco') @Default(0) int isDirectLco,
    @JsonKey(name: 'is_unpaidlco') @Default(0) int isUnpaidlco,
    @JsonKey(name: 'appMenuFormat') @Default('DEFAULT') String appMenuFormat,
    @JsonKey(name: 'invoicepaymentsearchlimit') @Default(0) int invoicePaymentSearchLimit,
    @JsonKey(name: 'lcoMobileNo') @Default('') String lcoMobileNo,
    @JsonKey(name: 'patch_information') @Default('') String patchInformation,
    @JsonKey(name: 'recurringServiceEdit') @Default(0) int recurringServiceEdit,
    @JsonKey(name: 'showLcoComplaint') @Default(0) int showLcoComplaint,
    @JsonKey(name: 'deposit_amount') @Default(0.0) double depositAmount,
    @JsonKey(name: 'show_serial_vc') @Default(1) int showSerialVc,
    @JsonKey(name: 'show_service_extension') @Default(0) int showServiceExtension,
    @JsonKey(name: 'edit_quantity') @Default(0) int editQuantity,
    @JsonKey(name: 'enable_box_wise_payment') @Default(0) int enableBoxWisePayment,
    @JsonKey(name: 'baid_label') String? baidLabel,

    // Nullable location defaults
    @JsonKey(name: 'defaultCountry') String? defaultCountry,
    @JsonKey(name: 'defaultState') int? defaultState,
    @JsonKey(name: 'defaultDistrict') int? defaultDistrict,
    @JsonKey(name: 'defaultCity') int? defaultCity,

    // Nullable config flags
    @JsonKey(name: 'appTheme') int? appTheme,
    @JsonKey(name: 'appDashboard') int? appDashboard,
    @JsonKey(name: 'enableAadhaar') int? enableAadhaar,
    @JsonKey(name: 'lcoPayment') int? lcoPayment,

    // Notification fields
    @JsonKey(name: 'userNotifications') @Default(0) int userNotifications,
    @JsonKey(name: 'notifyCount') @Default(0) int notifyCount,
    @JsonKey(name: 'note_duration') @Default(0) int noteDuration,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(_sanitizeLoginJson(json));
}

/// Convert String-encoded numbers to actual num types and handle
/// unexpected types (List, Map, null) so json_serializable casts don't throw.
Map<String, dynamic> _sanitizeLoginJson(Map<String, dynamic> json) {
  final result = Map<String, dynamic>.from(json);

  // Fields that should be int but server may send as String, List, or null
  const intFields = [
    'status_code', 'dealerId', 'employeeId', 'useCRF', 'useLastName',
    'useDiscount', 'useDataFromMasterTable', 'useMandatoryForHotel',
    'useAccountNumber', 'freezecustomerparamsinapp', 'blockpayment',
    'lco_billtype', 'use_lco_deposits', 'customer_billtype',
    'AUTO_RECEIPT_NUMBER', 'allow_top_up', 'show_caf_mobile_validation',
    'stb_pairing', 'stb_unpairing', 'show_mia_agreement_upload',
    'accept_terms_condtions', 'agreement_details_count',
    'access_distributor_wise', 'is_direct_lco', 'is_unpaidlco',
    'invoicepaymentsearchlimit', 'recurringServiceEdit',
    'showLcoComplaint', 'show_serial_vc', 'show_service_extension',
    'edit_quantity', 'enable_box_wise_payment', 'defaultState',
    'defaultDistrict', 'defaultCity', 'appTheme', 'appDashboard',
    'enableAadhaar', 'lcoPayment', 'userNotifications', 'notifyCount',
    'note_duration',
  ];
  const doubleFields = ['deposit_amount'];

  for (final key in intFields) {
    final v = result[key];
    if (v is String) {
      result[key] = int.tryParse(v) ?? 0;
    } else if (v is List || v is Map) {
      // Server sometimes sends [] or {} for int fields (e.g., userNotifications: [])
      result[key] = 0;
    } else if (v == null) {
      result[key] = null; // Let @Default handle it
    }
  }
  for (final key in doubleFields) {
    final v = result[key];
    if (v is String) {
      result[key] = double.tryParse(v) ?? 0.0;
    } else if (v is List || v is Map) {
      result[key] = 0.0;
    }
  }

  // config_values_array is a Map — not a model field, remove to avoid cast errors
  // It's accessed separately via AppSession if needed
  if (result['config_values_array'] is Map) {
    result.remove('config_values_array');
  }

  // lcoMobileNo: server sends as number or string; model is now String
  final lcoVal = result['lcoMobileNo'];
  if (lcoVal == null) {
    result['lcoMobileNo'] = '';
  } else if (lcoVal is! String) {
    result['lcoMobileNo'] = lcoVal.toString();
  }

  // Ensure String fields that might be null don't break
  const stringFields = [
    'address2', 'address3', 'phone', 'dob', 'adate',
    'employeeParentId', 'employeeParentType', 'user_image',
    'baid_label',
  ];
  for (final key in stringFields) {
    if (result[key] == null) {
      result[key] = null; // Keep null for nullable String? fields
    } else if (result[key] is! String) {
      result[key] = result[key].toString();
    }
  }

  return result;
}
