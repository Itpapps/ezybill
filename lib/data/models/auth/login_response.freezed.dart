// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LoginResponse {

@JsonKey(name: 'status_code') int get statusCode;@JsonKey(name: 'status_msg') String get statusMsg;@JsonKey(name: 'token') String get token;@JsonKey(name: 'dealerId') int get dealerId;@JsonKey(name: 'employeeId') int get employeeId;@JsonKey(name: 'userType') String get userType;@JsonKey(name: 'first_name') String get firstName;@JsonKey(name: 'last_name') String get lastName;@JsonKey(name: 'email') String get email;@JsonKey(name: 'phone') String get phone;@JsonKey(name: 'lcoCode') String get lcoCode;@JsonKey(name: 'business_name') String get businessName;@JsonKey(name: 'employeeParentType') String get employeeParentType;@JsonKey(name: 'employeeParentId') String get employeeParentId;@JsonKey(name: 'username') String? get username;@JsonKey(name: 'user_image') String? get logoImg;@JsonKey(name: 'address1') String get address1;@JsonKey(name: 'address2') String get address2;@JsonKey(name: 'address3') String get address3;@JsonKey(name: 'copy_rights') String get copyRights;@JsonKey(name: 'short_name') String get shortName;@JsonKey(name: 'pin_code') String get pinCode;@JsonKey(name: 'country') String get country;@JsonKey(name: 'state') String get state;@JsonKey(name: 'district') String get district;@JsonKey(name: 'city') String get city;@JsonKey(name: 'dob') String get dob;@JsonKey(name: 'adate') String get adate;@JsonKey(name: 'employeeName') String get employeeName;@JsonKey(name: 'lcoLocation') String get lcoLocation;@JsonKey(name: 'country_name') String get countryName;// Config flags
@JsonKey(name: 'useCRF') int get useCRF;@JsonKey(name: 'useCAF') String get useCAF;@JsonKey(name: 'useLastName') int get useLastName;@JsonKey(name: 'useDiscount') int get useDiscount;@JsonKey(name: 'useDataFromMasterTable') int get useDataFromMasterTable;@JsonKey(name: 'useMandatoryForHotel') int get useMandatoryForHotel;@JsonKey(name: 'useAccountNumber') int get useAccountNumber;@JsonKey(name: 'freezecustomerparamsinapp') int get freezecustomerparamsinapp;@JsonKey(name: 'blockpayment') int get blockpayment;@JsonKey(name: 'lco_billtype') int get lcoBilltype;@JsonKey(name: 'use_lco_deposits') int get useLcoDeposit;@JsonKey(name: 'customer_billtype') int get customerBilltype;@JsonKey(name: 'AUTO_RECEIPT_NUMBER') int get autoReceiptNumber;@JsonKey(name: 'CURRENCY_CODE') String get currencyCode;@JsonKey(name: 'allow_top_up') int get allowTopUp;@JsonKey(name: 'show_caf_mobile_validation') int get showCafMobileValidation;@JsonKey(name: 'stb_pairing') int get stbPairing;@JsonKey(name: 'stb_unpairing') int get stbUnpairing;@JsonKey(name: 'show_mia_agreement_upload') int get showMiaAgreementUpload;@JsonKey(name: 'accept_terms_condtions') int get acceptTermsConditions;@JsonKey(name: 'agreement_details_count') int get agreementDetailsCount;@JsonKey(name: 'access_distributor_wise') int get accessDistributorWise;@JsonKey(name: 'is_direct_lco') int get isDirectLco;@JsonKey(name: 'is_unpaidlco') int get isUnpaidlco;@JsonKey(name: 'appMenuFormat') String get appMenuFormat;@JsonKey(name: 'invoicepaymentsearchlimit') int get invoicePaymentSearchLimit;@JsonKey(name: 'lcoMobileNo') String get lcoMobileNo;@JsonKey(name: 'patch_information') String get patchInformation;@JsonKey(name: 'recurringServiceEdit') int get recurringServiceEdit;@JsonKey(name: 'showLcoComplaint') int get showLcoComplaint;@JsonKey(name: 'deposit_amount') double get depositAmount;@JsonKey(name: 'show_serial_vc') int get showSerialVc;@JsonKey(name: 'show_service_extension') int get showServiceExtension;@JsonKey(name: 'edit_quantity') int get editQuantity;@JsonKey(name: 'enable_box_wise_payment') int get enableBoxWisePayment;@JsonKey(name: 'baid_label') String? get baidLabel;// Nullable location defaults
@JsonKey(name: 'defaultCountry') String? get defaultCountry;@JsonKey(name: 'defaultState') int? get defaultState;@JsonKey(name: 'defaultDistrict') int? get defaultDistrict;@JsonKey(name: 'defaultCity') int? get defaultCity;// Nullable config flags
@JsonKey(name: 'appTheme') int? get appTheme;@JsonKey(name: 'appDashboard') int? get appDashboard;@JsonKey(name: 'enableAadhaar') int? get enableAadhaar;@JsonKey(name: 'lcoPayment') int? get lcoPayment;// Notification fields
@JsonKey(name: 'userNotifications') int get userNotifications;@JsonKey(name: 'notifyCount') int get notifyCount;@JsonKey(name: 'note_duration') int get noteDuration;
/// Create a copy of LoginResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginResponseCopyWith<LoginResponse> get copyWith => _$LoginResponseCopyWithImpl<LoginResponse>(this as LoginResponse, _$identity);

  /// Serializes this LoginResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginResponse&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.statusMsg, statusMsg) || other.statusMsg == statusMsg)&&(identical(other.token, token) || other.token == token)&&(identical(other.dealerId, dealerId) || other.dealerId == dealerId)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.userType, userType) || other.userType == userType)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.lcoCode, lcoCode) || other.lcoCode == lcoCode)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.employeeParentType, employeeParentType) || other.employeeParentType == employeeParentType)&&(identical(other.employeeParentId, employeeParentId) || other.employeeParentId == employeeParentId)&&(identical(other.username, username) || other.username == username)&&(identical(other.logoImg, logoImg) || other.logoImg == logoImg)&&(identical(other.address1, address1) || other.address1 == address1)&&(identical(other.address2, address2) || other.address2 == address2)&&(identical(other.address3, address3) || other.address3 == address3)&&(identical(other.copyRights, copyRights) || other.copyRights == copyRights)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.pinCode, pinCode) || other.pinCode == pinCode)&&(identical(other.country, country) || other.country == country)&&(identical(other.state, state) || other.state == state)&&(identical(other.district, district) || other.district == district)&&(identical(other.city, city) || other.city == city)&&(identical(other.dob, dob) || other.dob == dob)&&(identical(other.adate, adate) || other.adate == adate)&&(identical(other.employeeName, employeeName) || other.employeeName == employeeName)&&(identical(other.lcoLocation, lcoLocation) || other.lcoLocation == lcoLocation)&&(identical(other.countryName, countryName) || other.countryName == countryName)&&(identical(other.useCRF, useCRF) || other.useCRF == useCRF)&&(identical(other.useCAF, useCAF) || other.useCAF == useCAF)&&(identical(other.useLastName, useLastName) || other.useLastName == useLastName)&&(identical(other.useDiscount, useDiscount) || other.useDiscount == useDiscount)&&(identical(other.useDataFromMasterTable, useDataFromMasterTable) || other.useDataFromMasterTable == useDataFromMasterTable)&&(identical(other.useMandatoryForHotel, useMandatoryForHotel) || other.useMandatoryForHotel == useMandatoryForHotel)&&(identical(other.useAccountNumber, useAccountNumber) || other.useAccountNumber == useAccountNumber)&&(identical(other.freezecustomerparamsinapp, freezecustomerparamsinapp) || other.freezecustomerparamsinapp == freezecustomerparamsinapp)&&(identical(other.blockpayment, blockpayment) || other.blockpayment == blockpayment)&&(identical(other.lcoBilltype, lcoBilltype) || other.lcoBilltype == lcoBilltype)&&(identical(other.useLcoDeposit, useLcoDeposit) || other.useLcoDeposit == useLcoDeposit)&&(identical(other.customerBilltype, customerBilltype) || other.customerBilltype == customerBilltype)&&(identical(other.autoReceiptNumber, autoReceiptNumber) || other.autoReceiptNumber == autoReceiptNumber)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.allowTopUp, allowTopUp) || other.allowTopUp == allowTopUp)&&(identical(other.showCafMobileValidation, showCafMobileValidation) || other.showCafMobileValidation == showCafMobileValidation)&&(identical(other.stbPairing, stbPairing) || other.stbPairing == stbPairing)&&(identical(other.stbUnpairing, stbUnpairing) || other.stbUnpairing == stbUnpairing)&&(identical(other.showMiaAgreementUpload, showMiaAgreementUpload) || other.showMiaAgreementUpload == showMiaAgreementUpload)&&(identical(other.acceptTermsConditions, acceptTermsConditions) || other.acceptTermsConditions == acceptTermsConditions)&&(identical(other.agreementDetailsCount, agreementDetailsCount) || other.agreementDetailsCount == agreementDetailsCount)&&(identical(other.accessDistributorWise, accessDistributorWise) || other.accessDistributorWise == accessDistributorWise)&&(identical(other.isDirectLco, isDirectLco) || other.isDirectLco == isDirectLco)&&(identical(other.isUnpaidlco, isUnpaidlco) || other.isUnpaidlco == isUnpaidlco)&&(identical(other.appMenuFormat, appMenuFormat) || other.appMenuFormat == appMenuFormat)&&(identical(other.invoicePaymentSearchLimit, invoicePaymentSearchLimit) || other.invoicePaymentSearchLimit == invoicePaymentSearchLimit)&&(identical(other.lcoMobileNo, lcoMobileNo) || other.lcoMobileNo == lcoMobileNo)&&(identical(other.patchInformation, patchInformation) || other.patchInformation == patchInformation)&&(identical(other.recurringServiceEdit, recurringServiceEdit) || other.recurringServiceEdit == recurringServiceEdit)&&(identical(other.showLcoComplaint, showLcoComplaint) || other.showLcoComplaint == showLcoComplaint)&&(identical(other.depositAmount, depositAmount) || other.depositAmount == depositAmount)&&(identical(other.showSerialVc, showSerialVc) || other.showSerialVc == showSerialVc)&&(identical(other.showServiceExtension, showServiceExtension) || other.showServiceExtension == showServiceExtension)&&(identical(other.editQuantity, editQuantity) || other.editQuantity == editQuantity)&&(identical(other.enableBoxWisePayment, enableBoxWisePayment) || other.enableBoxWisePayment == enableBoxWisePayment)&&(identical(other.baidLabel, baidLabel) || other.baidLabel == baidLabel)&&(identical(other.defaultCountry, defaultCountry) || other.defaultCountry == defaultCountry)&&(identical(other.defaultState, defaultState) || other.defaultState == defaultState)&&(identical(other.defaultDistrict, defaultDistrict) || other.defaultDistrict == defaultDistrict)&&(identical(other.defaultCity, defaultCity) || other.defaultCity == defaultCity)&&(identical(other.appTheme, appTheme) || other.appTheme == appTheme)&&(identical(other.appDashboard, appDashboard) || other.appDashboard == appDashboard)&&(identical(other.enableAadhaar, enableAadhaar) || other.enableAadhaar == enableAadhaar)&&(identical(other.lcoPayment, lcoPayment) || other.lcoPayment == lcoPayment)&&(identical(other.userNotifications, userNotifications) || other.userNotifications == userNotifications)&&(identical(other.notifyCount, notifyCount) || other.notifyCount == notifyCount)&&(identical(other.noteDuration, noteDuration) || other.noteDuration == noteDuration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,statusCode,statusMsg,token,dealerId,employeeId,userType,firstName,lastName,email,phone,lcoCode,businessName,employeeParentType,employeeParentId,username,logoImg,address1,address2,address3,copyRights,shortName,pinCode,country,state,district,city,dob,adate,employeeName,lcoLocation,countryName,useCRF,useCAF,useLastName,useDiscount,useDataFromMasterTable,useMandatoryForHotel,useAccountNumber,freezecustomerparamsinapp,blockpayment,lcoBilltype,useLcoDeposit,customerBilltype,autoReceiptNumber,currencyCode,allowTopUp,showCafMobileValidation,stbPairing,stbUnpairing,showMiaAgreementUpload,acceptTermsConditions,agreementDetailsCount,accessDistributorWise,isDirectLco,isUnpaidlco,appMenuFormat,invoicePaymentSearchLimit,lcoMobileNo,patchInformation,recurringServiceEdit,showLcoComplaint,depositAmount,showSerialVc,showServiceExtension,editQuantity,enableBoxWisePayment,baidLabel,defaultCountry,defaultState,defaultDistrict,defaultCity,appTheme,appDashboard,enableAadhaar,lcoPayment,userNotifications,notifyCount,noteDuration]);

