// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CustomerModel {

@JsonKey(name: 'customer_id') String get customerId;@JsonKey(name: 'customerName') String get customerName;@JsonKey(name: 'caf_no') String? get cafNumber;@JsonKey(name: 'mobile_no') String? get mobileNumber;@JsonKey(name: 'status') String get status;@JsonKey(name: 'billing_address') String? get billingAddress;@JsonKey(name: 'installation_address') String? get installationAddress;@JsonKey(name: 'pin_code') String? get pinCode;@JsonKey(name: 'crf_number') String? get crfNumber;@JsonKey(name: 'pending_amount') double get pendingAmount;@JsonKey(name: 'online_customer') int get onlineCustomer;@JsonKey(name: 'checkaddserviceaccess') int? get checkAddServiceAccess;@JsonKey(name: 'ADDON_AFTER_BASEPACK') int? get addonAfterBasepack;@JsonKey(name: 'reseller_id') String? get resellerId;@JsonKey(name: 'bill_type') String? get billType;@JsonKey(name: 'is_direct_lco') int get isDirectLco;@JsonKey(name: 'account_number') String? get accountNumber;@JsonKey(name: 'latitude') double get latitude;@JsonKey(name: 'longitude') double get longitude;@JsonKey(name: 'serial_number') String? get serialNumber;@JsonKey(name: 'vc_number') String? get vcNumber;@JsonKey(name: 'stb_count') int get stbCount;@JsonKey(name: 'baid') String? get baid;
/// Create a copy of CustomerModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerModelCopyWith<CustomerModel> get copyWith => _$CustomerModelCopyWithImpl<CustomerModel>(this as CustomerModel, _$identity);

  /// Serializes this CustomerModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerModel&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.cafNumber, cafNumber) || other.cafNumber == cafNumber)&&(identical(other.mobileNumber, mobileNumber) || other.mobileNumber == mobileNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.billingAddress, billingAddress) || other.billingAddress == billingAddress)&&(identical(other.installationAddress, installationAddress) || other.installationAddress == installationAddress)&&(identical(other.pinCode, pinCode) || other.pinCode == pinCode)&&(identical(other.crfNumber, crfNumber) || other.crfNumber == crfNumber)&&(identical(other.pendingAmount, pendingAmount) || other.pendingAmount == pendingAmount)&&(identical(other.onlineCustomer, onlineCustomer) || other.onlineCustomer == onlineCustomer)&&(identical(other.checkAddServiceAccess, checkAddServiceAccess) || other.checkAddServiceAccess == checkAddServiceAccess)&&(identical(other.addonAfterBasepack, addonAfterBasepack) || other.addonAfterBasepack == addonAfterBasepack)&&(identical(other.resellerId, resellerId) || other.resellerId == resellerId)&&(identical(other.billType, billType) || other.billType == billType)&&(identical(other.isDirectLco, isDirectLco) || other.isDirectLco == isDirectLco)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.vcNumber, vcNumber) || other.vcNumber == vcNumber)&&(identical(other.stbCount, stbCount) || other.stbCount == stbCount)&&(identical(other.baid, baid) || other.baid == baid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,customerId,customerName,cafNumber,mobileNumber,status,billingAddress,installationAddress,pinCode,crfNumber,pendingAmount,onlineCustomer,checkAddServiceAccess,addonAfterBasepack,resellerId,billType,isDirectLco,accountNumber,latitude,longitude,serialNumber,vcNumber,stbCount,baid]);

@override
String toString() {
  return 'CustomerModel(customerId: $customerId, customerName: $customerName, cafNumber: $cafNumber, mobileNumber: $mobileNumber, status: $status, billingAddress: $billingAddress, installationAddress: $installationAddress, pinCode: $pinCode, crfNumber: $crfNumber, pendingAmount: $pendingAmount, onlineCustomer: $onlineCustomer, checkAddServiceAccess: $checkAddServiceAccess, addonAfterBasepack: $addonAfterBasepack, resellerId: $resellerId, billType: $billType, isDirectLco: $isDirectLco, accountNumber: $accountNumber, latitude: $latitude, longitude: $longitude, serialNumber: $serialNumber, vcNumber: $vcNumber, stbCount: $stbCount, baid: $baid)';
}


}

