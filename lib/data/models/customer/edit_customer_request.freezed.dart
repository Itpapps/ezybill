// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'edit_customer_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EditCustomerRequest {

@JsonKey(name: 'customerId') String get customerId;@JsonKey(name: 'firstName') String get firstName;@JsonKey(name: 'lastName') String? get lastName;@JsonKey(name: 'mobileNumber') String get mobileNumber;@JsonKey(name: 'email') String? get email;@JsonKey(name: 'billingAddress1') String? get billingAddress1;@JsonKey(name: 'billingAddress2') String? get billingAddress2;@JsonKey(name: 'installationAddress1') String? get installationAddress1;@JsonKey(name: 'installationAddress2') String? get installationAddress2;@JsonKey(name: 'pinCode') String? get pinCode;@JsonKey(name: 'gender') String? get gender;@JsonKey(name: 'idType') String? get idType;@JsonKey(name: 'idNumber') String? get idNumber;@JsonKey(name: 'customerTypeId') String? get customerTypeId;@JsonKey(name: 'customerTypeTypesId') String? get customerTypeTypesId;@JsonKey(name: 'groupId') String? get groupId;@JsonKey(name: 'cafNumber') String? get cafNumber;@JsonKey(name: 'lcoCustomerId') String? get lcoCustomerId;@JsonKey(name: 'businessName') String? get businessName;@JsonKey(name: 'fatherName') String? get fatherName;@JsonKey(name: 'accountNumber') String? get accountNumber;@JsonKey(name: 'billType') String? get billType;@JsonKey(name: 'dob') String? get dob;@JsonKey(name: 'doa') String? get doa;@JsonKey(name: 'discount') double? get discount;@JsonKey(name: 'remarks') String? get remarks;@JsonKey(name: 'countryCode') String? get countryCode;@JsonKey(name: 'stateId') String? get stateId;@JsonKey(name: 'districtId') String? get districtId;@JsonKey(name: 'cityId') String? get cityId;@JsonKey(name: 'mandalId') String? get mandalId;@JsonKey(name: 'latitude') double? get latitude;@JsonKey(name: 'longitude') double? get longitude;@JsonKey(name: 'changeAddress', defaultValue: false) bool get changeAddress;@JsonKey(name: 'changeInstallAddress', defaultValue: false) bool get changeInstallAddress;@JsonKey(name: 'uploadDocs', defaultValue: false) bool get uploadDocs;@JsonKey(name: 'idPhoto') String? get idPhoto;@JsonKey(name: 'customerPhoto') String? get customerPhoto;@JsonKey(name: 'signatureImage') String? get signatureImage;
/// Create a copy of EditCustomerRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditCustomerRequestCopyWith<EditCustomerRequest> get copyWith => _$EditCustomerRequestCopyWithImpl<EditCustomerRequest>(this as EditCustomerRequest, _$identity);

  /// Serializes this EditCustomerRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditCustomerRequest&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.mobileNumber, mobileNumber) || other.mobileNumber == mobileNumber)&&(identical(other.email, email) || other.email == email)&&(identical(other.billingAddress1, billingAddress1) || other.billingAddress1 == billingAddress1)&&(identical(other.billingAddress2, billingAddress2) || other.billingAddress2 == billingAddress2)&&(identical(other.installationAddress1, installationAddress1) || other.installationAddress1 == installationAddress1)&&(identical(other.installationAddress2, installationAddress2) || other.installationAddress2 == installationAddress2)&&(identical(other.pinCode, pinCode) || other.pinCode == pinCode)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.idType, idType) || other.idType == idType)&&(identical(other.idNumber, idNumber) || other.idNumber == idNumber)&&(identical(other.customerTypeId, customerTypeId) || other.customerTypeId == customerTypeId)&&(identical(other.customerTypeTypesId, customerTypeTypesId) || other.customerTypeTypesId == customerTypeTypesId)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.cafNumber, cafNumber) || other.cafNumber == cafNumber)&&(identical(other.lcoCustomerId, lcoCustomerId) || other.lcoCustomerId == lcoCustomerId)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.fatherName, fatherName) || other.fatherName == fatherName)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.billType, billType) || other.billType == billType)&&(identical(other.dob, dob) || other.dob == dob)&&(identical(other.doa, doa) || other.doa == doa)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.stateId, stateId) || other.stateId == stateId)&&(identical(other.districtId, districtId) || other.districtId == districtId)&&(identical(other.cityId, cityId) || other.cityId == cityId)&&(identical(other.mandalId, mandalId) || other.mandalId == mandalId)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.changeAddress, changeAddress) || other.changeAddress == changeAddress)&&(identical(other.changeInstallAddress, changeInstallAddress) || other.changeInstallAddress == changeInstallAddress)&&(identical(other.uploadDocs, uploadDocs) || other.uploadDocs == uploadDocs)&&(identical(other.idPhoto, idPhoto) || other.idPhoto == idPhoto)&&(identical(other.customerPhoto, customerPhoto) || other.customerPhoto == customerPhoto)&&(identical(other.signatureImage, signatureImage) || other.signatureImage == signatureImage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,customerId,firstName,lastName,mobileNumber,email,billingAddress1,billingAddress2,installationAddress1,installationAddress2,pinCode,gender,idType,idNumber,customerTypeId,customerTypeTypesId,groupId,cafNumber,lcoCustomerId,businessName,fatherName,accountNumber,billType,dob,doa,discount,remarks,countryCode,stateId,districtId,cityId,mandalId,latitude,longitude,changeAddress,changeInstallAddress,uploadDocs,idPhoto,customerPhoto,signatureImage]);