@override
String toString() {
  return 'LoginResponse(statusCode: $statusCode, statusMsg: $statusMsg, token: $token, dealerId: $dealerId, employeeId: $employeeId, userType: $userType, firstName: $firstName, lastName: $lastName, email: $email, phone: $phone, lcoCode: $lcoCode, businessName: $businessName, employeeParentType: $employeeParentType, employeeParentId: $employeeParentId, username: $username, logoImg: $logoImg, address1: $address1, address2: $address2, address3: $address3, copyRights: $copyRights, shortName: $shortName, pinCode: $pinCode, country: $country, state: $state, district: $district, city: $city, dob: $dob, adate: $adate, employeeName: $employeeName, lcoLocation: $lcoLocation, countryName: $countryName, useCRF: $useCRF, useCAF: $useCAF, useLastName: $useLastName, useDiscount: $useDiscount, useDataFromMasterTable: $useDataFromMasterTable, useMandatoryForHotel: $useMandatoryForHotel, useAccountNumber: $useAccountNumber, freezecustomerparamsinapp: $freezecustomerparamsinapp, blockpayment: $blockpayment, lcoBilltype: $lcoBilltype, useLcoDeposit: $useLcoDeposit, customerBilltype: $customerBilltype, autoReceiptNumber: $autoReceiptNumber, currencyCode: $currencyCode, allowTopUp: $allowTopUp, showCafMobileValidation: $showCafMobileValidation, stbPairing: $stbPairing, stbUnpairing: $stbUnpairing, showMiaAgreementUpload: $showMiaAgreementUpload, acceptTermsConditions: $acceptTermsConditions, agreementDetailsCount: $agreementDetailsCount, accessDistributorWise: $accessDistributorWise, isDirectLco: $isDirectLco, isUnpaidlco: $isUnpaidlco, appMenuFormat: $appMenuFormat, invoicePaymentSearchLimit: $invoicePaymentSearchLimit, lcoMobileNo: $lcoMobileNo, patchInformation: $patchInformation, recurringServiceEdit: $recurringServiceEdit, showLcoComplaint: $showLcoComplaint, depositAmount: $depositAmount, showSerialVc: $showSerialVc, showServiceExtension: $showServiceExtension, editQuantity: $editQuantity, enableBoxWisePayment: $enableBoxWisePayment, baidLabel: $baidLabel, defaultCountry: $defaultCountry, defaultState: $defaultState, defaultDistrict: $defaultDistrict, defaultCity: $defaultCity, appTheme: $appTheme, appDashboard: $appDashboard, enableAadhaar: $enableAadhaar, lcoPayment: $lcoPayment, userNotifications: $userNotifications, notifyCount: $notifyCount, noteDuration: $noteDuration)';
}


}