/// @nodoc
abstract mixin class $CustomerModelCopyWith<$Res>  {
  factory $CustomerModelCopyWith(CustomerModel value, $Res Function(CustomerModel) _then) = _$CustomerModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'customer_id') String customerId,@JsonKey(name: 'customerName') String customerName,@JsonKey(name: 'caf_no') String? cafNumber,@JsonKey(name: 'mobile_no') String? mobileNumber,@JsonKey(name: 'status') String status,@JsonKey(name: 'billing_address') String? billingAddress,@JsonKey(name: 'installation_address') String? installationAddress,@JsonKey(name: 'pin_code') String? pinCode,@JsonKey(name: 'crf_number') String? crfNumber,@JsonKey(name: 'pending_amount') double pendingAmount,@JsonKey(name: 'online_customer') int onlineCustomer,@JsonKey(name: 'checkaddserviceaccess') int? checkAddServiceAccess,@JsonKey(name: 'ADDON_AFTER_BASEPACK') int? addonAfterBasepack,@JsonKey(name: 'reseller_id') String? resellerId,@JsonKey(name: 'bill_type') String? billType,@JsonKey(name: 'is_direct_lco') int isDirectLco,@JsonKey(name: 'account_number') String? accountNumber,@JsonKey(name: 'latitude') double latitude,@JsonKey(name: 'longitude') double longitude,@JsonKey(name: 'serial_number') String? serialNumber,@JsonKey(name: 'vc_number') String? vcNumber,@JsonKey(name: 'stb_count') int stbCount,@JsonKey(name: 'baid') String? baid
});




}
/// @nodoc
class _$CustomerModelCopyWithImpl<$Res>
    implements $CustomerModelCopyWith<$Res> {
  _$CustomerModelCopyWithImpl(this._self, this._then);

  final CustomerModel _self;
  final $Res Function(CustomerModel) _then;

/// Create a copy of CustomerModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? customerId = null,Object? customerName = null,Object? cafNumber = freezed,Object? mobileNumber = freezed,Object? status = null,Object? billingAddress = freezed,Object? installationAddress = freezed,Object? pinCode = freezed,Object? crfNumber = freezed,Object? pendingAmount = null,Object? onlineCustomer = null,Object? checkAddServiceAccess = freezed,Object? addonAfterBasepack = freezed,Object? resellerId = freezed,Object? billType = freezed,Object? isDirectLco = null,Object? accountNumber = freezed,Object? latitude = null,Object? longitude = null,Object? serialNumber = freezed,Object? vcNumber = freezed,Object? stbCount = null,Object? baid = freezed,}) {
  return _then(_self.copyWith(
customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,cafNumber: freezed == cafNumber ? _self.cafNumber : cafNumber // ignore: cast_nullable_to_non_nullable
as String?,mobileNumber: freezed == mobileNumber ? _self.mobileNumber : mobileNumber // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,billingAddress: freezed == billingAddress ? _self.billingAddress : billingAddress // ignore: cast_nullable_to_non_nullable
as String?,installationAddress: freezed == installationAddress ? _self.installationAddress : installationAddress // ignore: cast_nullable_to_non_nullable
as String?,pinCode: freezed == pinCode ? _self.pinCode : pinCode // ignore: cast_nullable_to_non_nullable
as String?,crfNumber: freezed == crfNumber ? _self.crfNumber : crfNumber // ignore: cast_nullable_to_non_nullable
as String?,pendingAmount: null == pendingAmount ? _self.pendingAmount : pendingAmount // ignore: cast_nullable_to_non_nullable
as double,onlineCustomer: null == onlineCustomer ? _self.onlineCustomer : onlineCustomer // ignore: cast_nullable_to_non_nullable
as int,checkAddServiceAccess: freezed == checkAddServiceAccess ? _self.checkAddServiceAccess : checkAddServiceAccess // ignore: cast_nullable_to_non_nullable
as int?,addonAfterBasepack: freezed == addonAfterBasepack ? _self.addonAfterBasepack : addonAfterBasepack // ignore: cast_nullable_to_non_nullable
as int?,resellerId: freezed == resellerId ? _self.resellerId : resellerId // ignore: cast_nullable_to_non_nullable
as String?,billType: freezed == billType ? _self.billType : billType // ignore: cast_nullable_to_non_nullable
as String?,isDirectLco: null == isDirectLco ? _self.isDirectLco : isDirectLco // ignore: cast_nullable_to_non_nullable
as int,accountNumber: freezed == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String?,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,serialNumber: freezed == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String?,vcNumber: freezed == vcNumber ? _self.vcNumber : vcNumber // ignore: cast_nullable_to_non_nullable
as String?,stbCount: null == stbCount ? _self.stbCount : stbCount // ignore: cast_nullable_to_non_nullable
as int,baid: freezed == baid ? _self.baid : baid // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomerModel].
extension CustomerModelPatterns on CustomerModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomerModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomerModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomerModel value)  $default,){
final _that = this;
switch (_that) {
case _CustomerModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomerModel value)?  $default,){
final _that = this;
switch (_that) {
case _CustomerModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'customer_id')  String customerId, @JsonKey(name: 'customerName')  String customerName, @JsonKey(name: 'caf_no')  String? cafNumber, @JsonKey(name: 'mobile_no')  String? mobileNumber, @JsonKey(name: 'status')  String status, @JsonKey(name: 'billing_address')  String? billingAddress, @JsonKey(name: 'installation_address')  String? installationAddress, @JsonKey(name: 'pin_code')  String? pinCode, @JsonKey(name: 'crf_number')  String? crfNumber, @JsonKey(name: 'pending_amount')  double pendingAmount, @JsonKey(name: 'online_customer')  int onlineCustomer, @JsonKey(name: 'checkaddserviceaccess')  int? checkAddServiceAccess, @JsonKey(name: 'ADDON_AFTER_BASEPACK')  int? addonAfterBasepack, @JsonKey(name: 'reseller_id')  String? resellerId, @JsonKey(name: 'bill_type')  String? billType, @JsonKey(name: 'is_direct_lco')  int isDirectLco, @JsonKey(name: 'account_number')  String? accountNumber, @JsonKey(name: 'latitude')  double latitude, @JsonKey(name: 'longitude')  double longitude, @JsonKey(name: 'serial_number')  String? serialNumber, @JsonKey(name: 'vc_number')  String? vcNumber, @JsonKey(name: 'stb_count')  int stbCount, @JsonKey(name: 'baid')  String? baid)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomerModel() when $default != null:
return $default(_that.customerId,_that.customerName,_that.cafNumber,_that.mobileNumber,_that.status,_that.billingAddress,_that.installationAddress,_that.pinCode,_that.crfNumber,_that.pendingAmount,_that.onlineCustomer,_that.checkAddServiceAccess,_that.addonAfterBasepack,_that.resellerId,_that.billType,_that.isDirectLco,_that.accountNumber,_that.latitude,_that.longitude,_that.serialNumber,_that.vcNumber,_that.stbCount,_that.baid);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'customer_id')  String customerId, @JsonKey(name: 'customerName')  String customerName, @JsonKey(name: 'caf_no')  String? cafNumber, @JsonKey(name: 'mobile_no')  String? mobileNumber, @JsonKey(name: 'status')  String status, @JsonKey(name: 'billing_address')  String? billingAddress, @JsonKey(name: 'installation_address')  String? installationAddress, @JsonKey(name: 'pin_code')  String? pinCode, @JsonKey(name: 'crf_number')  String? crfNumber, @JsonKey(name: 'pending_amount')  double pendingAmount, @JsonKey(name: 'online_customer')  int onlineCustomer, @JsonKey(name: 'checkaddserviceaccess')  int? checkAddServiceAccess, @JsonKey(name: 'ADDON_AFTER_BASEPACK')  int? addonAfterBasepack, @JsonKey(name: 'reseller_id')  String? resellerId, @JsonKey(name: 'bill_type')  String? billType, @JsonKey(name: 'is_direct_lco')  int isDirectLco, @JsonKey(name: 'account_number')  String? accountNumber, @JsonKey(name: 'latitude')  double latitude, @JsonKey(name: 'longitude')  double longitude, @JsonKey(name: 'serial_number')  String? serialNumber, @JsonKey(name: 'vc_number')  String? vcNumber, @JsonKey(name: 'stb_count')  int stbCount, @JsonKey(name: 'baid')  String? baid)  $default,) {final _that = this;
switch (_that) {
case _CustomerModel():
return $default(_that.customerId,_that.customerName,_that.cafNumber,_that.mobileNumber,_that.status,_that.billingAddress,_that.installationAddress,_that.pinCode,_that.crfNumber,_that.pendingAmount,_that.onlineCustomer,_that.checkAddServiceAccess,_that.addonAfterBasepack,_that.resellerId,_that.billType,_that.isDirectLco,_that.accountNumber,_that.latitude,_that.longitude,_that.serialNumber,_that.vcNumber,_that.stbCount,_that.baid);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'customer_id')  String customerId, @JsonKey(name: 'customerName')  String customerName, @JsonKey(name: 'caf_no')  String? cafNumber, @JsonKey(name: 'mobile_no')  String? mobileNumber, @JsonKey(name: 'status')  String status, @JsonKey(name: 'billing_address')  String? billingAddress, @JsonKey(name: 'installation_address')  String? installationAddress, @JsonKey(name: 'pin_code')  String? pinCode, @JsonKey(name: 'crf_number')  String? crfNumber, @JsonKey(name: 'pending_amount')  double pendingAmount, @JsonKey(name: 'online_customer')  int onlineCustomer, @JsonKey(name: 'checkaddserviceaccess')  int? checkAddServiceAccess, @JsonKey(name: 'ADDON_AFTER_BASEPACK')  int? addonAfterBasepack, @JsonKey(name: 'reseller_id')  String? resellerId, @JsonKey(name: 'bill_type')  String? billType, @JsonKey(name: 'is_direct_lco')  int isDirectLco, @JsonKey(name: 'account_number')  String? accountNumber, @JsonKey(name: 'latitude')  double latitude, @JsonKey(name: 'longitude')  double longitude, @JsonKey(name: 'serial_number')  String? serialNumber, @JsonKey(name: 'vc_number')  String? vcNumber, @JsonKey(name: 'stb_count')  int stbCount, @JsonKey(name: 'baid')  String? baid)?  $default,) {final _that = this;
switch (_that) {
case _CustomerModel() when $default != null:
return $default(_that.customerId,_that.customerName,_that.cafNumber,_that.mobileNumber,_that.status,_that.billingAddress,_that.installationAddress,_that.pinCode,_that.crfNumber,_that.pendingAmount,_that.onlineCustomer,_that.checkAddServiceAccess,_that.addonAfterBasepack,_that.resellerId,_that.billType,_that.isDirectLco,_that.accountNumber,_that.latitude,_that.longitude,_that.serialNumber,_that.vcNumber,_that.stbCount,_that.baid);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CustomerModel implements CustomerModel {
  const _CustomerModel({@JsonKey(name: 'customer_id') this.customerId = '', @JsonKey(name: 'customerName') this.customerName = '', @JsonKey(name: 'caf_no') this.cafNumber, @JsonKey(name: 'mobile_no') this.mobileNumber, @JsonKey(name: 'status') this.status = '', @JsonKey(name: 'billing_address') this.billingAddress, @JsonKey(name: 'installation_address') this.installationAddress, @JsonKey(name: 'pin_code') this.pinCode, @JsonKey(name: 'crf_number') this.crfNumber, @JsonKey(name: 'pending_amount') this.pendingAmount = 0.0, @JsonKey(name: 'online_customer') this.onlineCustomer = 0, @JsonKey(name: 'checkaddserviceaccess') this.checkAddServiceAccess, @JsonKey(name: 'ADDON_AFTER_BASEPACK') this.addonAfterBasepack, @JsonKey(name: 'reseller_id') this.resellerId, @JsonKey(name: 'bill_type') this.billType, @JsonKey(name: 'is_direct_lco') this.isDirectLco = 0, @JsonKey(name: 'account_number') this.accountNumber, @JsonKey(name: 'latitude') this.latitude = 0.0, @JsonKey(name: 'longitude') this.longitude = 0.0, @JsonKey(name: 'serial_number') this.serialNumber, @JsonKey(name: 'vc_number') this.vcNumber, @JsonKey(name: 'stb_count') this.stbCount = 0, @JsonKey(name: 'baid') this.baid});
  factory _CustomerModel.fromJson(Map<String, dynamic> json) => _$CustomerModelFromJson(json);

@override@JsonKey(name: 'customer_id') final  String customerId;
@override@JsonKey(name: 'customerName') final  String customerName;
@override@JsonKey(name: 'caf_no') final  String? cafNumber;
@override@JsonKey(name: 'mobile_no') final  String? mobileNumber;
@override@JsonKey(name: 'status') final  String status;
@override@JsonKey(name: 'billing_address') final  String? billingAddress;
@override@JsonKey(name: 'installation_address') final  String? installationAddress;
@override@JsonKey(name: 'pin_code') final  String? pinCode;
@override@JsonKey(name: 'crf_number') final  String? crfNumber;
@override@JsonKey(name: 'pending_amount') final  double pendingAmount;
@override@JsonKey(name: 'online_customer') final  int onlineCustomer;
@override@JsonKey(name: 'checkaddserviceaccess') final  int? checkAddServiceAccess;
@override@JsonKey(name: 'ADDON_AFTER_BASEPACK') final  int? addonAfterBasepack;
@override@JsonKey(name: 'reseller_id') final  String? resellerId;
@override@JsonKey(name: 'bill_type') final  String? billType;
@override@JsonKey(name: 'is_direct_lco') final  int isDirectLco;
@override@JsonKey(name: 'account_number') final  String? accountNumber;
@override@JsonKey(name: 'latitude') final  double latitude;
@override@JsonKey(name: 'longitude') final  double longitude;
@override@JsonKey(name: 'serial_number') final  String? serialNumber;
@override@JsonKey(name: 'vc_number') final  String? vcNumber;
@override@JsonKey(name: 'stb_count') final  int stbCount;
@override@JsonKey(name: 'baid') final  String? baid;

/// Create a copy of CustomerModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerModelCopyWith<_CustomerModel> get copyWith => __$CustomerModelCopyWithImpl<_CustomerModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomerModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomerModel&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.cafNumber, cafNumber) || other.cafNumber == cafNumber)&&(identical(other.mobileNumber, mobileNumber) || other.mobileNumber == mobileNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.billingAddress, billingAddress) || other.billingAddress == billingAddress)&&(identical(other.installationAddress, installationAddress) || other.installationAddress == installationAddress)&&(identical(other.pinCode, pinCode) || other.pinCode == pinCode)&&(identical(other.crfNumber, crfNumber) || other.crfNumber == crfNumber)&&(identical(other.pendingAmount, pendingAmount) || other.pendingAmount == pendingAmount)&&(identical(other.onlineCustomer, onlineCustomer) || other.onlineCustomer == onlineCustomer)&&(identical(other.checkAddServiceAccess, checkAddServiceAccess) || other.checkAddServiceAccess == checkAddServiceAccess)&&(identical(other.addonAfterBasepack, addonAfterBasepack) || other.addonAfterBasepack == addonAfterBasepack)&&(identical(other.resellerId, resellerId) || other.resellerId == resellerId)&&(identical(other.billType, billType) || other.billType == billType)&&(identical(other.isDirectLco, isDirectLco) || other.isDirectLco == isDirectLco)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.vcNumber, vcNumber) || other.vcNumber == vcNumber)&&(identical(other.stbCount, stbCount) || other.stbCount == stbCount)&&(identical(other.baid, baid) || other.baid == baid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,customerId,customerName,cafNumber,mobileNumber,status,billingAddress,installationAddress,pinCode,crfNumber,pendingAmount,onlineCustomer,checkAddServiceAccess,addonAfterBasepack,resellerId,billType,isDirectLco,accountNumber,latitude,longitude,serialNumber,vcNumber,stbCount,baid]);

@override
String toString() {
  return 'CustomerModel(customerId: $customerId, customerName: $customerName, cafNumber: $cafNumber, mobileNumber: $mobileNumber, status: $status, billingAddress: $billingAddress, installationAddress: $installationAddress, pinCode: $pinCode, crfNumber: $crfNumber, pendingAmount: $pendingAmount, onlineCustomer: $onlineCustomer, checkAddServiceAccess: $checkAddServiceAccess, addonAfterBasepack: $addonAfterBasepack, resellerId: $resellerId, billType: $billType, isDirectLco: $isDirectLco, accountNumber: $accountNumber, latitude: $latitude, longitude: $longitude, serialNumber: $serialNumber, vcNumber: $vcNumber, stbCount: $stbCount, baid: $baid)';
}


}

/// @nodoc
abstract mixin class _$CustomerModelCopyWith<$Res> implements $CustomerModelCopyWith<$Res> {
  factory _$CustomerModelCopyWith(_CustomerModel value, $Res Function(_CustomerModel) _then) = __$CustomerModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'customer_id') String customerId,@JsonKey(name: 'customerName') String customerName,@JsonKey(name: 'caf_no') String? cafNumber,@JsonKey(name: 'mobile_no') String? mobileNumber,@JsonKey(name: 'status') String status,@JsonKey(name: 'billing_address') String? billingAddress,@JsonKey(name: 'installation_address') String? installationAddress,@JsonKey(name: 'pin_code') String? pinCode,@JsonKey(name: 'crf_number') String? crfNumber,@JsonKey(name: 'pending_amount') double pendingAmount,@JsonKey(name: 'online_customer') int onlineCustomer,@JsonKey(name: 'checkaddserviceaccess') int? checkAddServiceAccess,@JsonKey(name: 'ADDON_AFTER_BASEPACK') int? addonAfterBasepack,@JsonKey(name: 'reseller_id') String? resellerId,@JsonKey(name: 'bill_type') String? billType,@JsonKey(name: 'is_direct_lco') int isDirectLco,@JsonKey(name: 'account_number') String? accountNumber,@JsonKey(name: 'latitude') double latitude,@JsonKey(name: 'longitude') double longitude,@JsonKey(name: 'serial_number') String? serialNumber,@JsonKey(name: 'vc_number') String? vcNumber,@JsonKey(name: 'stb_count') int stbCount,@JsonKey(name: 'baid') String? baid
});




}
/// @nodoc
class __$CustomerModelCopyWithImpl<$Res>
    implements _$CustomerModelCopyWith<$Res> {
  __$CustomerModelCopyWithImpl(this._self, this._then);

  final _CustomerModel _self;
  final $Res Function(_CustomerModel) _then;

/// Create a copy of CustomerModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? customerId = null,Object? customerName = null,Object? cafNumber = freezed,Object? mobileNumber = freezed,Object? status = null,Object? billingAddress = freezed,Object? installationAddress = freezed,Object? pinCode = freezed,Object? crfNumber = freezed,Object? pendingAmount = null,Object? onlineCustomer = null,Object? checkAddServiceAccess = freezed,Object? addonAfterBasepack = freezed,Object? resellerId = freezed,Object? billType = freezed,Object? isDirectLco = null,Object? accountNumber = freezed,Object? latitude = null,Object? longitude = null,Object? serialNumber = freezed,Object? vcNumber = freezed,Object? stbCount = null,Object? baid = freezed,}) {
  return _then(_CustomerModel(
customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,cafNumber: freezed == cafNumber ? _self.cafNumber : cafNumber // ignore: cast_nullable_to_non_nullable
as String?,mobileNumber: freezed == mobileNumber ? _self.mobileNumber : mobileNumber // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,billingAddress: freezed == billingAddress ? _self.billingAddress : billingAddress // ignore: cast_nullable_to_non_nullable
as String?,installationAddress: freezed == installationAddress ? _self.installationAddress : installationAddress // ignore: cast_nullable_to_non_nullable
as String?,pinCode: freezed == pinCode ? _self.pinCode : pinCode // ignore: cast_nullable_to_non_nullable
as String?,crfNumber: freezed == crfNumber ? _self.crfNumber : crfNumber // ignore: cast_nullable_to_non_nullable
as String?,pendingAmount: null == pendingAmount ? _self.pendingAmount : pendingAmount // ignore: cast_nullable_to_non_nullable
as double,onlineCustomer: null == onlineCustomer ? _self.onlineCustomer : onlineCustomer // ignore: cast_nullable_to_non_nullable
as int,checkAddServiceAccess: freezed == checkAddServiceAccess ? _self.checkAddServiceAccess : checkAddServiceAccess // ignore: cast_nullable_to_non_nullable
as int?,addonAfterBasepack: freezed == addonAfterBasepack ? _self.addonAfterBasepack : addonAfterBasepack // ignore: cast_nullable_to_non_nullable
as int?,resellerId: freezed == resellerId ? _self.resellerId : resellerId // ignore: cast_nullable_to_non_nullable
as String?,billType: freezed == billType ? _self.billType : billType // ignore: cast_nullable_to_non_nullable
as String?,isDirectLco: null == isDirectLco ? _self.isDirectLco : isDirectLco // ignore: cast_nullable_to_non_nullable
as int,accountNumber: freezed == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String?,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,serialNumber: freezed == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String?,vcNumber: freezed == vcNumber ? _self.vcNumber : vcNumber // ignore: cast_nullable_to_non_nullable
as String?,stbCount: null == stbCount ? _self.stbCount : stbCount // ignore: cast_nullable_to_non_nullable
as int,baid: freezed == baid ? _self.baid : baid // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