@override
String toString() {
  return 'EditCustomerRequest(customerId: $customerId, firstName: $firstName, lastName: $lastName, mobileNumber: $mobileNumber, email: $email, billingAddress1: $billingAddress1, billingAddress2: $billingAddress2, installationAddress1: $installationAddress1, installationAddress2: $installationAddress2, pinCode: $pinCode, gender: $gender, idType: $idType, idNumber: $idNumber, customerTypeId: $customerTypeId, customerTypeTypesId: $customerTypeTypesId, groupId: $groupId, cafNumber: $cafNumber, lcoCustomerId: $lcoCustomerId, businessName: $businessName, fatherName: $fatherName, accountNumber: $accountNumber, billType: $billType, dob: $dob, doa: $doa, discount: $discount, remarks: $remarks, countryCode: $countryCode, stateId: $stateId, districtId: $districtId, cityId: $cityId, mandalId: $mandalId, latitude: $latitude, longitude: $longitude, changeAddress: $changeAddress, changeInstallAddress: $changeInstallAddress, uploadDocs: $uploadDocs, idPhoto: $idPhoto, customerPhoto: $customerPhoto, signatureImage: $signatureImage)';
}


}

/// @nodoc
abstract mixin class $EditCustomerRequestCopyWith<$Res>  {
  factory $EditCustomerRequestCopyWith(EditCustomerRequest value, $Res Function(EditCustomerRequest) _then) = _$EditCustomerRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'customerId') String customerId,@JsonKey(name: 'firstName') String firstName,@JsonKey(name: 'lastName') String? lastName,@JsonKey(name: 'mobileNumber') String mobileNumber,@JsonKey(name: 'email') String? email,@JsonKey(name: 'billingAddress1') String? billingAddress1,@JsonKey(name: 'billingAddress2') String? billingAddress2,@JsonKey(name: 'installationAddress1') String? installationAddress1,@JsonKey(name: 'installationAddress2') String? installationAddress2,@JsonKey(name: 'pinCode') String? pinCode,@JsonKey(name: 'gender') String? gender,@JsonKey(name: 'idType') String? idType,@JsonKey(name: 'idNumber') String? idNumber,@JsonKey(name: 'customerTypeId') String? customerTypeId,@JsonKey(name: 'customerTypeTypesId') String? customerTypeTypesId,@JsonKey(name: 'groupId') String? groupId,@JsonKey(name: 'cafNumber') String? cafNumber,@JsonKey(name: 'lcoCustomerId') String? lcoCustomerId,@JsonKey(name: 'businessName') String? businessName,@JsonKey(name: 'fatherName') String? fatherName,@JsonKey(name: 'accountNumber') String? accountNumber,@JsonKey(name: 'billType') String? billType,@JsonKey(name: 'dob') String? dob,@JsonKey(name: 'doa') String? doa,@JsonKey(name: 'discount') double? discount,@JsonKey(name: 'remarks') String? remarks,@JsonKey(name: 'countryCode') String? countryCode,@JsonKey(name: 'stateId') String? stateId,@JsonKey(name: 'districtId') String? districtId,@JsonKey(name: 'cityId') String? cityId,@JsonKey(name: 'mandalId') String? mandalId,@JsonKey(name: 'latitude') double? latitude,@JsonKey(name: 'longitude') double? longitude,@JsonKey(name: 'changeAddress', defaultValue: false) bool changeAddress,@JsonKey(name: 'changeInstallAddress', defaultValue: false) bool changeInstallAddress,@JsonKey(name: 'uploadDocs', defaultValue: false) bool uploadDocs,@JsonKey(name: 'idPhoto') String? idPhoto,@JsonKey(name: 'customerPhoto') String? customerPhoto,@JsonKey(name: 'signatureImage') String? signatureImage
});




}
/// @nodoc
class _$EditCustomerRequestCopyWithImpl<$Res>
    implements $EditCustomerRequestCopyWith<$Res> {
  _$EditCustomerRequestCopyWithImpl(this._self, this._then);

  final EditCustomerRequest _self;
  final $Res Function(EditCustomerRequest) _then;

/// Create a copy of EditCustomerRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? customerId = null,Object? firstName = null,Object? lastName = freezed,Object? mobileNumber = null,Object? email = freezed,Object? billingAddress1 = freezed,Object? billingAddress2 = freezed,Object? installationAddress1 = freezed,Object? installationAddress2 = freezed,Object? pinCode = freezed,Object? gender = freezed,Object? idType = freezed,Object? idNumber = freezed,Object? customerTypeId = freezed,Object? customerTypeTypesId = freezed,Object? groupId = freezed,Object? cafNumber = freezed,Object? lcoCustomerId = freezed,Object? businessName = freezed,Object? fatherName = freezed,Object? accountNumber = freezed,Object? billType = freezed,Object? dob = freezed,Object? doa = freezed,Object? discount = freezed,Object? remarks = freezed,Object? countryCode = freezed,Object? stateId = freezed,Object? districtId = freezed,Object? cityId = freezed,Object? mandalId = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? changeAddress = null,Object? changeInstallAddress = null,Object? uploadDocs = null,Object? idPhoto = freezed,Object? customerPhoto = freezed,Object? signatureImage = freezed,}) {
  return _then(_self.copyWith(
customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,mobileNumber: null == mobileNumber ? _self.mobileNumber : mobileNumber // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,billingAddress1: freezed == billingAddress1 ? _self.billingAddress1 : billingAddress1 // ignore: cast_nullable_to_non_nullable
as String?,billingAddress2: freezed == billingAddress2 ? _self.billingAddress2 : billingAddress2 // ignore: cast_nullable_to_non_nullable
as String?,installationAddress1: freezed == installationAddress1 ? _self.installationAddress1 : installationAddress1 // ignore: cast_nullable_to_non_nullable
as String?,installationAddress2: freezed == installationAddress2 ? _self.installationAddress2 : installationAddress2 // ignore: cast_nullable_to_non_nullable
as String?,pinCode: freezed == pinCode ? _self.pinCode : pinCode // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,idType: freezed == idType ? _self.idType : idType // ignore: cast_nullable_to_non_nullable
as String?,idNumber: freezed == idNumber ? _self.idNumber : idNumber // ignore: cast_nullable_to_non_nullable
as String?,customerTypeId: freezed == customerTypeId ? _self.customerTypeId : customerTypeId // ignore: cast_nullable_to_non_nullable
as String?,customerTypeTypesId: freezed == customerTypeTypesId ? _self.customerTypeTypesId : customerTypeTypesId // ignore: cast_nullable_to_non_nullable
as String?,groupId: freezed == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String?,cafNumber: freezed == cafNumber ? _self.cafNumber : cafNumber // ignore: cast_nullable_to_non_nullable
as String?,lcoCustomerId: freezed == lcoCustomerId ? _self.lcoCustomerId : lcoCustomerId // ignore: cast_nullable_to_non_nullable
as String?,businessName: freezed == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String?,fatherName: freezed == fatherName ? _self.fatherName : fatherName // ignore: cast_nullable_to_non_nullable
as String?,accountNumber: freezed == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String?,billType: freezed == billType ? _self.billType : billType // ignore: cast_nullable_to_non_nullable
as String?,dob: freezed == dob ? _self.dob : dob // ignore: cast_nullable_to_non_nullable
as String?,doa: freezed == doa ? _self.doa : doa // ignore: cast_nullable_to_non_nullable
as String?,discount: freezed == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as double?,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,countryCode: freezed == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String?,stateId: freezed == stateId ? _self.stateId : stateId // ignore: cast_nullable_to_non_nullable
as String?,districtId: freezed == districtId ? _self.districtId : districtId // ignore: cast_nullable_to_non_nullable
as String?,cityId: freezed == cityId ? _self.cityId : cityId // ignore: cast_nullable_to_non_nullable
as String?,mandalId: freezed == mandalId ? _self.mandalId : mandalId // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,changeAddress: null == changeAddress ? _self.changeAddress : changeAddress // ignore: cast_nullable_to_non_nullable
as bool,changeInstallAddress: null == changeInstallAddress ? _self.changeInstallAddress : changeInstallAddress // ignore: cast_nullable_to_non_nullable
as bool,uploadDocs: null == uploadDocs ? _self.uploadDocs : uploadDocs // ignore: cast_nullable_to_non_nullable
as bool,idPhoto: freezed == idPhoto ? _self.idPhoto : idPhoto // ignore: cast_nullable_to_non_nullable
as String?,customerPhoto: freezed == customerPhoto ? _self.customerPhoto : customerPhoto // ignore: cast_nullable_to_non_nullable
as String?,signatureImage: freezed == signatureImage ? _self.signatureImage : signatureImage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EditCustomerRequest].
extension EditCustomerRequestPatterns on EditCustomerRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EditCustomerRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EditCustomerRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EditCustomerRequest value)  $default,){
final _that = this;
switch (_that) {
case _EditCustomerRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EditCustomerRequest value)?  $default,){
final _that = this;
switch (_that) {
case _EditCustomerRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'customerId')  String customerId, @JsonKey(name: 'firstName')  String firstName, @JsonKey(name: 'lastName')  String? lastName, @JsonKey(name: 'mobileNumber')  String mobileNumber, @JsonKey(name: 'email')  String? email, @JsonKey(name: 'billingAddress1')  String? billingAddress1, @JsonKey(name: 'billingAddress2')  String? billingAddress2, @JsonKey(name: 'installationAddress1')  String? installationAddress1, @JsonKey(name: 'installationAddress2')  String? installationAddress2, @JsonKey(name: 'pinCode')  String? pinCode, @JsonKey(name: 'gender')  String? gender, @JsonKey(name: 'idType')  String? idType, @JsonKey(name: 'idNumber')  String? idNumber, @JsonKey(name: 'customerTypeId')  String? customerTypeId, @JsonKey(name: 'customerTypeTypesId')  String? customerTypeTypesId, @JsonKey(name: 'groupId')  String? groupId, @JsonKey(name: 'cafNumber')  String? cafNumber, @JsonKey(name: 'lcoCustomerId')  String? lcoCustomerId, @JsonKey(name: 'businessName')  String? businessName, @JsonKey(name: 'fatherName')  String? fatherName, @JsonKey(name: 'accountNumber')  String? accountNumber, @JsonKey(name: 'billType')  String? billType, @JsonKey(name: 'dob')  String? dob, @JsonKey(name: 'doa')  String? doa, @JsonKey(name: 'discount')  double? discount, @JsonKey(name: 'remarks')  String? remarks, @JsonKey(name: 'countryCode')  String? countryCode, @JsonKey(name: 'stateId')  String? stateId, @JsonKey(name: 'districtId')  String? districtId, @JsonKey(name: 'cityId')  String? cityId, @JsonKey(name: 'mandalId')  String? mandalId, @JsonKey(name: 'latitude')  double? latitude, @JsonKey(name: 'longitude')  double? longitude, @JsonKey(name: 'changeAddress', defaultValue: false)  bool changeAddress, @JsonKey(name: 'changeInstallAddress', defaultValue: false)  bool changeInstallAddress, @JsonKey(name: 'uploadDocs', defaultValue: false)  bool uploadDocs, @JsonKey(name: 'idPhoto')  String? idPhoto, @JsonKey(name: 'customerPhoto')  String? customerPhoto, @JsonKey(name: 'signatureImage')  String? signatureImage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EditCustomerRequest() when $default != null:
return $default(_that.customerId,_that.firstName,_that.lastName,_that.mobileNumber,_that.email,_that.billingAddress1,_that.billingAddress2,_that.installationAddress1,_that.installationAddress2,_that.pinCode,_that.gender,_that.idType,_that.idNumber,_that.customerTypeId,_that.customerTypeTypesId,_that.groupId,_that.cafNumber,_that.lcoCustomerId,_that.businessName,_that.fatherName,_that.accountNumber,_that.billType,_that.dob,_that.doa,_that.discount,_that.remarks,_that.countryCode,_that.stateId,_that.districtId,_that.cityId,_that.mandalId,_that.latitude,_that.longitude,_that.changeAddress,_that.changeInstallAddress,_that.uploadDocs,_that.idPhoto,_that.customerPhoto,_that.signatureImage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'customerId')  String customerId, @JsonKey(name: 'firstName')  String firstName, @JsonKey(name: 'lastName')  String? lastName, @JsonKey(name: 'mobileNumber')  String mobileNumber, @JsonKey(name: 'email')  String? email, @JsonKey(name: 'billingAddress1')  String? billingAddress1, @JsonKey(name: 'billingAddress2')  String? billingAddress2, @JsonKey(name: 'installationAddress1')  String? installationAddress1, @JsonKey(name: 'installationAddress2')  String? installationAddress2, @JsonKey(name: 'pinCode')  String? pinCode, @JsonKey(name: 'gender')  String? gender, @JsonKey(name: 'idType')  String? idType, @JsonKey(name: 'idNumber')  String? idNumber, @JsonKey(name: 'customerTypeId')  String? customerTypeId, @JsonKey(name: 'customerTypeTypesId')  String? customerTypeTypesId, @JsonKey(name: 'groupId')  String? groupId, @JsonKey(name: 'cafNumber')  String? cafNumber, @JsonKey(name: 'lcoCustomerId')  String? lcoCustomerId, @JsonKey(name: 'businessName')  String? businessName, @JsonKey(name: 'fatherName')  String? fatherName, @JsonKey(name: 'accountNumber')  String? accountNumber, @JsonKey(name: 'billType')  String? billType, @JsonKey(name: 'dob')  String? dob, @JsonKey(name: 'doa')  String? doa, @JsonKey(name: 'discount')  double? discount, @JsonKey(name: 'remarks')  String? remarks, @JsonKey(name: 'countryCode')  String? countryCode, @JsonKey(name: 'stateId')  String? stateId, @JsonKey(name: 'districtId')  String? districtId, @JsonKey(name: 'cityId')  String? cityId, @JsonKey(name: 'mandalId')  String? mandalId, @JsonKey(name: 'latitude')  double? latitude, @JsonKey(name: 'longitude')  double? longitude, @JsonKey(name: 'changeAddress', defaultValue: false)  bool changeAddress, @JsonKey(name: 'changeInstallAddress', defaultValue: false)  bool changeInstallAddress, @JsonKey(name: 'uploadDocs', defaultValue: false)  bool uploadDocs, @JsonKey(name: 'idPhoto')  String? idPhoto, @JsonKey(name: 'customerPhoto')  String? customerPhoto, @JsonKey(name: 'signatureImage')  String? signatureImage)  $default,) {final _that = this;
switch (_that) {
case _EditCustomerRequest():
return $default(_that.customerId,_that.firstName,_that.lastName,_that.mobileNumber,_that.email,_that.billingAddress1,_that.billingAddress2,_that.installationAddress1,_that.installationAddress2,_that.pinCode,_that.gender,_that.idType,_that.idNumber,_that.customerTypeId,_that.customerTypeTypesId,_that.groupId,_that.cafNumber,_that.lcoCustomerId,_that.businessName,_that.fatherName,_that.accountNumber,_that.billType,_that.dob,_that.doa,_that.discount,_that.remarks,_that.countryCode,_that.stateId,_that.districtId,_that.cityId,_that.mandalId,_that.latitude,_that.longitude,_that.changeAddress,_that.changeInstallAddress,_that.uploadDocs,_that.idPhoto,_that.customerPhoto,_that.signatureImage);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'customerId')  String customerId, @JsonKey(name: 'firstName')  String firstName, @JsonKey(name: 'lastName')  String? lastName, @JsonKey(name: 'mobileNumber')  String mobileNumber, @JsonKey(name: 'email')  String? email, @JsonKey(name: 'billingAddress1')  String? billingAddress1, @JsonKey(name: 'billingAddress2')  String? billingAddress2, @JsonKey(name: 'installationAddress1')  String? installationAddress1, @JsonKey(name: 'installationAddress2')  String? installationAddress2, @JsonKey(name: 'pinCode')  String? pinCode, @JsonKey(name: 'gender')  String? gender, @JsonKey(name: 'idType')  String? idType, @JsonKey(name: 'idNumber')  String? idNumber, @JsonKey(name: 'customerTypeId')  String? customerTypeId, @JsonKey(name: 'customerTypeTypesId')  String? customerTypeTypesId, @JsonKey(name: 'groupId')  String? groupId, @JsonKey(name: 'cafNumber')  String? cafNumber, @JsonKey(name: 'lcoCustomerId')  String? lcoCustomerId, @JsonKey(name: 'businessName')  String? businessName, @JsonKey(name: 'fatherName')  String? fatherName, @JsonKey(name: 'accountNumber')  String? accountNumber, @JsonKey(name: 'billType')  String? billType, @JsonKey(name: 'dob')  String? dob, @JsonKey(name: 'doa')  String? doa, @JsonKey(name: 'discount')  double? discount, @JsonKey(name: 'remarks')  String? remarks, @JsonKey(name: 'countryCode')  String? countryCode, @JsonKey(name: 'stateId')  String? stateId, @JsonKey(name: 'districtId')  String? districtId, @JsonKey(name: 'cityId')  String? cityId, @JsonKey(name: 'mandalId')  String? mandalId, @JsonKey(name: 'latitude')  double? latitude, @JsonKey(name: 'longitude')  double? longitude, @JsonKey(name: 'changeAddress', defaultValue: false)  bool changeAddress, @JsonKey(name: 'changeInstallAddress', defaultValue: false)  bool changeInstallAddress, @JsonKey(name: 'uploadDocs', defaultValue: false)  bool uploadDocs, @JsonKey(name: 'idPhoto')  String? idPhoto, @JsonKey(name: 'customerPhoto')  String? customerPhoto, @JsonKey(name: 'signatureImage')  String? signatureImage)?  $default,) {final _that = this;
switch (_that) {
case _EditCustomerRequest() when $default != null:
return $default(_that.customerId,_that.firstName,_that.lastName,_that.mobileNumber,_that.email,_that.billingAddress1,_that.billingAddress2,_that.installationAddress1,_that.installationAddress2,_that.pinCode,_that.gender,_that.idType,_that.idNumber,_that.customerTypeId,_that.customerTypeTypesId,_that.groupId,_that.cafNumber,_that.lcoCustomerId,_that.businessName,_that.fatherName,_that.accountNumber,_that.billType,_that.dob,_that.doa,_that.discount,_that.remarks,_that.countryCode,_that.stateId,_that.districtId,_that.cityId,_that.mandalId,_that.latitude,_that.longitude,_that.changeAddress,_that.changeInstallAddress,_that.uploadDocs,_that.idPhoto,_that.customerPhoto,_that.signatureImage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EditCustomerRequest implements EditCustomerRequest {
  const _EditCustomerRequest({@JsonKey(name: 'customerId') required this.customerId, @JsonKey(name: 'firstName') required this.firstName, @JsonKey(name: 'lastName') this.lastName, @JsonKey(name: 'mobileNumber') required this.mobileNumber, @JsonKey(name: 'email') this.email, @JsonKey(name: 'billingAddress1') this.billingAddress1, @JsonKey(name: 'billingAddress2') this.billingAddress2, @JsonKey(name: 'installationAddress1') this.installationAddress1, @JsonKey(name: 'installationAddress2') this.installationAddress2, @JsonKey(name: 'pinCode') this.pinCode, @JsonKey(name: 'gender') this.gender, @JsonKey(name: 'idType') this.idType, @JsonKey(name: 'idNumber') this.idNumber, @JsonKey(name: 'customerTypeId') this.customerTypeId, @JsonKey(name: 'customerTypeTypesId') this.customerTypeTypesId, @JsonKey(name: 'groupId') this.groupId, @JsonKey(name: 'cafNumber') this.cafNumber, @JsonKey(name: 'lcoCustomerId') this.lcoCustomerId, @JsonKey(name: 'businessName') this.businessName, @JsonKey(name: 'fatherName') this.fatherName, @JsonKey(name: 'accountNumber') this.accountNumber, @JsonKey(name: 'billType') this.billType, @JsonKey(name: 'dob') this.dob, @JsonKey(name: 'doa') this.doa, @JsonKey(name: 'discount') this.discount, @JsonKey(name: 'remarks') this.remarks, @JsonKey(name: 'countryCode') this.countryCode, @JsonKey(name: 'stateId') this.stateId, @JsonKey(name: 'districtId') this.districtId, @JsonKey(name: 'cityId') this.cityId, @JsonKey(name: 'mandalId') this.mandalId, @JsonKey(name: 'latitude') this.latitude, @JsonKey(name: 'longitude') this.longitude, @JsonKey(name: 'changeAddress', defaultValue: false) required this.changeAddress, @JsonKey(name: 'changeInstallAddress', defaultValue: false) required this.changeInstallAddress, @JsonKey(name: 'uploadDocs', defaultValue: false) required this.uploadDocs, @JsonKey(name: 'idPhoto') this.idPhoto, @JsonKey(name: 'customerPhoto') this.customerPhoto, @JsonKey(name: 'signatureImage') this.signatureImage});
  factory _EditCustomerRequest.fromJson(Map<String, dynamic> json) => _$EditCustomerRequestFromJson(json);

@override@JsonKey(name: 'customerId') final  String customerId;
@override@JsonKey(name: 'firstName') final  String firstName;
@override@JsonKey(name: 'lastName') final  String? lastName;
@override@JsonKey(name: 'mobileNumber') final  String mobileNumber;
@override@JsonKey(name: 'email') final  String? email;
@override@JsonKey(name: 'billingAddress1') final  String? billingAddress1;
@override@JsonKey(name: 'billingAddress2') final  String? billingAddress2;
@override@JsonKey(name: 'installationAddress1') final  String? installationAddress1;
@override@JsonKey(name: 'installationAddress2') final  String? installationAddress2;
@override@JsonKey(name: 'pinCode') final  String? pinCode;
@override@JsonKey(name: 'gender') final  String? gender;
@override@JsonKey(name: 'idType') final  String? idType;
@override@JsonKey(name: 'idNumber') final  String? idNumber;
@override@JsonKey(name: 'customerTypeId') final  String? customerTypeId;
@override@JsonKey(name: 'customerTypeTypesId') final  String? customerTypeTypesId;
@override@JsonKey(name: 'groupId') final  String? groupId;
@override@JsonKey(name: 'cafNumber') final  String? cafNumber;
@override@JsonKey(name: 'lcoCustomerId') final  String? lcoCustomerId;
@override@JsonKey(name: 'businessName') final  String? businessName;
@override@JsonKey(name: 'fatherName') final  String? fatherName;
@override@JsonKey(name: 'accountNumber') final  String? accountNumber;
@override@JsonKey(name: 'billType') final  String? billType;
@override@JsonKey(name: 'dob') final  String? dob;
@override@JsonKey(name: 'doa') final  String? doa;
@override@JsonKey(name: 'discount') final  double? discount;
@override@JsonKey(name: 'remarks') final  String? remarks;
@override@JsonKey(name: 'countryCode') final  String? countryCode;
@override@JsonKey(name: 'stateId') final  String? stateId;
@override@JsonKey(name: 'districtId') final  String? districtId;
@override@JsonKey(name: 'cityId') final  String? cityId;
@override@JsonKey(name: 'mandalId') final  String? mandalId;
@override@JsonKey(name: 'latitude') final  double? latitude;
@override@JsonKey(name: 'longitude') final  double? longitude;
@override@JsonKey(name: 'changeAddress', defaultValue: false) final  bool changeAddress;
@override@JsonKey(name: 'changeInstallAddress', defaultValue: false) final  bool changeInstallAddress;
@override@JsonKey(name: 'uploadDocs', defaultValue: false) final  bool uploadDocs;
@override@JsonKey(name: 'idPhoto') final  String? idPhoto;
@override@JsonKey(name: 'customerPhoto') final  String? customerPhoto;
@override@JsonKey(name: 'signatureImage') final  String? signatureImage;

/// Create a copy of EditCustomerRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EditCustomerRequestCopyWith<_EditCustomerRequest> get copyWith => __$EditCustomerRequestCopyWithImpl<_EditCustomerRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EditCustomerRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EditCustomerRequest&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.mobileNumber, mobileNumber) || other.mobileNumber == mobileNumber)&&(identical(other.email, email) || other.email == email)&&(identical(other.billingAddress1, billingAddress1) || other.billingAddress1 == billingAddress1)&&(identical(other.billingAddress2, billingAddress2) || other.billingAddress2 == billingAddress2)&&(identical(other.installationAddress1, installationAddress1) || other.installationAddress1 == installationAddress1)&&(identical(other.installationAddress2, installationAddress2) || other.installationAddress2 == installationAddress2)&&(identical(other.pinCode, pinCode) || other.pinCode == pinCode)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.idType, idType) || other.idType == idType)&&(identical(other.idNumber, idNumber) || other.idNumber == idNumber)&&(identical(other.customerTypeId, customerTypeId) || other.customerTypeId == customerTypeId)&&(identical(other.customerTypeTypesId, customerTypeTypesId) || other.customerTypeTypesId == customerTypeTypesId)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.cafNumber, cafNumber) || other.cafNumber == cafNumber)&&(identical(other.lcoCustomerId, lcoCustomerId) || other.lcoCustomerId == lcoCustomerId)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.fatherName, fatherName) || other.fatherName == fatherName)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.billType, billType) || other.billType == billType)&&(identical(other.dob, dob) || other.dob == dob)&&(identical(other.doa, doa) || other.doa == doa)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.stateId, stateId) || other.stateId == stateId)&&(identical(other.districtId, districtId) || other.districtId == districtId)&&(identical(other.cityId, cityId) || other.cityId == cityId)&&(identical(other.mandalId, mandalId) || other.mandalId == mandalId)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.changeAddress, changeAddress) || other.changeAddress == changeAddress)&&(identical(other.changeInstallAddress, changeInstallAddress) || other.changeInstallAddress == changeInstallAddress)&&(identical(other.uploadDocs, uploadDocs) || other.uploadDocs == uploadDocs)&&(identical(other.idPhoto, idPhoto) || other.idPhoto == idPhoto)&&(identical(other.customerPhoto, customerPhoto) || other.customerPhoto == customerPhoto)&&(identical(other.signatureImage, signatureImage) || other.signatureImage == signatureImage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,customerId,firstName,lastName,mobileNumber,email,billingAddress1,billingAddress2,installationAddress1,installationAddress2,pinCode,gender,idType,idNumber,customerTypeId,customerTypeTypesId,groupId,cafNumber,lcoCustomerId,businessName,fatherName,accountNumber,billType,dob,doa,discount,remarks,countryCode,stateId,districtId,cityId,mandalId,latitude,longitude,changeAddress,changeInstallAddress,uploadDocs,idPhoto,customerPhoto,signatureImage]);

@override
String toString() {
  return 'EditCustomerRequest(customerId: $customerId, firstName: $firstName, lastName: $lastName, mobileNumber: $mobileNumber, email: $email, billingAddress1: $billingAddress1, billingAddress2: $billingAddress2, installationAddress1: $installationAddress1, installationAddress2: $installationAddress2, pinCode: $pinCode, gender: $gender, idType: $idType, idNumber: $idNumber, customerTypeId: $customerTypeId, customerTypeTypesId: $customerTypeTypesId, groupId: $groupId, cafNumber: $cafNumber, lcoCustomerId: $lcoCustomerId, businessName: $businessName, fatherName: $fatherName, accountNumber: $accountNumber, billType: $billType, dob: $dob, doa: $doa, discount: $discount, remarks: $remarks, countryCode: $countryCode, stateId: $stateId, districtId: $districtId, cityId: $cityId, mandalId: $mandalId, latitude: $latitude, longitude: $longitude, changeAddress: $changeAddress, changeInstallAddress: $changeInstallAddress, uploadDocs: $uploadDocs, idPhoto: $idPhoto, customerPhoto: $customerPhoto, signatureImage: $signatureImage)';
}


}

/// @nodoc
abstract mixin class _$EditCustomerRequestCopyWith<$Res> implements $EditCustomerRequestCopyWith<$Res> {
  factory _$EditCustomerRequestCopyWith(_EditCustomerRequest value, $Res Function(_EditCustomerRequest) _then) = __$EditCustomerRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'customerId') String customerId,@JsonKey(name: 'firstName') String firstName,@JsonKey(name: 'lastName') String? lastName,@JsonKey(name: 'mobileNumber') String mobileNumber,@JsonKey(name: 'email') String? email,@JsonKey(name: 'billingAddress1') String? billingAddress1,@JsonKey(name: 'billingAddress2') String? billingAddress2,@JsonKey(name: 'installationAddress1') String? installationAddress1,@JsonKey(name: 'installationAddress2') String? installationAddress2,@JsonKey(name: 'pinCode') String? pinCode,@JsonKey(name: 'gender') String? gender,@JsonKey(name: 'idType') String? idType,@JsonKey(name: 'idNumber') String? idNumber,@JsonKey(name: 'customerTypeId') String? customerTypeId,@JsonKey(name: 'customerTypeTypesId') String? customerTypeTypesId,@JsonKey(name: 'groupId') String? groupId,@JsonKey(name: 'cafNumber') String? cafNumber,@JsonKey(name: 'lcoCustomerId') String? lcoCustomerId,@JsonKey(name: 'businessName') String? businessName,@JsonKey(name: 'fatherName') String? fatherName,@JsonKey(name: 'accountNumber') String? accountNumber,@JsonKey(name: 'billType') String? billType,@JsonKey(name: 'dob') String? dob,@JsonKey(name: 'doa') String? doa,@JsonKey(name: 'discount') double? discount,@JsonKey(name: 'remarks') String? remarks,@JsonKey(name: 'countryCode') String? countryCode,@JsonKey(name: 'stateId') String? stateId,@JsonKey(name: 'districtId') String? districtId,@JsonKey(name: 'cityId') String? cityId,@JsonKey(name: 'mandalId') String? mandalId,@JsonKey(name: 'latitude') double? latitude,@JsonKey(name: 'longitude') double? longitude,@JsonKey(name: 'changeAddress', defaultValue: false) bool changeAddress,@JsonKey(name: 'changeInstallAddress', defaultValue: false) bool changeInstallAddress,@JsonKey(name: 'uploadDocs', defaultValue: false) bool uploadDocs,@JsonKey(name: 'idPhoto') String? idPhoto,@JsonKey(name: 'customerPhoto') String? customerPhoto,@JsonKey(name: 'signatureImage') String? signatureImage
});




}
/// @nodoc
class __$EditCustomerRequestCopyWithImpl<$Res>
    implements _$EditCustomerRequestCopyWith<$Res> {
  __$EditCustomerRequestCopyWithImpl(this._self, this._then);

  final _EditCustomerRequest _self;
  final $Res Function(_EditCustomerRequest) _then;

/// Create a copy of EditCustomerRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? customerId = null,Object? firstName = null,Object? lastName = freezed,Object? mobileNumber = null,Object? email = freezed,Object? billingAddress1 = freezed,Object? billingAddress2 = freezed,Object? installationAddress1 = freezed,Object? installationAddress2 = freezed,Object? pinCode = freezed,Object? gender = freezed,Object? idType = freezed,Object? idNumber = freezed,Object? customerTypeId = freezed,Object? customerTypeTypesId = freezed,Object? groupId = freezed,Object? cafNumber = freezed,Object? lcoCustomerId = freezed,Object? businessName = freezed,Object? fatherName = freezed,Object? accountNumber = freezed,Object? billType = freezed,Object? dob = freezed,Object? doa = freezed,Object? discount = freezed,Object? remarks = freezed,Object? countryCode = freezed,Object? stateId = freezed,Object? districtId = freezed,Object? cityId = freezed,Object? mandalId = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? changeAddress = null,Object? changeInstallAddress = null,Object? uploadDocs = null,Object? idPhoto = freezed,Object? customerPhoto = freezed,Object? signatureImage = freezed,}) {
  return _then(_EditCustomerRequest(
customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,mobileNumber: null == mobileNumber ? _self.mobileNumber : mobileNumber // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,billingAddress1: freezed == billingAddress1 ? _self.billingAddress1 : billingAddress1 // ignore: cast_nullable_to_non_nullable
as String?,billingAddress2: freezed == billingAddress2 ? _self.billingAddress2 : billingAddress2 // ignore: cast_nullable_to_non_nullable
as String?,installationAddress1: freezed == installationAddress1 ? _self.installationAddress1 : installationAddress1 // ignore: cast_nullable_to_non_nullable
as String?,installationAddress2: freezed == installationAddress2 ? _self.installationAddress2 : installationAddress2 // ignore: cast_nullable_to_non_nullable
as String?,pinCode: freezed == pinCode ? _self.pinCode : pinCode // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,idType: freezed == idType ? _self.idType : idType // ignore: cast_nullable_to_non_nullable
as String?,idNumber: freezed == idNumber ? _self.idNumber : idNumber // ignore: cast_nullable_to_non_nullable
as String?,customerTypeId: freezed == customerTypeId ? _self.customerTypeId : customerTypeId // ignore: cast_nullable_to_non_nullable
as String?,customerTypeTypesId: freezed == customerTypeTypesId ? _self.customerTypeTypesId : customerTypeTypesId // ignore: cast_nullable_to_non_nullable
as String?,groupId: freezed == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String?,cafNumber: freezed == cafNumber ? _self.cafNumber : cafNumber // ignore: cast_nullable_to_non_nullable
as String?,lcoCustomerId: freezed == lcoCustomerId ? _self.lcoCustomerId : lcoCustomerId // ignore: cast_nullable_to_non_nullable
as String?,businessName: freezed == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String?,fatherName: freezed == fatherName ? _self.fatherName : fatherName // ignore: cast_nullable_to_non_nullable
as String?,accountNumber: freezed == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String?,billType: freezed == billType ? _self.billType : billType // ignore: cast_nullable_to_non_nullable
as String?,dob: freezed == dob ? _self.dob : dob // ignore: cast_nullable_to_non_nullable
as String?,doa: freezed == doa ? _self.doa : doa // ignore: cast_nullable_to_non_nullable
as String?,discount: freezed == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as double?,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,countryCode: freezed == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String?,stateId: freezed == stateId ? _self.stateId : stateId // ignore: cast_nullable_to_non_nullable
as String?,districtId: freezed == districtId ? _self.districtId : districtId // ignore: cast_nullable_to_non_nullable
as String?,cityId: freezed == cityId ? _self.cityId : cityId // ignore: cast_nullable_to_non_nullable
as String?,mandalId: freezed == mandalId ? _self.mandalId : mandalId // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,changeAddress: null == changeAddress ? _self.changeAddress : changeAddress // ignore: cast_nullable_to_non_nullable
as bool,changeInstallAddress: null == changeInstallAddress ? _self.changeInstallAddress : changeInstallAddress // ignore: cast_nullable_to_non_nullable
as bool,uploadDocs: null == uploadDocs ? _self.uploadDocs : uploadDocs // ignore: cast_nullable_to_non_nullable
as bool,idPhoto: freezed == idPhoto ? _self.idPhoto : idPhoto // ignore: cast_nullable_to_non_nullable
as String?,customerPhoto: freezed == customerPhoto ? _self.customerPhoto : customerPhoto // ignore: cast_nullable_to_non_nullable
as String?,signatureImage: freezed == signatureImage ? _self.signatureImage : signatureImage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