/// @nodoc
abstract mixin class $LoginResponseCopyWith<$Res>  {
  factory $LoginResponseCopyWith(LoginResponse value, $Res Function(LoginResponse) _then) = _$LoginResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'status_code') int statusCode,@JsonKey(name: 'status_msg') String statusMsg,@JsonKey(name: 'token') String token,@JsonKey(name: 'dealerId') int dealerId,@JsonKey(name: 'employeeId') int employeeId,@JsonKey(name: 'userType') String userType,@JsonKey(name: 'first_name') String firstName,@JsonKey(name: 'last_name') String lastName,@JsonKey(name: 'email') String email,@JsonKey(name: 'phone') String phone,@JsonKey(name: 'lcoCode') String lcoCode,@JsonKey(name: 'business_name') String businessName,@JsonKey(name: 'employeeParentType') String employeeParentType,@JsonKey(name: 'employeeParentId') String employeeParentId,@JsonKey(name: 'username') String? username,@JsonKey(name: 'user_image') String? logoImg,@JsonKey(name: 'address1') String address1,@JsonKey(name: 'address2') String address2,@JsonKey(name: 'address3') String address3,@JsonKey(name: 'copy_rights') String copyRights,@JsonKey(name: 'short_name') String shortName,@JsonKey(name: 'pin_code') String pinCode,@JsonKey(name: 'country') String country,@JsonKey(name: 'state') String state,@JsonKey(name: 'district') String district,@JsonKey(name: 'city') String city,@JsonKey(name: 'dob') String dob,@JsonKey(name: 'adate') String adate,@JsonKey(name: 'employeeName') String employeeName,@JsonKey(name: 'lcoLocation') String lcoLocation,@JsonKey(name: 'country_name') String countryName,@JsonKey(name: 'useCRF') int useCRF,@JsonKey(name: 'useCAF') String useCAF,@JsonKey(name: 'useLastName') int useLastName,@JsonKey(name: 'useDiscount') int useDiscount,@JsonKey(name: 'useDataFromMasterTable') int useDataFromMasterTable,@JsonKey(name: 'useMandatoryForHotel') int useMandatoryForHotel,@JsonKey(name: 'useAccountNumber') int useAccountNumber,@JsonKey(name: 'freezecustomerparamsinapp') int freezecustomerparamsinapp,@JsonKey(name: 'blockpayment') int blockpayment,@JsonKey(name: 'lco_billtype') int lcoBilltype,@JsonKey(name: 'use_lco_deposits') int useLcoDeposit,@JsonKey(name: 'customer_billtype') int customerBilltype,@JsonKey(name: 'AUTO_RECEIPT_NUMBER') int autoReceiptNumber,@JsonKey(name: 'CURRENCY_CODE') String currencyCode,@JsonKey(name: 'allow_top_up') int allowTopUp,@JsonKey(name: 'show_caf_mobile_validation') int showCafMobileValidation,@JsonKey(name: 'stb_pairing') int stbPairing,@JsonKey(name: 'stb_unpairing') int stbUnpairing,@JsonKey(name: 'show_mia_agreement_upload') int showMiaAgreementUpload,@JsonKey(name: 'accept_terms_condtions') int acceptTermsConditions,@JsonKey(name: 'agreement_details_count') int agreementDetailsCount,@JsonKey(name: 'access_distributor_wise') int accessDistributorWise,@JsonKey(name: 'is_direct_lco') int isDirectLco,@JsonKey(name: 'is_unpaidlco') int isUnpaidlco,@JsonKey(name: 'appMenuFormat') String appMenuFormat,@JsonKey(name: 'invoicepaymentsearchlimit') int invoicePaymentSearchLimit,@JsonKey(name: 'lcoMobileNo') String lcoMobileNo,@JsonKey(name: 'patch_information') String patchInformation,@JsonKey(name: 'recurringServiceEdit') int recurringServiceEdit,@JsonKey(name: 'showLcoComplaint') int showLcoComplaint,@JsonKey(name: 'deposit_amount') double depositAmount,@JsonKey(name: 'show_serial_vc') int showSerialVc,@JsonKey(name: 'show_service_extension') int showServiceExtension,@JsonKey(name: 'edit_quantity') int editQuantity,@JsonKey(name: 'enable_box_wise_payment') int enableBoxWisePayment,@JsonKey(name: 'baid_label') String? baidLabel,@JsonKey(name: 'defaultCountry') String? defaultCountry,@JsonKey(name: 'defaultState') int? defaultState,@JsonKey(name: 'defaultDistrict') int? defaultDistrict,@JsonKey(name: 'defaultCity') int? defaultCity,@JsonKey(name: 'appTheme') int? appTheme,@JsonKey(name: 'appDashboard') int? appDashboard,@JsonKey(name: 'enableAadhaar') int? enableAadhaar,@JsonKey(name: 'lcoPayment') int? lcoPayment,@JsonKey(name: 'userNotifications') int userNotifications,@JsonKey(name: 'notifyCount') int notifyCount,@JsonKey(name: 'note_duration') int noteDuration
});




}
/// @nodoc
class _$LoginResponseCopyWithImpl<$Res>
    implements $LoginResponseCopyWith<$Res> {
  _$LoginResponseCopyWithImpl(this._self, this._then);

  final LoginResponse _self;
  final $Res Function(LoginResponse) _then;

/// Create a copy of LoginResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? statusCode = null,Object? statusMsg = null,Object? token = null,Object? dealerId = null,Object? employeeId = null,Object? userType = null,Object? firstName = null,Object? lastName = null,Object? email = null,Object? phone = null,Object? lcoCode = null,Object? businessName = null,Object? employeeParentType = null,Object? employeeParentId = null,Object? username = freezed,Object? logoImg = freezed,Object? address1 = null,Object? address2 = null,Object? address3 = null,Object? copyRights = null,Object? shortName = null,Object? pinCode = null,Object? country = null,Object? state = null,Object? district = null,Object? city = null,Object? dob = null,Object? adate = null,Object? employeeName = null,Object? lcoLocation = null,Object? countryName = null,Object? useCRF = null,Object? useCAF = null,Object? useLastName = null,Object? useDiscount = null,Object? useDataFromMasterTable = null,Object? useMandatoryForHotel = null,Object? useAccountNumber = null,Object? freezecustomerparamsinapp = null,Object? blockpayment = null,Object? lcoBilltype = null,Object? useLcoDeposit = null,Object? customerBilltype = null,Object? autoReceiptNumber = null,Object? currencyCode = null,Object? allowTopUp = null,Object? showCafMobileValidation = null,Object? stbPairing = null,Object? stbUnpairing = null,Object? showMiaAgreementUpload = null,Object? acceptTermsConditions = null,Object? agreementDetailsCount = null,Object? accessDistributorWise = null,Object? isDirectLco = null,Object? isUnpaidlco = null,Object? appMenuFormat = null,Object? invoicePaymentSearchLimit = null,Object? lcoMobileNo = null,Object? patchInformation = null,Object? recurringServiceEdit = null,Object? showLcoComplaint = null,Object? depositAmount = null,Object? showSerialVc = null,Object? showServiceExtension = null,Object? editQuantity = null,Object? enableBoxWisePayment = null,Object? baidLabel = freezed,Object? defaultCountry = freezed,Object? defaultState = freezed,Object? defaultDistrict = freezed,Object? defaultCity = freezed,Object? appTheme = freezed,Object? appDashboard = freezed,Object? enableAadhaar = freezed,Object? lcoPayment = freezed,Object? userNotifications = null,Object? notifyCount = null,Object? noteDuration = null,}) {
  return _then(_self.copyWith(
statusCode: null == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int,statusMsg: null == statusMsg ? _self.statusMsg : statusMsg // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,dealerId: null == dealerId ? _self.dealerId : dealerId // ignore: cast_nullable_to_non_nullable
as int,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as int,userType: null == userType ? _self.userType : userType // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,lcoCode: null == lcoCode ? _self.lcoCode : lcoCode // ignore: cast_nullable_to_non_nullable
as String,businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,employeeParentType: null == employeeParentType ? _self.employeeParentType : employeeParentType // ignore: cast_nullable_to_non_nullable
as String,employeeParentId: null == employeeParentId ? _self.employeeParentId : employeeParentId // ignore: cast_nullable_to_non_nullable
as String,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,logoImg: freezed == logoImg ? _self.logoImg : logoImg // ignore: cast_nullable_to_non_nullable
as String?,address1: null == address1 ? _self.address1 : address1 // ignore: cast_nullable_to_non_nullable
as String,address2: null == address2 ? _self.address2 : address2 // ignore: cast_nullable_to_non_nullable
as String,address3: null == address3 ? _self.address3 : address3 // ignore: cast_nullable_to_non_nullable
as String,copyRights: null == copyRights ? _self.copyRights : copyRights // ignore: cast_nullable_to_non_nullable
as String,shortName: null == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String,pinCode: null == pinCode ? _self.pinCode : pinCode // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,district: null == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,dob: null == dob ? _self.dob : dob // ignore: cast_nullable_to_non_nullable
as String,adate: null == adate ? _self.adate : adate // ignore: cast_nullable_to_non_nullable
as String,employeeName: null == employeeName ? _self.employeeName : employeeName // ignore: cast_nullable_to_non_nullable
as String,lcoLocation: null == lcoLocation ? _self.lcoLocation : lcoLocation // ignore: cast_nullable_to_non_nullable
as String,countryName: null == countryName ? _self.countryName : countryName // ignore: cast_nullable_to_non_nullable
as String,useCRF: null == useCRF ? _self.useCRF : useCRF // ignore: cast_nullable_to_non_nullable
as int,useCAF: null == useCAF ? _self.useCAF : useCAF // ignore: cast_nullable_to_non_nullable
as String,useLastName: null == useLastName ? _self.useLastName : useLastName // ignore: cast_nullable_to_non_nullable
as int,useDiscount: null == useDiscount ? _self.useDiscount : useDiscount // ignore: cast_nullable_to_non_nullable
as int,useDataFromMasterTable: null == useDataFromMasterTable ? _self.useDataFromMasterTable : useDataFromMasterTable // ignore: cast_nullable_to_non_nullable
as int,useMandatoryForHotel: null == useMandatoryForHotel ? _self.useMandatoryForHotel : useMandatoryForHotel // ignore: cast_nullable_to_non_nullable
as int,useAccountNumber: null == useAccountNumber ? _self.useAccountNumber : useAccountNumber // ignore: cast_nullable_to_non_nullable
as int,freezecustomerparamsinapp: null == freezecustomerparamsinapp ? _self.freezecustomerparamsinapp : freezecustomerparamsinapp // ignore: cast_nullable_to_non_nullable
as int,blockpayment: null == blockpayment ? _self.blockpayment : blockpayment // ignore: cast_nullable_to_non_nullable
as int,lcoBilltype: null == lcoBilltype ? _self.lcoBilltype : lcoBilltype // ignore: cast_nullable_to_non_nullable
as int,useLcoDeposit: null == useLcoDeposit ? _self.useLcoDeposit : useLcoDeposit // ignore: cast_nullable_to_non_nullable
as int,customerBilltype: null == customerBilltype ? _self.customerBilltype : customerBilltype // ignore: cast_nullable_to_non_nullable
as int,autoReceiptNumber: null == autoReceiptNumber ? _self.autoReceiptNumber : autoReceiptNumber // ignore: cast_nullable_to_non_nullable
as int,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,allowTopUp: null == allowTopUp ? _self.allowTopUp : allowTopUp // ignore: cast_nullable_to_non_nullable
as int,showCafMobileValidation: null == showCafMobileValidation ? _self.showCafMobileValidation : showCafMobileValidation // ignore: cast_nullable_to_non_nullable
as int,stbPairing: null == stbPairing ? _self.stbPairing : stbPairing // ignore: cast_nullable_to_non_nullable
as int,stbUnpairing: null == stbUnpairing ? _self.stbUnpairing : stbUnpairing // ignore: cast_nullable_to_non_nullable
as int,showMiaAgreementUpload: null == showMiaAgreementUpload ? _self.showMiaAgreementUpload : showMiaAgreementUpload // ignore: cast_nullable_to_non_nullable
as int,acceptTermsConditions: null == acceptTermsConditions ? _self.acceptTermsConditions : acceptTermsConditions // ignore: cast_nullable_to_non_nullable
as int,agreementDetailsCount: null == agreementDetailsCount ? _self.agreementDetailsCount : agreementDetailsCount // ignore: cast_nullable_to_non_nullable
as int,accessDistributorWise: null == accessDistributorWise ? _self.accessDistributorWise : accessDistributorWise // ignore: cast_nullable_to_non_nullable
as int,isDirectLco: null == isDirectLco ? _self.isDirectLco : isDirectLco // ignore: cast_nullable_to_non_nullable
as int,isUnpaidlco: null == isUnpaidlco ? _self.isUnpaidlco : isUnpaidlco // ignore: cast_nullable_to_non_nullable
as int,appMenuFormat: null == appMenuFormat ? _self.appMenuFormat : appMenuFormat // ignore: cast_nullable_to_non_nullable
as String,invoicePaymentSearchLimit: null == invoicePaymentSearchLimit ? _self.invoicePaymentSearchLimit : invoicePaymentSearchLimit // ignore: cast_nullable_to_non_nullable
as int,lcoMobileNo: null == lcoMobileNo ? _self.lcoMobileNo : lcoMobileNo // ignore: cast_nullable_to_non_nullable
as String,patchInformation: null == patchInformation ? _self.patchInformation : patchInformation // ignore: cast_nullable_to_non_nullable
as String,recurringServiceEdit: null == recurringServiceEdit ? _self.recurringServiceEdit : recurringServiceEdit // ignore: cast_nullable_to_non_nullable
as int,showLcoComplaint: null == showLcoComplaint ? _self.showLcoComplaint : showLcoComplaint // ignore: cast_nullable_to_non_nullable
as int,depositAmount: null == depositAmount ? _self.depositAmount : depositAmount // ignore: cast_nullable_to_non_nullable
as double,showSerialVc: null == showSerialVc ? _self.showSerialVc : showSerialVc // ignore: cast_nullable_to_non_nullable
as int,showServiceExtension: null == showServiceExtension ? _self.showServiceExtension : showServiceExtension // ignore: cast_nullable_to_non_nullable
as int,editQuantity: null == editQuantity ? _self.editQuantity : editQuantity // ignore: cast_nullable_to_non_nullable
as int,enableBoxWisePayment: null == enableBoxWisePayment ? _self.enableBoxWisePayment : enableBoxWisePayment // ignore: cast_nullable_to_non_nullable
as int,baidLabel: freezed == baidLabel ? _self.baidLabel : baidLabel // ignore: cast_nullable_to_non_nullable
as String?,defaultCountry: freezed == defaultCountry ? _self.defaultCountry : defaultCountry // ignore: cast_nullable_to_non_nullable
as String?,defaultState: freezed == defaultState ? _self.defaultState : defaultState // ignore: cast_nullable_to_non_nullable
as int?,defaultDistrict: freezed == defaultDistrict ? _self.defaultDistrict : defaultDistrict // ignore: cast_nullable_to_non_nullable
as int?,defaultCity: freezed == defaultCity ? _self.defaultCity : defaultCity // ignore: cast_nullable_to_non_nullable
as int?,appTheme: freezed == appTheme ? _self.appTheme : appTheme // ignore: cast_nullable_to_non_nullable
as int?,appDashboard: freezed == appDashboard ? _self.appDashboard : appDashboard // ignore: cast_nullable_to_non_nullable
as int?,enableAadhaar: freezed == enableAadhaar ? _self.enableAadhaar : enableAadhaar // ignore: cast_nullable_to_non_nullable
as int?,lcoPayment: freezed == lcoPayment ? _self.lcoPayment : lcoPayment // ignore: cast_nullable_to_non_nullable
as int?,userNotifications: null == userNotifications ? _self.userNotifications : userNotifications // ignore: cast_nullable_to_non_nullable
as int,notifyCount: null == notifyCount ? _self.notifyCount : notifyCount // ignore: cast_nullable_to_non_nullable
as int,noteDuration: null == noteDuration ? _self.noteDuration : noteDuration // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LoginResponse].
extension LoginResponsePatterns on LoginResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginResponse value)  $default,){
final _that = this;
switch (_that) {
case _LoginResponse():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginResponse value)?  $default,){
final _that = this;
switch (_that) {
case _LoginResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'status_code')  int statusCode, @JsonKey(name: 'status_msg')  String statusMsg, @JsonKey(name: 'token')  String token, @JsonKey(name: 'dealerId')  int dealerId, @JsonKey(name: 'employeeId')  int employeeId, @JsonKey(name: 'userType')  String userType, @JsonKey(name: 'first_name')  String firstName, @JsonKey(name: 'last_name')  String lastName, @JsonKey(name: 'email')  String email, @JsonKey(name: 'phone')  String phone, @JsonKey(name: 'lcoCode')  String lcoCode, @JsonKey(name: 'business_name')  String businessName, @JsonKey(name: 'employeeParentType')  String employeeParentType, @JsonKey(name: 'employeeParentId')  String employeeParentId, @JsonKey(name: 'username')  String? username, @JsonKey(name: 'user_image')  String? logoImg, @JsonKey(name: 'address1')  String address1, @JsonKey(name: 'address2')  String address2, @JsonKey(name: 'address3')  String address3, @JsonKey(name: 'copy_rights')  String copyRights, @JsonKey(name: 'short_name')  String shortName, @JsonKey(name: 'pin_code')  String pinCode, @JsonKey(name: 'country')  String country, @JsonKey(name: 'state')  String state, @JsonKey(name: 'district')  String district, @JsonKey(name: 'city')  String city, @JsonKey(name: 'dob')  String dob, @JsonKey(name: 'adate')  String adate, @JsonKey(name: 'employeeName')  String employeeName, @JsonKey(name: 'lcoLocation')  String lcoLocation, @JsonKey(name: 'country_name')  String countryName, @JsonKey(name: 'useCRF')  int useCRF, @JsonKey(name: 'useCAF')  String useCAF, @JsonKey(name: 'useLastName')  int useLastName, @JsonKey(name: 'useDiscount')  int useDiscount, @JsonKey(name: 'useDataFromMasterTable')  int useDataFromMasterTable, @JsonKey(name: 'useMandatoryForHotel')  int useMandatoryForHotel, @JsonKey(name: 'useAccountNumber')  int useAccountNumber, @JsonKey(name: 'freezecustomerparamsinapp')  int freezecustomerparamsinapp, @JsonKey(name: 'blockpayment')  int blockpayment, @JsonKey(name: 'lco_billtype')  int lcoBilltype, @JsonKey(name: 'use_lco_deposits')  int useLcoDeposit, @JsonKey(name: 'customer_billtype')  int customerBilltype, @JsonKey(name: 'AUTO_RECEIPT_NUMBER')  int autoReceiptNumber, @JsonKey(name: 'CURRENCY_CODE')  String currencyCode, @JsonKey(name: 'allow_top_up')  int allowTopUp, @JsonKey(name: 'show_caf_mobile_validation')  int showCafMobileValidation, @JsonKey(name: 'stb_pairing')  int stbPairing, @JsonKey(name: 'stb_unpairing')  int stbUnpairing, @JsonKey(name: 'show_mia_agreement_upload')  int showMiaAgreementUpload, @JsonKey(name: 'accept_terms_condtions')  int acceptTermsConditions, @JsonKey(name: 'agreement_details_count')  int agreementDetailsCount, @JsonKey(name: 'access_distributor_wise')  int accessDistributorWise, @JsonKey(name: 'is_direct_lco')  int isDirectLco, @JsonKey(name: 'is_unpaidlco')  int isUnpaidlco, @JsonKey(name: 'appMenuFormat')  String appMenuFormat, @JsonKey(name: 'invoicepaymentsearchlimit')  int invoicePaymentSearchLimit, @JsonKey(name: 'lcoMobileNo')  String lcoMobileNo, @JsonKey(name: 'patch_information')  String patchInformation, @JsonKey(name: 'recurringServiceEdit')  int recurringServiceEdit, @JsonKey(name: 'showLcoComplaint')  int showLcoComplaint, @JsonKey(name: 'deposit_amount')  double depositAmount, @JsonKey(name: 'show_serial_vc')  int showSerialVc, @JsonKey(name: 'show_service_extension')  int showServiceExtension, @JsonKey(name: 'edit_quantity')  int editQuantity, @JsonKey(name: 'enable_box_wise_payment')  int enableBoxWisePayment, @JsonKey(name: 'baid_label')  String? baidLabel, @JsonKey(name: 'defaultCountry')  String? defaultCountry, @JsonKey(name: 'defaultState')  int? defaultState, @JsonKey(name: 'defaultDistrict')  int? defaultDistrict, @JsonKey(name: 'defaultCity')  int? defaultCity, @JsonKey(name: 'appTheme')  int? appTheme, @JsonKey(name: 'appDashboard')  int? appDashboard, @JsonKey(name: 'enableAadhaar')  int? enableAadhaar, @JsonKey(name: 'lcoPayment')  int? lcoPayment, @JsonKey(name: 'userNotifications')  int userNotifications, @JsonKey(name: 'notifyCount')  int notifyCount, @JsonKey(name: 'note_duration')  int noteDuration)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginResponse() when $default != null:
return $default(_that.statusCode,_that.statusMsg,_that.token,_that.dealerId,_that.employeeId,_that.userType,_that.firstName,_that.lastName,_that.email,_that.phone,_that.lcoCode,_that.businessName,_that.employeeParentType,_that.employeeParentId,_that.username,_that.logoImg,_that.address1,_that.address2,_that.address3,_that.copyRights,_that.shortName,_that.pinCode,_that.country,_that.state,_that.district,_that.city,_that.dob,_that.adate,_that.employeeName,_that.lcoLocation,_that.countryName,_that.useCRF,_that.useCAF,_that.useLastName,_that.useDiscount,_that.useDataFromMasterTable,_that.useMandatoryForHotel,_that.useAccountNumber,_that.freezecustomerparamsinapp,_that.blockpayment,_that.lcoBilltype,_that.useLcoDeposit,_that.customerBilltype,_that.autoReceiptNumber,_that.currencyCode,_that.allowTopUp,_that.showCafMobileValidation,_that.stbPairing,_that.stbUnpairing,_that.showMiaAgreementUpload,_that.acceptTermsConditions,_that.agreementDetailsCount,_that.accessDistributorWise,_that.isDirectLco,_that.isUnpaidlco,_that.appMenuFormat,_that.invoicePaymentSearchLimit,_that.lcoMobileNo,_that.patchInformation,_that.recurringServiceEdit,_that.showLcoComplaint,_that.depositAmount,_that.showSerialVc,_that.showServiceExtension,_that.editQuantity,_that.enableBoxWisePayment,_that.baidLabel,_that.defaultCountry,_that.defaultState,_that.defaultDistrict,_that.defaultCity,_that.appTheme,_that.appDashboard,_that.enableAadhaar,_that.lcoPayment,_that.userNotifications,_that.notifyCount,_that.noteDuration);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'status_code')  int statusCode, @JsonKey(name: 'status_msg')  String statusMsg, @JsonKey(name: 'token')  String token, @JsonKey(name: 'dealerId')  int dealerId, @JsonKey(name: 'employeeId')  int employeeId, @JsonKey(name: 'userType')  String userType, @JsonKey(name: 'first_name')  String firstName, @JsonKey(name: 'last_name')  String lastName, @JsonKey(name: 'email')  String email, @JsonKey(name: 'phone')  String phone, @JsonKey(name: 'lcoCode')  String lcoCode, @JsonKey(name: 'business_name')  String businessName, @JsonKey(name: 'employeeParentType')  String employeeParentType, @JsonKey(name: 'employeeParentId')  String employeeParentId, @JsonKey(name: 'username')  String? username, @JsonKey(name: 'user_image')  String? logoImg, @JsonKey(name: 'address1')  String address1, @JsonKey(name: 'address2')  String address2, @JsonKey(name: 'address3')  String address3, @JsonKey(name: 'copy_rights')  String copyRights, @JsonKey(name: 'short_name')  String shortName, @JsonKey(name: 'pin_code')  String pinCode, @JsonKey(name: 'country')  String country, @JsonKey(name: 'state')  String state, @JsonKey(name: 'district')  String district, @JsonKey(name: 'city')  String city, @JsonKey(name: 'dob')  String dob, @JsonKey(name: 'adate')  String adate, @JsonKey(name: 'employeeName')  String employeeName, @JsonKey(name: 'lcoLocation')  String lcoLocation, @JsonKey(name: 'country_name')  String countryName, @JsonKey(name: 'useCRF')  int useCRF, @JsonKey(name: 'useCAF')  String useCAF, @JsonKey(name: 'useLastName')  int useLastName, @JsonKey(name: 'useDiscount')  int useDiscount, @JsonKey(name: 'useDataFromMasterTable')  int useDataFromMasterTable, @JsonKey(name: 'useMandatoryForHotel')  int useMandatoryForHotel, @JsonKey(name: 'useAccountNumber')  int useAccountNumber, @JsonKey(name: 'freezecustomerparamsinapp')  int freezecustomerparamsinapp, @JsonKey(name: 'blockpayment')  int blockpayment, @JsonKey(name: 'lco_billtype')  int lcoBilltype, @JsonKey(name: 'use_lco_deposits')  int useLcoDeposit, @JsonKey(name: 'customer_billtype')  int customerBilltype, @JsonKey(name: 'AUTO_RECEIPT_NUMBER')  int autoReceiptNumber, @JsonKey(name: 'CURRENCY_CODE')  String currencyCode, @JsonKey(name: 'allow_top_up')  int allowTopUp, @JsonKey(name: 'show_caf_mobile_validation')  int showCafMobileValidation, @JsonKey(name: 'stb_pairing')  int stbPairing, @JsonKey(name: 'stb_unpairing')  int stbUnpairing, @JsonKey(name: 'show_mia_agreement_upload')  int showMiaAgreementUpload, @JsonKey(name: 'accept_terms_condtions')  int acceptTermsConditions, @JsonKey(name: 'agreement_details_count')  int agreementDetailsCount, @JsonKey(name: 'access_distributor_wise')  int accessDistributorWise, @JsonKey(name: 'is_direct_lco')  int isDirectLco, @JsonKey(name: 'is_unpaidlco')  int isUnpaidlco, @JsonKey(name: 'appMenuFormat')  String appMenuFormat, @JsonKey(name: 'invoicepaymentsearchlimit')  int invoicePaymentSearchLimit, @JsonKey(name: 'lcoMobileNo')  String lcoMobileNo, @JsonKey(name: 'patch_information')  String patchInformation, @JsonKey(name: 'recurringServiceEdit')  int recurringServiceEdit, @JsonKey(name: 'showLcoComplaint')  int showLcoComplaint, @JsonKey(name: 'deposit_amount')  double depositAmount, @JsonKey(name: 'show_serial_vc')  int showSerialVc, @JsonKey(name: 'show_service_extension')  int showServiceExtension, @JsonKey(name: 'edit_quantity')  int editQuantity, @JsonKey(name: 'enable_box_wise_payment')  int enableBoxWisePayment, @JsonKey(name: 'baid_label')  String? baidLabel, @JsonKey(name: 'defaultCountry')  String? defaultCountry, @JsonKey(name: 'defaultState')  int? defaultState, @JsonKey(name: 'defaultDistrict')  int? defaultDistrict, @JsonKey(name: 'defaultCity')  int? defaultCity, @JsonKey(name: 'appTheme')  int? appTheme, @JsonKey(name: 'appDashboard')  int? appDashboard, @JsonKey(name: 'enableAadhaar')  int? enableAadhaar, @JsonKey(name: 'lcoPayment')  int? lcoPayment, @JsonKey(name: 'userNotifications')  int userNotifications, @JsonKey(name: 'notifyCount')  int notifyCount, @JsonKey(name: 'note_duration')  int noteDuration)  $default,) {final _that = this;
switch (_that) {
case _LoginResponse():
return $default(_that.statusCode,_that.statusMsg,_that.token,_that.dealerId,_that.employeeId,_that.userType,_that.firstName,_that.lastName,_that.email,_that.phone,_that.lcoCode,_that.businessName,_that.employeeParentType,_that.employeeParentId,_that.username,_that.logoImg,_that.address1,_that.address2,_that.address3,_that.copyRights,_that.shortName,_that.pinCode,_that.country,_that.state,_that.district,_that.city,_that.dob,_that.adate,_that.employeeName,_that.lcoLocation,_that.countryName,_that.useCRF,_that.useCAF,_that.useLastName,_that.useDiscount,_that.useDataFromMasterTable,_that.useMandatoryForHotel,_that.useAccountNumber,_that.freezecustomerparamsinapp,_that.blockpayment,_that.lcoBilltype,_that.useLcoDeposit,_that.customerBilltype,_that.autoReceiptNumber,_that.currencyCode,_that.allowTopUp,_that.showCafMobileValidation,_that.stbPairing,_that.stbUnpairing,_that.showMiaAgreementUpload,_that.acceptTermsConditions,_that.agreementDetailsCount,_that.accessDistributorWise,_that.isDirectLco,_that.isUnpaidlco,_that.appMenuFormat,_that.invoicePaymentSearchLimit,_that.lcoMobileNo,_that.patchInformation,_that.recurringServiceEdit,_that.showLcoComplaint,_that.depositAmount,_that.showSerialVc,_that.showServiceExtension,_that.editQuantity,_that.enableBoxWisePayment,_that.baidLabel,_that.defaultCountry,_that.defaultState,_that.defaultDistrict,_that.defaultCity,_that.appTheme,_that.appDashboard,_that.enableAadhaar,_that.lcoPayment,_that.userNotifications,_that.notifyCount,_that.noteDuration);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'status_code')  int statusCode, @JsonKey(name: 'status_msg')  String statusMsg, @JsonKey(name: 'token')  String token, @JsonKey(name: 'dealerId')  int dealerId, @JsonKey(name: 'employeeId')  int employeeId, @JsonKey(name: 'userType')  String userType, @JsonKey(name: 'first_name')  String firstName, @JsonKey(name: 'last_name')  String lastName, @JsonKey(name: 'email')  String email, @JsonKey(name: 'phone')  String phone, @JsonKey(name: 'lcoCode')  String lcoCode, @JsonKey(name: 'business_name')  String businessName, @JsonKey(name: 'employeeParentType')  String employeeParentType, @JsonKey(name: 'employeeParentId')  String employeeParentId, @JsonKey(name: 'username')  String? username, @JsonKey(name: 'user_image')  String? logoImg, @JsonKey(name: 'address1')  String address1, @JsonKey(name: 'address2')  String address2, @JsonKey(name: 'address3')  String address3, @JsonKey(name: 'copy_rights')  String copyRights, @JsonKey(name: 'short_name')  String shortName, @JsonKey(name: 'pin_code')  String pinCode, @JsonKey(name: 'country')  String country, @JsonKey(name: 'state')  String state, @JsonKey(name: 'district')  String district, @JsonKey(name: 'city')  String city, @JsonKey(name: 'dob')  String dob, @JsonKey(name: 'adate')  String adate, @JsonKey(name: 'employeeName')  String employeeName, @JsonKey(name: 'lcoLocation')  String lcoLocation, @JsonKey(name: 'country_name')  String countryName, @JsonKey(name: 'useCRF')  int useCRF, @JsonKey(name: 'useCAF')  String useCAF, @JsonKey(name: 'useLastName')  int useLastName, @JsonKey(name: 'useDiscount')  int useDiscount, @JsonKey(name: 'useDataFromMasterTable')  int useDataFromMasterTable, @JsonKey(name: 'useMandatoryForHotel')  int useMandatoryForHotel, @JsonKey(name: 'useAccountNumber')  int useAccountNumber, @JsonKey(name: 'freezecustomerparamsinapp')  int freezecustomerparamsinapp, @JsonKey(name: 'blockpayment')  int blockpayment, @JsonKey(name: 'lco_billtype')  int lcoBilltype, @JsonKey(name: 'use_lco_deposits')  int useLcoDeposit, @JsonKey(name: 'customer_billtype')  int customerBilltype, @JsonKey(name: 'AUTO_RECEIPT_NUMBER')  int autoReceiptNumber, @JsonKey(name: 'CURRENCY_CODE')  String currencyCode, @JsonKey(name: 'allow_top_up')  int allowTopUp, @JsonKey(name: 'show_caf_mobile_validation')  int showCafMobileValidation, @JsonKey(name: 'stb_pairing')  int stbPairing, @JsonKey(name: 'stb_unpairing')  int stbUnpairing, @JsonKey(name: 'show_mia_agreement_upload')  int showMiaAgreementUpload, @JsonKey(name: 'accept_terms_condtions')  int acceptTermsConditions, @JsonKey(name: 'agreement_details_count')  int agreementDetailsCount, @JsonKey(name: 'access_distributor_wise')  int accessDistributorWise, @JsonKey(name: 'is_direct_lco')  int isDirectLco, @JsonKey(name: 'is_unpaidlco')  int isUnpaidlco, @JsonKey(name: 'appMenuFormat')  String appMenuFormat, @JsonKey(name: 'invoicepaymentsearchlimit')  int invoicePaymentSearchLimit, @JsonKey(name: 'lcoMobileNo')  String lcoMobileNo, @JsonKey(name: 'patch_information')  String patchInformation, @JsonKey(name: 'recurringServiceEdit')  int recurringServiceEdit, @JsonKey(name: 'showLcoComplaint')  int showLcoComplaint, @JsonKey(name: 'deposit_amount')  double depositAmount, @JsonKey(name: 'show_serial_vc')  int showSerialVc, @JsonKey(name: 'show_service_extension')  int showServiceExtension, @JsonKey(name: 'edit_quantity')  int editQuantity, @JsonKey(name: 'enable_box_wise_payment')  int enableBoxWisePayment, @JsonKey(name: 'baid_label')  String? baidLabel, @JsonKey(name: 'defaultCountry')  String? defaultCountry, @JsonKey(name: 'defaultState')  int? defaultState, @JsonKey(name: 'defaultDistrict')  int? defaultDistrict, @JsonKey(name: 'defaultCity')  int? defaultCity, @JsonKey(name: 'appTheme')  int? appTheme, @JsonKey(name: 'appDashboard')  int? appDashboard, @JsonKey(name: 'enableAadhaar')  int? enableAadhaar, @JsonKey(name: 'lcoPayment')  int? lcoPayment, @JsonKey(name: 'userNotifications')  int userNotifications, @JsonKey(name: 'notifyCount')  int notifyCount, @JsonKey(name: 'note_duration')  int noteDuration)?  $default,) {final _that = this;
switch (_that) {
case _LoginResponse() when $default != null:
return $default(_that.statusCode,_that.statusMsg,_that.token,_that.dealerId,_that.employeeId,_that.userType,_that.firstName,_that.lastName,_that.email,_that.phone,_that.lcoCode,_that.businessName,_that.employeeParentType,_that.employeeParentId,_that.username,_that.logoImg,_that.address1,_that.address2,_that.address3,_that.copyRights,_that.shortName,_that.pinCode,_that.country,_that.state,_that.district,_that.city,_that.dob,_that.adate,_that.employeeName,_that.lcoLocation,_that.countryName,_that.useCRF,_that.useCAF,_that.useLastName,_that.useDiscount,_that.useDataFromMasterTable,_that.useMandatoryForHotel,_that.useAccountNumber,_that.freezecustomerparamsinapp,_that.blockpayment,_that.lcoBilltype,_that.useLcoDeposit,_that.customerBilltype,_that.autoReceiptNumber,_that.currencyCode,_that.allowTopUp,_that.showCafMobileValidation,_that.stbPairing,_that.stbUnpairing,_that.showMiaAgreementUpload,_that.acceptTermsConditions,_that.agreementDetailsCount,_that.accessDistributorWise,_that.isDirectLco,_that.isUnpaidlco,_that.appMenuFormat,_that.invoicePaymentSearchLimit,_that.lcoMobileNo,_that.patchInformation,_that.recurringServiceEdit,_that.showLcoComplaint,_that.depositAmount,_that.showSerialVc,_that.showServiceExtension,_that.editQuantity,_that.enableBoxWisePayment,_that.baidLabel,_that.defaultCountry,_that.defaultState,_that.defaultDistrict,_that.defaultCity,_that.appTheme,_that.appDashboard,_that.enableAadhaar,_that.lcoPayment,_that.userNotifications,_that.notifyCount,_that.noteDuration);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoginResponse implements LoginResponse {
  const _LoginResponse({@JsonKey(name: 'status_code') this.statusCode = 0, @JsonKey(name: 'status_msg') this.statusMsg = '', @JsonKey(name: 'token') this.token = '', @JsonKey(name: 'dealerId') this.dealerId = 0, @JsonKey(name: 'employeeId') this.employeeId = 0, @JsonKey(name: 'userType') this.userType = '', @JsonKey(name: 'first_name') this.firstName = '', @JsonKey(name: 'last_name') this.lastName = '', @JsonKey(name: 'email') this.email = '', @JsonKey(name: 'phone') this.phone = '', @JsonKey(name: 'lcoCode') this.lcoCode = '', @JsonKey(name: 'business_name') this.businessName = '', @JsonKey(name: 'employeeParentType') this.employeeParentType = '', @JsonKey(name: 'employeeParentId') this.employeeParentId = '', @JsonKey(name: 'username') this.username, @JsonKey(name: 'user_image') this.logoImg, @JsonKey(name: 'address1') this.address1 = '', @JsonKey(name: 'address2') this.address2 = '', @JsonKey(name: 'address3') this.address3 = '', @JsonKey(name: 'copy_rights') this.copyRights = '', @JsonKey(name: 'short_name') this.shortName = '', @JsonKey(name: 'pin_code') this.pinCode = '', @JsonKey(name: 'country') this.country = '', @JsonKey(name: 'state') this.state = '', @JsonKey(name: 'district') this.district = '', @JsonKey(name: 'city') this.city = '', @JsonKey(name: 'dob') this.dob = '', @JsonKey(name: 'adate') this.adate = '', @JsonKey(name: 'employeeName') this.employeeName = '', @JsonKey(name: 'lcoLocation') this.lcoLocation = '', @JsonKey(name: 'country_name') this.countryName = '', @JsonKey(name: 'useCRF') this.useCRF = 0, @JsonKey(name: 'useCAF') this.useCAF = '0', @JsonKey(name: 'useLastName') this.useLastName = 0, @JsonKey(name: 'useDiscount') this.useDiscount = 0, @JsonKey(name: 'useDataFromMasterTable') this.useDataFromMasterTable = 0, @JsonKey(name: 'useMandatoryForHotel') this.useMandatoryForHotel = 0, @JsonKey(name: 'useAccountNumber') this.useAccountNumber = 0, @JsonKey(name: 'freezecustomerparamsinapp') this.freezecustomerparamsinapp = 0, @JsonKey(name: 'blockpayment') this.blockpayment = 0, @JsonKey(name: 'lco_billtype') this.lcoBilltype = 0, @JsonKey(name: 'use_lco_deposits') this.useLcoDeposit = 0, @JsonKey(name: 'customer_billtype') this.customerBilltype = 0, @JsonKey(name: 'AUTO_RECEIPT_NUMBER') this.autoReceiptNumber = 0, @JsonKey(name: 'CURRENCY_CODE') this.currencyCode = 'INR', @JsonKey(name: 'allow_top_up') this.allowTopUp = 0, @JsonKey(name: 'show_caf_mobile_validation') this.showCafMobileValidation = 0, @JsonKey(name: 'stb_pairing') this.stbPairing = 0, @JsonKey(name: 'stb_unpairing') this.stbUnpairing = 0, @JsonKey(name: 'show_mia_agreement_upload') this.showMiaAgreementUpload = 0, @JsonKey(name: 'accept_terms_condtions') this.acceptTermsConditions = 0, @JsonKey(name: 'agreement_details_count') this.agreementDetailsCount = 0, @JsonKey(name: 'access_distributor_wise') this.accessDistributorWise = 0, @JsonKey(name: 'is_direct_lco') this.isDirectLco = 0, @JsonKey(name: 'is_unpaidlco') this.isUnpaidlco = 0, @JsonKey(name: 'appMenuFormat') this.appMenuFormat = 'DEFAULT', @JsonKey(name: 'invoicepaymentsearchlimit') this.invoicePaymentSearchLimit = 0, @JsonKey(name: 'lcoMobileNo') this.lcoMobileNo = '', @JsonKey(name: 'patch_information') this.patchInformation = '', @JsonKey(name: 'recurringServiceEdit') this.recurringServiceEdit = 0, @JsonKey(name: 'showLcoComplaint') this.showLcoComplaint = 0, @JsonKey(name: 'deposit_amount') this.depositAmount = 0.0, @JsonKey(name: 'show_serial_vc') this.showSerialVc = 1, @JsonKey(name: 'show_service_extension') this.showServiceExtension = 0, @JsonKey(name: 'edit_quantity') this.editQuantity = 0, @JsonKey(name: 'enable_box_wise_payment') this.enableBoxWisePayment = 0, @JsonKey(name: 'baid_label') this.baidLabel, @JsonKey(name: 'defaultCountry') this.defaultCountry, @JsonKey(name: 'defaultState') this.defaultState, @JsonKey(name: 'defaultDistrict') this.defaultDistrict, @JsonKey(name: 'defaultCity') this.defaultCity, @JsonKey(name: 'appTheme') this.appTheme, @JsonKey(name: 'appDashboard') this.appDashboard, @JsonKey(name: 'enableAadhaar') this.enableAadhaar, @JsonKey(name: 'lcoPayment') this.lcoPayment, @JsonKey(name: 'userNotifications') this.userNotifications = 0, @JsonKey(name: 'notifyCount') this.notifyCount = 0, @JsonKey(name: 'note_duration') this.noteDuration = 0});
  factory _LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);

@override@JsonKey(name: 'status_code') final  int statusCode;
@override@JsonKey(name: 'status_msg') final  String statusMsg;
@override@JsonKey(name: 'token') final  String token;
@override@JsonKey(name: 'dealerId') final  int dealerId;
@override@JsonKey(name: 'employeeId') final  int employeeId;
@override@JsonKey(name: 'userType') final  String userType;
@override@JsonKey(name: 'first_name') final  String firstName;
@override@JsonKey(name: 'last_name') final  String lastName;
@override@JsonKey(name: 'email') final  String email;
@override@JsonKey(name: 'phone') final  String phone;
@override@JsonKey(name: 'lcoCode') final  String lcoCode;
@override@JsonKey(name: 'business_name') final  String businessName;
@override@JsonKey(name: 'employeeParentType') final  String employeeParentType;
@override@JsonKey(name: 'employeeParentId') final  String employeeParentId;
@override@JsonKey(name: 'username') final  String? username;
@override@JsonKey(name: 'user_image') final  String? logoImg;
@override@JsonKey(name: 'address1') final  String address1;
@override@JsonKey(name: 'address2') final  String address2;
@override@JsonKey(name: 'address3') final  String address3;
@override@JsonKey(name: 'copy_rights') final  String copyRights;
@override@JsonKey(name: 'short_name') final  String shortName;
@override@JsonKey(name: 'pin_code') final  String pinCode;
@override@JsonKey(name: 'country') final  String country;
@override@JsonKey(name: 'state') final  String state;
@override@JsonKey(name: 'district') final  String district;
@override@JsonKey(name: 'city') final  String city;
@override@JsonKey(name: 'dob') final  String dob;
@override@JsonKey(name: 'adate') final  String adate;
@override@JsonKey(name: 'employeeName') final  String employeeName;
@override@JsonKey(name: 'lcoLocation') final  String lcoLocation;
@override@JsonKey(name: 'country_name') final  String countryName;
// Config flags
@override@JsonKey(name: 'useCRF') final  int useCRF;
@override@JsonKey(name: 'useCAF') final  String useCAF;
@override@JsonKey(name: 'useLastName') final  int useLastName;
@override@JsonKey(name: 'useDiscount') final  int useDiscount;
@override@JsonKey(name: 'useDataFromMasterTable') final  int useDataFromMasterTable;
@override@JsonKey(name: 'useMandatoryForHotel') final  int useMandatoryForHotel;
@override@JsonKey(name: 'useAccountNumber') final  int useAccountNumber;
@override@JsonKey(name: 'freezecustomerparamsinapp') final  int freezecustomerparamsinapp;
@override@JsonKey(name: 'blockpayment') final  int blockpayment;
@override@JsonKey(name: 'lco_billtype') final  int lcoBilltype;
@override@JsonKey(name: 'use_lco_deposits') final  int useLcoDeposit;
@override@JsonKey(name: 'customer_billtype') final  int customerBilltype;
@override@JsonKey(name: 'AUTO_RECEIPT_NUMBER') final  int autoReceiptNumber;
@override@JsonKey(name: 'CURRENCY_CODE') final  String currencyCode;
@override@JsonKey(name: 'allow_top_up') final  int allowTopUp;
@override@JsonKey(name: 'show_caf_mobile_validation') final  int showCafMobileValidation;
@override@JsonKey(name: 'stb_pairing') final  int stbPairing;
@override@JsonKey(name: 'stb_unpairing') final  int stbUnpairing;
@override@JsonKey(name: 'show_mia_agreement_upload') final  int showMiaAgreementUpload;
@override@JsonKey(name: 'accept_terms_condtions') final  int acceptTermsConditions;
@override@JsonKey(name: 'agreement_details_count') final  int agreementDetailsCount;
@override@JsonKey(name: 'access_distributor_wise') final  int accessDistributorWise;
@override@JsonKey(name: 'is_direct_lco') final  int isDirectLco;
@override@JsonKey(name: 'is_unpaidlco') final  int isUnpaidlco;
@override@JsonKey(name: 'appMenuFormat') final  String appMenuFormat;
@override@JsonKey(name: 'invoicepaymentsearchlimit') final  int invoicePaymentSearchLimit;
@override@JsonKey(name: 'lcoMobileNo') final  String lcoMobileNo;
@override@JsonKey(name: 'patch_information') final  String patchInformation;
@override@JsonKey(name: 'recurringServiceEdit') final  int recurringServiceEdit;
@override@JsonKey(name: 'showLcoComplaint') final  int showLcoComplaint;
@override@JsonKey(name: 'deposit_amount') final  double depositAmount;
@override@JsonKey(name: 'show_serial_vc') final  int showSerialVc;
@override@JsonKey(name: 'show_service_extension') final  int showServiceExtension;
@override@JsonKey(name: 'edit_quantity') final  int editQuantity;
@override@JsonKey(name: 'enable_box_wise_payment') final  int enableBoxWisePayment;
@override@JsonKey(name: 'baid_label') final  String? baidLabel;
// Nullable location defaults
@override@JsonKey(name: 'defaultCountry') final  String? defaultCountry;
@override@JsonKey(name: 'defaultState') final  int? defaultState;
@override@JsonKey(name: 'defaultDistrict') final  int? defaultDistrict;
@override@JsonKey(name: 'defaultCity') final  int? defaultCity;
// Nullable config flags
@override@JsonKey(name: 'appTheme') final  int? appTheme;
@override@JsonKey(name: 'appDashboard') final  int? appDashboard;
@override@JsonKey(name: 'enableAadhaar') final  int? enableAadhaar;
@override@JsonKey(name: 'lcoPayment') final  int? lcoPayment;
// Notification fields
@override@JsonKey(name: 'userNotifications') final  int userNotifications;
@override@JsonKey(name: 'notifyCount') final  int notifyCount;
@override@JsonKey(name: 'note_duration') final  int noteDuration;

/// Create a copy of LoginResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginResponseCopyWith<_LoginResponse> get copyWith => __$LoginResponseCopyWithImpl<_LoginResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoginResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginResponse&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.statusMsg, statusMsg) || other.statusMsg == statusMsg)&&(identical(other.token, token) || other.token == token)&&(identical(other.dealerId, dealerId) || other.dealerId == dealerId)&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.userType, userType) || other.userType == userType)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.lcoCode, lcoCode) || other.lcoCode == lcoCode)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.employeeParentType, employeeParentType) || other.employeeParentType == employeeParentType)&&(identical(other.employeeParentId, employeeParentId) || other.employeeParentId == employeeParentId)&&(identical(other.username, username) || other.username == username)&&(identical(other.logoImg, logoImg) || other.logoImg == logoImg)&&(identical(other.address1, address1) || other.address1 == address1)&&(identical(other.address2, address2) || other.address2 == address2)&&(identical(other.address3, address3) || other.address3 == address3)&&(identical(other.copyRights, copyRights) || other.copyRights == copyRights)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.pinCode, pinCode) || other.pinCode == pinCode)&&(identical(other.country, country) || other.country == country)&&(identical(other.state, state) || other.state == state)&&(identical(other.district, district) || other.district == district)&&(identical(other.city, city) || other.city == city)&&(identical(other.dob, dob) || other.dob == dob)&&(identical(other.adate, adate) || other.adate == adate)&&(identical(other.employeeName, employeeName) || other.employeeName == employeeName)&&(identical(other.lcoLocation, lcoLocation) || other.lcoLocation == lcoLocation)&&(identical(other.countryName, countryName) || other.countryName == countryName)&&(identical(other.useCRF, useCRF) || other.useCRF == useCRF)&&(identical(other.useCAF, useCAF) || other.useCAF == useCAF)&&(identical(other.useLastName, useLastName) || other.useLastName == useLastName)&&(identical(other.useDiscount, useDiscount) || other.useDiscount == useDiscount)&&(identical(other.useDataFromMasterTable, useDataFromMasterTable) || other.useDataFromMasterTable == useDataFromMasterTable)&&(identical(other.useMandatoryForHotel, useMandatoryForHotel) || other.useMandatoryForHotel == useMandatoryForHotel)&&(identical(other.useAccountNumber, useAccountNumber) || other.useAccountNumber == useAccountNumber)&&(identical(other.freezecustomerparamsinapp, freezecustomerparamsinapp) || other.freezecustomerparamsinapp == freezecustomerparamsinapp)&&(identical(other.blockpayment, blockpayment) || other.blockpayment == blockpayment)&&(identical(other.lcoBilltype, lcoBilltype) || other.lcoBilltype == lcoBilltype)&&(identical(other.useLcoDeposit, useLcoDeposit) || other.useLcoDeposit == useLcoDeposit)&&(identical(other.customerBilltype, customerBilltype) || other.customerBilltype == customerBilltype)&&(identical(other.autoReceiptNumber, autoReceiptNumber) || other.autoReceiptNumber == autoReceiptNumber)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.allowTopUp, allowTopUp) || other.allowTopUp == allowTopUp)&&(identical(other.showCafMobileValidation, showCafMobileValidation) || other.showCafMobileValidation == showCafMobileValidation)&&(identical(other.stbPairing, stbPairing) || other.stbPairing == stbPairing)&&(identical(other.stbUnpairing, stbUnpairing) || other.stbUnpairing == stbUnpairing)&&(identical(other.showMiaAgreementUpload, showMiaAgreementUpload) || other.showMiaAgreementUpload == showMiaAgreementUpload)&&(identical(other.acceptTermsConditions, acceptTermsConditions) || other.acceptTermsConditions == acceptTermsConditions)&&(identical(other.agreementDetailsCount, agreementDetailsCount) || other.agreementDetailsCount == agreementDetailsCount)&&(identical(other.accessDistributorWise, accessDistributorWise) || other.accessDistributorWise == accessDistributorWise)&&(identical(other.isDirectLco, isDirectLco) || other.isDirectLco == isDirectLco)&&(identical(other.isUnpaidlco, isUnpaidlco) || other.isUnpaidlco == isUnpaidlco)&&(identical(other.appMenuFormat, appMenuFormat) || other.appMenuFormat == appMenuFormat)&&(identical(other.invoicePaymentSearchLimit, invoicePaymentSearchLimit) || other.invoicePaymentSearchLimit == invoicePaymentSearchLimit)&&(identical(other.lcoMobileNo, lcoMobileNo) || other.lcoMobileNo == lcoMobileNo)&&(identical(other.patchInformation, patchInformation) || other.patchInformation == patchInformation)&&(identical(other.recurringServiceEdit, recurringServiceEdit) || other.recurringServiceEdit == recurringServiceEdit)&&(identical(other.showLcoComplaint, showLcoComplaint) || other.showLcoComplaint == showLcoComplaint)&&(identical(other.depositAmount, depositAmount) || other.depositAmount == depositAmount)&&(identical(other.showSerialVc, showSerialVc) || other.showSerialVc == showSerialVc)&&(identical(other.showServiceExtension, showServiceExtension) || other.showServiceExtension == showServiceExtension)&&(identical(other.editQuantity, editQuantity) || other.editQuantity == editQuantity)&&(identical(other.enableBoxWisePayment, enableBoxWisePayment) || other.enableBoxWisePayment == enableBoxWisePayment)&&(identical(other.baidLabel, baidLabel) || other.baidLabel == baidLabel)&&(identical(other.defaultCountry, defaultCountry) || other.defaultCountry == defaultCountry)&&(identical(other.defaultState, defaultState) || other.defaultState == defaultState)&&(identical(other.defaultDistrict, defaultDistrict) || other.defaultDistrict == defaultDistrict)&&(identical(other.defaultCity, defaultCity) || other.defaultCity == defaultCity)&&(identical(other.appTheme, appTheme) || other.appTheme == appTheme)&&(identical(other.appDashboard, appDashboard) || other.appDashboard == appDashboard)&&(identical(other.enableAadhaar, enableAadhaar) || other.enableAadhaar == enableAadhaar)&&(identical(other.lcoPayment, lcoPayment) || other.lcoPayment == lcoPayment)&&(identical(other.userNotifications, userNotifications) || other.userNotifications == userNotifications)&&(identical(other.notifyCount, notifyCount) || other.notifyCount == notifyCount)&&(identical(other.noteDuration, noteDuration) || other.noteDuration == noteDuration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,statusCode,statusMsg,token,dealerId,employeeId,userType,firstName,lastName,email,phone,lcoCode,businessName,employeeParentType,employeeParentId,username,logoImg,address1,address2,address3,copyRights,shortName,pinCode,country,state,district,city,dob,adate,employeeName,lcoLocation,countryName,useCRF,useCAF,useLastName,useDiscount,useDataFromMasterTable,useMandatoryForHotel,useAccountNumber,freezecustomerparamsinapp,blockpayment,lcoBilltype,useLcoDeposit,customerBilltype,autoReceiptNumber,currencyCode,allowTopUp,showCafMobileValidation,stbPairing,stbUnpairing,showMiaAgreementUpload,acceptTermsConditions,agreementDetailsCount,accessDistributorWise,isDirectLco,isUnpaidlco,appMenuFormat,invoicePaymentSearchLimit,lcoMobileNo,patchInformation,recurringServiceEdit,showLcoComplaint,depositAmount,showSerialVc,showServiceExtension,editQuantity,enableBoxWisePayment,baidLabel,defaultCountry,defaultState,defaultDistrict,defaultCity,appTheme,appDashboard,enableAadhaar,lcoPayment,userNotifications,notifyCount,noteDuration]);

@override
String toString() {
  return 'LoginResponse(statusCode: $statusCode, statusMsg: $statusMsg, token: $token, dealerId: $dealerId, employeeId: $employeeId, userType: $userType, firstName: $firstName, lastName: $lastName, email: $email, phone: $phone, lcoCode: $lcoCode, businessName: $businessName, employeeParentType: $employeeParentType, employeeParentId: $employeeParentId, username: $username, logoImg: $logoImg, address1: $address1, address2: $address2, address3: $address3, copyRights: $copyRights, shortName: $shortName, pinCode: $pinCode, country: $country, state: $state, district: $district, city: $city, dob: $dob, adate: $adate, employeeName: $employeeName, lcoLocation: $lcoLocation, countryName: $countryName, useCRF: $useCRF, useCAF: $useCAF, useLastName: $useLastName, useDiscount: $useDiscount, useDataFromMasterTable: $useDataFromMasterTable, useMandatoryForHotel: $useMandatoryForHotel, useAccountNumber: $useAccountNumber, freezecustomerparamsinapp: $freezecustomerparamsinapp, blockpayment: $blockpayment, lcoBilltype: $lcoBilltype, useLcoDeposit: $useLcoDeposit, customerBilltype: $customerBilltype, autoReceiptNumber: $autoReceiptNumber, currencyCode: $currencyCode, allowTopUp: $allowTopUp, showCafMobileValidation: $showCafMobileValidation, stbPairing: $stbPairing, stbUnpairing: $stbUnpairing, showMiaAgreementUpload: $showMiaAgreementUpload, acceptTermsConditions: $acceptTermsConditions, agreementDetailsCount: $agreementDetailsCount, accessDistributorWise: $accessDistributorWise, isDirectLco: $isDirectLco, isUnpaidlco: $isUnpaidlco, appMenuFormat: $appMenuFormat, invoicePaymentSearchLimit: $invoicePaymentSearchLimit, lcoMobileNo: $lcoMobileNo, patchInformation: $patchInformation, recurringServiceEdit: $recurringServiceEdit, showLcoComplaint: $showLcoComplaint, depositAmount: $depositAmount, showSerialVc: $showSerialVc, showServiceExtension: $showServiceExtension, editQuantity: $editQuantity, enableBoxWisePayment: $enableBoxWisePayment, baidLabel: $baidLabel, defaultCountry: $defaultCountry, defaultState: $defaultState, defaultDistrict: $defaultDistrict, defaultCity: $defaultCity, appTheme: $appTheme, appDashboard: $appDashboard, enableAadhaar: $enableAadhaar, lcoPayment: $lcoPayment, userNotifications: $userNotifications, notifyCount: $notifyCount, noteDuration: $noteDuration)';
}


}

/// @nodoc
abstract mixin class _$LoginResponseCopyWith<$Res> implements $LoginResponseCopyWith<$Res> {
  factory _$LoginResponseCopyWith(_LoginResponse value, $Res Function(_LoginResponse) _then) = __$LoginResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'status_code') int statusCode,@JsonKey(name: 'status_msg') String statusMsg,@JsonKey(name: 'token') String token,@JsonKey(name: 'dealerId') int dealerId,@JsonKey(name: 'employeeId') int employeeId,@JsonKey(name: 'userType') String userType,@JsonKey(name: 'first_name') String firstName,@JsonKey(name: 'last_name') String lastName,@JsonKey(name: 'email') String email,@JsonKey(name: 'phone') String phone,@JsonKey(name: 'lcoCode') String lcoCode,@JsonKey(name: 'business_name') String businessName,@JsonKey(name: 'employeeParentType') String employeeParentType,@JsonKey(name: 'employeeParentId') String employeeParentId,@JsonKey(name: 'username') String? username,@JsonKey(name: 'user_image') String? logoImg,@JsonKey(name: 'address1') String address1,@JsonKey(name: 'address2') String address2,@JsonKey(name: 'address3') String address3,@JsonKey(name: 'copy_rights') String copyRights,@JsonKey(name: 'short_name') String shortName,@JsonKey(name: 'pin_code') String pinCode,@JsonKey(name: 'country') String country,@JsonKey(name: 'state') String state,@JsonKey(name: 'district') String district,@JsonKey(name: 'city') String city,@JsonKey(name: 'dob') String dob,@JsonKey(name: 'adate') String adate,@JsonKey(name: 'employeeName') String employeeName,@JsonKey(name: 'lcoLocation') String lcoLocation,@JsonKey(name: 'country_name') String countryName,@JsonKey(name: 'useCRF') int useCRF,@JsonKey(name: 'useCAF') String useCAF,@JsonKey(name: 'useLastName') int useLastName,@JsonKey(name: 'useDiscount') int useDiscount,@JsonKey(name: 'useDataFromMasterTable') int useDataFromMasterTable,@JsonKey(name: 'useMandatoryForHotel') int useMandatoryForHotel,@JsonKey(name: 'useAccountNumber') int useAccountNumber,@JsonKey(name: 'freezecustomerparamsinapp') int freezecustomerparamsinapp,@JsonKey(name: 'blockpayment') int blockpayment,@JsonKey(name: 'lco_billtype') int lcoBilltype,@JsonKey(name: 'use_lco_deposits') int useLcoDeposit,@JsonKey(name: 'customer_billtype') int customerBilltype,@JsonKey(name: 'AUTO_RECEIPT_NUMBER') int autoReceiptNumber,@JsonKey(name: 'CURRENCY_CODE') String currencyCode,@JsonKey(name: 'allow_top_up') int allowTopUp,@JsonKey(name: 'show_caf_mobile_validation') int showCafMobileValidation,@JsonKey(name: 'stb_pairing') int stbPairing,@JsonKey(name: 'stb_unpairing') int stbUnpairing,@JsonKey(name: 'show_mia_agreement_upload') int showMiaAgreementUpload,@JsonKey(name: 'accept_terms_condtions') int acceptTermsConditions,@JsonKey(name: 'agreement_details_count') int agreementDetailsCount,@JsonKey(name: 'access_distributor_wise') int accessDistributorWise,@JsonKey(name: 'is_direct_lco') int isDirectLco,@JsonKey(name: 'is_unpaidlco') int isUnpaidlco,@JsonKey(name: 'appMenuFormat') String appMenuFormat,@JsonKey(name: 'invoicepaymentsearchlimit') int invoicePaymentSearchLimit,@JsonKey(name: 'lcoMobileNo') String lcoMobileNo,@JsonKey(name: 'patch_information') String patchInformation,@JsonKey(name: 'recurringServiceEdit') int recurringServiceEdit,@JsonKey(name: 'showLcoComplaint') int showLcoComplaint,@JsonKey(name: 'deposit_amount') double depositAmount,@JsonKey(name: 'show_serial_vc') int showSerialVc,@JsonKey(name: 'show_service_extension') int showServiceExtension,@JsonKey(name: 'edit_quantity') int editQuantity,@JsonKey(name: 'enable_box_wise_payment') int enableBoxWisePayment,@JsonKey(name: 'baid_label') String? baidLabel,@JsonKey(name: 'defaultCountry') String? defaultCountry,@JsonKey(name: 'defaultState') int? defaultState,@JsonKey(name: 'defaultDistrict') int? defaultDistrict,@JsonKey(name: 'defaultCity') int? defaultCity,@JsonKey(name: 'appTheme') int? appTheme,@JsonKey(name: 'appDashboard') int? appDashboard,@JsonKey(name: 'enableAadhaar') int? enableAadhaar,@JsonKey(name: 'lcoPayment') int? lcoPayment,@JsonKey(name: 'userNotifications') int userNotifications,@JsonKey(name: 'notifyCount') int notifyCount,@JsonKey(name: 'note_duration') int noteDuration
});




}
/// @nodoc
class __$LoginResponseCopyWithImpl<$Res>
    implements _$LoginResponseCopyWith<$Res> {
  __$LoginResponseCopyWithImpl(this._self, this._then);

  final _LoginResponse _self;
  final $Res Function(_LoginResponse) _then;

/// Create a copy of LoginResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? statusCode = null,Object? statusMsg = null,Object? token = null,Object? dealerId = null,Object? employeeId = null,Object? userType = null,Object? firstName = null,Object? lastName = null,Object? email = null,Object? phone = null,Object? lcoCode = null,Object? businessName = null,Object? employeeParentType = null,Object? employeeParentId = null,Object? username = freezed,Object? logoImg = freezed,Object? address1 = null,Object? address2 = null,Object? address3 = null,Object? copyRights = null,Object? shortName = null,Object? pinCode = null,Object? country = null,Object? state = null,Object? district = null,Object? city = null,Object? dob = null,Object? adate = null,Object? employeeName = null,Object? lcoLocation = null,Object? countryName = null,Object? useCRF = null,Object? useCAF = null,Object? useLastName = null,Object? useDiscount = null,Object? useDataFromMasterTable = null,Object? useMandatoryForHotel = null,Object? useAccountNumber = null,Object? freezecustomerparamsinapp = null,Object? blockpayment = null,Object? lcoBilltype = null,Object? useLcoDeposit = null,Object? customerBilltype = null,Object? autoReceiptNumber = null,Object? currencyCode = null,Object? allowTopUp = null,Object? showCafMobileValidation = null,Object? stbPairing = null,Object? stbUnpairing = null,Object? showMiaAgreementUpload = null,Object? acceptTermsConditions = null,Object? agreementDetailsCount = null,Object? accessDistributorWise = null,Object? isDirectLco = null,Object? isUnpaidlco = null,Object? appMenuFormat = null,Object? invoicePaymentSearchLimit = null,Object? lcoMobileNo = null,Object? patchInformation = null,Object? recurringServiceEdit = null,Object? showLcoComplaint = null,Object? depositAmount = null,Object? showSerialVc = null,Object? showServiceExtension = null,Object? editQuantity = null,Object? enableBoxWisePayment = null,Object? baidLabel = freezed,Object? defaultCountry = freezed,Object? defaultState = freezed,Object? defaultDistrict = freezed,Object? defaultCity = freezed,Object? appTheme = freezed,Object? appDashboard = freezed,Object? enableAadhaar = freezed,Object? lcoPayment = freezed,Object? userNotifications = null,Object? notifyCount = null,Object? noteDuration = null,}) {
  return _then(_LoginResponse(
statusCode: null == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int,statusMsg: null == statusMsg ? _self.statusMsg : statusMsg // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,dealerId: null == dealerId ? _self.dealerId : dealerId // ignore: cast_nullable_to_non_nullable
as int,employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as int,userType: null == userType ? _self.userType : userType // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,lcoCode: null == lcoCode ? _self.lcoCode : lcoCode // ignore: cast_nullable_to_non_nullable
as String,businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,employeeParentType: null == employeeParentType ? _self.employeeParentType : employeeParentType // ignore: cast_nullable_to_non_nullable
as String,employeeParentId: null == employeeParentId ? _self.employeeParentId : employeeParentId // ignore: cast_nullable_to_non_nullable
as String,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,logoImg: freezed == logoImg ? _self.logoImg : logoImg // ignore: cast_nullable_to_non_nullable
as String?,address1: null == address1 ? _self.address1 : address1 // ignore: cast_nullable_to_non_nullable
as String,address2: null == address2 ? _self.address2 : address2 // ignore: cast_nullable_to_non_nullable
as String,address3: null == address3 ? _self.address3 : address3 // ignore: cast_nullable_to_non_nullable
as String,copyRights: null == copyRights ? _self.copyRights : copyRights // ignore: cast_nullable_to_non_nullable
as String,shortName: null == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String,pinCode: null == pinCode ? _self.pinCode : pinCode // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,district: null == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,dob: null == dob ? _self.dob : dob // ignore: cast_nullable_to_non_nullable
as String,adate: null == adate ? _self.adate : adate // ignore: cast_nullable_to_non_nullable
as String,employeeName: null == employeeName ? _self.employeeName : employeeName // ignore: cast_nullable_to_non_nullable
as String,lcoLocation: null == lcoLocation ? _self.lcoLocation : lcoLocation // ignore: cast_nullable_to_non_nullable
as String,countryName: null == countryName ? _self.countryName : countryName // ignore: cast_nullable_to_non_nullable
as String,useCRF: null == useCRF ? _self.useCRF : useCRF // ignore: cast_nullable_to_non_nullable
as int,useCAF: null == useCAF ? _self.useCAF : useCAF // ignore: cast_nullable_to_non_nullable
as String,useLastName: null == useLastName ? _self.useLastName : useLastName // ignore: cast_nullable_to_non_nullable
as int,useDiscount: null == useDiscount ? _self.useDiscount : useDiscount // ignore: cast_nullable_to_non_nullable
as int,useDataFromMasterTable: null == useDataFromMasterTable ? _self.useDataFromMasterTable : useDataFromMasterTable // ignore: cast_nullable_to_non_nullable
as int,useMandatoryForHotel: null == useMandatoryForHotel ? _self.useMandatoryForHotel : useMandatoryForHotel // ignore: cast_nullable_to_non_nullable
as int,useAccountNumber: null == useAccountNumber ? _self.useAccountNumber : useAccountNumber // ignore: cast_nullable_to_non_nullable
as int,freezecustomerparamsinapp: null == freezecustomerparamsinapp ? _self.freezecustomerparamsinapp : freezecustomerparamsinapp // ignore: cast_nullable_to_non_nullable
as int,blockpayment: null == blockpayment ? _self.blockpayment : blockpayment // ignore: cast_nullable_to_non_nullable
as int,lcoBilltype: null == lcoBilltype ? _self.lcoBilltype : lcoBilltype // ignore: cast_nullable_to_non_nullable
as int,useLcoDeposit: null == useLcoDeposit ? _self.useLcoDeposit : useLcoDeposit // ignore: cast_nullable_to_non_nullable
as int,customerBilltype: null == customerBilltype ? _self.customerBilltype : customerBilltype // ignore: cast_nullable_to_non_nullable
as int,autoReceiptNumber: null == autoReceiptNumber ? _self.autoReceiptNumber : autoReceiptNumber // ignore: cast_nullable_to_non_nullable
as int,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,allowTopUp: null == allowTopUp ? _self.allowTopUp : allowTopUp // ignore: cast_nullable_to_non_nullable
as int,showCafMobileValidation: null == showCafMobileValidation ? _self.showCafMobileValidation : showCafMobileValidation // ignore: cast_nullable_to_non_nullable
as int,stbPairing: null == stbPairing ? _self.stbPairing : stbPairing // ignore: cast_nullable_to_non_nullable
as int,stbUnpairing: null == stbUnpairing ? _self.stbUnpairing : stbUnpairing // ignore: cast_nullable_to_non_nullable
as int,showMiaAgreementUpload: null == showMiaAgreementUpload ? _self.showMiaAgreementUpload : showMiaAgreementUpload // ignore: cast_nullable_to_non_nullable
as int,acceptTermsConditions: null == acceptTermsConditions ? _self.acceptTermsConditions : acceptTermsConditions // ignore: cast_nullable_to_non_nullable
as int,agreementDetailsCount: null == agreementDetailsCount ? _self.agreementDetailsCount : agreementDetailsCount // ignore: cast_nullable_to_non_nullable
as int,accessDistributorWise: null == accessDistributorWise ? _self.accessDistributorWise : accessDistributorWise // ignore: cast_nullable_to_non_nullable
as int,isDirectLco: null == isDirectLco ? _self.isDirectLco : isDirectLco // ignore: cast_nullable_to_non_nullable
as int,isUnpaidlco: null == isUnpaidlco ? _self.isUnpaidlco : isUnpaidlco // ignore: cast_nullable_to_non_nullable
as int,appMenuFormat: null == appMenuFormat ? _self.appMenuFormat : appMenuFormat // ignore: cast_nullable_to_non_nullable
as String,invoicePaymentSearchLimit: null == invoicePaymentSearchLimit ? _self.invoicePaymentSearchLimit : invoicePaymentSearchLimit // ignore: cast_nullable_to_non_nullable
as int,lcoMobileNo: null == lcoMobileNo ? _self.lcoMobileNo : lcoMobileNo // ignore: cast_nullable_to_non_nullable
as String,patchInformation: null == patchInformation ? _self.patchInformation : patchInformation // ignore: cast_nullable_to_non_nullable
as String,recurringServiceEdit: null == recurringServiceEdit ? _self.recurringServiceEdit : recurringServiceEdit // ignore: cast_nullable_to_non_nullable
as int,showLcoComplaint: null == showLcoComplaint ? _self.showLcoComplaint : showLcoComplaint // ignore: cast_nullable_to_non_nullable
as int,depositAmount: null == depositAmount ? _self.depositAmount : depositAmount // ignore: cast_nullable_to_non_nullable
as double,showSerialVc: null == showSerialVc ? _self.showSerialVc : showSerialVc // ignore: cast_nullable_to_non_nullable
as int,showServiceExtension: null == showServiceExtension ? _self.showServiceExtension : showServiceExtension // ignore: cast_nullable_to_non_nullable
as int,editQuantity: null == editQuantity ? _self.editQuantity : editQuantity // ignore: cast_nullable_to_non_nullable
as int,enableBoxWisePayment: null == enableBoxWisePayment ? _self.enableBoxWisePayment : enableBoxWisePayment // ignore: cast_nullable_to_non_nullable
as int,baidLabel: freezed == baidLabel ? _self.baidLabel : baidLabel // ignore: cast_nullable_to_non_nullable
as String?,defaultCountry: freezed == defaultCountry ? _self.defaultCountry : defaultCountry // ignore: cast_nullable_to_non_nullable
as String?,defaultState: freezed == defaultState ? _self.defaultState : defaultState // ignore: cast_nullable_to_non_nullable
as int?,defaultDistrict: freezed == defaultDistrict ? _self.defaultDistrict : defaultDistrict // ignore: cast_nullable_to_non_nullable
as int?,defaultCity: freezed == defaultCity ? _self.defaultCity : defaultCity // ignore: cast_nullable_to_non_nullable
as int?,appTheme: freezed == appTheme ? _self.appTheme : appTheme // ignore: cast_nullable_to_non_nullable
as int?,appDashboard: freezed == appDashboard ? _self.appDashboard : appDashboard // ignore: cast_nullable_to_non_nullable
as int?,enableAadhaar: freezed == enableAadhaar ? _self.enableAadhaar : enableAadhaar // ignore: cast_nullable_to_non_nullable
as int?,lcoPayment: freezed == lcoPayment ? _self.lcoPayment : lcoPayment // ignore: cast_nullable_to_non_nullable
as int?,userNotifications: null == userNotifications ? _self.userNotifications : userNotifications // ignore: cast_nullable_to_non_nullable
as int,notifyCount: null == notifyCount ? _self.notifyCount : notifyCount // ignore: cast_nullable_to_non_nullable
as int,noteDuration: null == noteDuration ? _self.noteDuration : noteDuration // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
