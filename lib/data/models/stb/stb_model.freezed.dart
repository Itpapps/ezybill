// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stb_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StbModel {

@JsonKey(name: 'serial_number') String get stbNo;@JsonKey(name: 'vc_number') String get vcNo;@JsonKey(name: 'customer_id') String? get customerId;@JsonKey(name: 'status') String get status;@JsonKey(name: 'cas_display_name') String get casType;@JsonKey(name: 'box_number') String? get boxNumber;@JsonKey(name: 'mac_address') String? get macAddress;@JsonKey(name: 'stock_id') String? get stockId;@JsonKey(name: 'device_id') String? get deviceId;@JsonKey(name: 'backend_setup_id') String? get backendSetupId;@JsonKey(name: 'stock_status') String? get stockStatus;@JsonKey(name: 'activation_date') String? get activatedDate;@JsonKey(name: 'assigned_date') String? get assignedDate;@JsonKey(name: 'is_assigned') int get isAssigned;@JsonKey(name: 'installation_address') String? get installationAddress;@JsonKey(name: 'is_temp_deactivated') int get isTempDeactivated;// New fields from server
@JsonKey(name: 'stb_type') String? get stbType;@JsonKey(name: 'stb_model') String? get stbModel;@JsonKey(name: 'stock_location') String? get stockLocation;@JsonKey(name: 'customer_name') String? get customerName;@JsonKey(name: 'mobile_no') String? get mobileNo;
/// Create a copy of StbModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StbModelCopyWith<StbModel> get copyWith => _$StbModelCopyWithImpl<StbModel>(this as StbModel, _$identity);

  /// Serializes this StbModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StbModel&&(identical(other.stbNo, stbNo) || other.stbNo == stbNo)&&(identical(other.vcNo, vcNo) || other.vcNo == vcNo)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.status, status) || other.status == status)&&(identical(other.casType, casType) || other.casType == casType)&&(identical(other.boxNumber, boxNumber) || other.boxNumber == boxNumber)&&(identical(other.macAddress, macAddress) || other.macAddress == macAddress)&&(identical(other.stockId, stockId) || other.stockId == stockId)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.backendSetupId, backendSetupId) || other.backendSetupId == backendSetupId)&&(identical(other.stockStatus, stockStatus) || other.stockStatus == stockStatus)&&(identical(other.activatedDate, activatedDate) || other.activatedDate == activatedDate)&&(identical(other.assignedDate, assignedDate) || other.assignedDate == assignedDate)&&(identical(other.isAssigned, isAssigned) || other.isAssigned == isAssigned)&&(identical(other.installationAddress, installationAddress) || other.installationAddress == installationAddress)&&(identical(other.isTempDeactivated, isTempDeactivated) || other.isTempDeactivated == isTempDeactivated)&&(identical(other.stbType, stbType) || other.stbType == stbType)&&(identical(other.stbModel, stbModel) || other.stbModel == stbModel)&&(identical(other.stockLocation, stockLocation) || other.stockLocation == stockLocation)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.mobileNo, mobileNo) || other.mobileNo == mobileNo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,stbNo,vcNo,customerId,status,casType,boxNumber,macAddress,stockId,deviceId,backendSetupId,stockStatus,activatedDate,assignedDate,isAssigned,installationAddress,isTempDeactivated,stbType,stbModel,stockLocation,customerName,mobileNo]);

@override
String toString() {
  return 'StbModel(stbNo: $stbNo, vcNo: $vcNo, customerId: $customerId, status: $status, casType: $casType, boxNumber: $boxNumber, macAddress: $macAddress, stockId: $stockId, deviceId: $deviceId, backendSetupId: $backendSetupId, stockStatus: $stockStatus, activatedDate: $activatedDate, assignedDate: $assignedDate, isAssigned: $isAssigned, installationAddress: $installationAddress, isTempDeactivated: $isTempDeactivated, stbType: $stbType, stbModel: $stbModel, stockLocation: $stockLocation, customerName: $customerName, mobileNo: $mobileNo)';
}


}

/// @nodoc
abstract mixin class $StbModelCopyWith<$Res>  {
  factory $StbModelCopyWith(StbModel value, $Res Function(StbModel) _then) = _$StbModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'serial_number') String stbNo,@JsonKey(name: 'vc_number') String vcNo,@JsonKey(name: 'customer_id') String? customerId,@JsonKey(name: 'status') String status,@JsonKey(name: 'cas_display_name') String casType,@JsonKey(name: 'box_number') String? boxNumber,@JsonKey(name: 'mac_address') String? macAddress,@JsonKey(name: 'stock_id') String? stockId,@JsonKey(name: 'device_id') String? deviceId,@JsonKey(name: 'backend_setup_id') String? backendSetupId,@JsonKey(name: 'stock_status') String? stockStatus,@JsonKey(name: 'activation_date') String? activatedDate,@JsonKey(name: 'assigned_date') String? assignedDate,@JsonKey(name: 'is_assigned') int isAssigned,@JsonKey(name: 'installation_address') String? installationAddress,@JsonKey(name: 'is_temp_deactivated') int isTempDeactivated,@JsonKey(name: 'stb_type') String? stbType,@JsonKey(name: 'stb_model') String? stbModel,@JsonKey(name: 'stock_location') String? stockLocation,@JsonKey(name: 'customer_name') String? customerName,@JsonKey(name: 'mobile_no') String? mobileNo
});




}
/// @nodoc
class _$StbModelCopyWithImpl<$Res>
    implements $StbModelCopyWith<$Res> {
  _$StbModelCopyWithImpl(this._self, this._then);

  final StbModel _self;
  final $Res Function(StbModel) _then;

/// Create a copy of StbModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stbNo = null,Object? vcNo = null,Object? customerId = freezed,Object? status = null,Object? casType = null,Object? boxNumber = freezed,Object? macAddress = freezed,Object? stockId = freezed,Object? deviceId = freezed,Object? backendSetupId = freezed,Object? stockStatus = freezed,Object? activatedDate = freezed,Object? assignedDate = freezed,Object? isAssigned = null,Object? installationAddress = freezed,Object? isTempDeactivated = null,Object? stbType = freezed,Object? stbModel = freezed,Object? stockLocation = freezed,Object? customerName = freezed,Object? mobileNo = freezed,}) {
  return _then(_self.copyWith(
stbNo: null == stbNo ? _self.stbNo : stbNo // ignore: cast_nullable_to_non_nullable
as String,vcNo: null == vcNo ? _self.vcNo : vcNo // ignore: cast_nullable_to_non_nullable
as String,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,casType: null == casType ? _self.casType : casType // ignore: cast_nullable_to_non_nullable
as String,boxNumber: freezed == boxNumber ? _self.boxNumber : boxNumber // ignore: cast_nullable_to_non_nullable
as String?,macAddress: freezed == macAddress ? _self.macAddress : macAddress // ignore: cast_nullable_to_non_nullable
as String?,stockId: freezed == stockId ? _self.stockId : stockId // ignore: cast_nullable_to_non_nullable
as String?,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,backendSetupId: freezed == backendSetupId ? _self.backendSetupId : backendSetupId // ignore: cast_nullable_to_non_nullable
as String?,stockStatus: freezed == stockStatus ? _self.stockStatus : stockStatus // ignore: cast_nullable_to_non_nullable
as String?,activatedDate: freezed == activatedDate ? _self.activatedDate : activatedDate // ignore: cast_nullable_to_non_nullable
as String?,assignedDate: freezed == assignedDate ? _self.assignedDate : assignedDate // ignore: cast_nullable_to_non_nullable
as String?,isAssigned: null == isAssigned ? _self.isAssigned : isAssigned // ignore: cast_nullable_to_non_nullable
as int,installationAddress: freezed == installationAddress ? _self.installationAddress : installationAddress // ignore: cast_nullable_to_non_nullable
as String?,isTempDeactivated: null == isTempDeactivated ? _self.isTempDeactivated : isTempDeactivated // ignore: cast_nullable_to_non_nullable
as int,stbType: freezed == stbType ? _self.stbType : stbType // ignore: cast_nullable_to_non_nullable
as String?,stbModel: freezed == stbModel ? _self.stbModel : stbModel // ignore: cast_nullable_to_non_nullable
as String?,stockLocation: freezed == stockLocation ? _self.stockLocation : stockLocation // ignore: cast_nullable_to_non_nullable
as String?,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,mobileNo: freezed == mobileNo ? _self.mobileNo : mobileNo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StbModel].
extension StbModelPatterns on StbModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StbModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StbModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StbModel value)  $default,){
final _that = this;
switch (_that) {
case _StbModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StbModel value)?  $default,){
final _that = this;
switch (_that) {
case _StbModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'serial_number')  String stbNo, @JsonKey(name: 'vc_number')  String vcNo, @JsonKey(name: 'customer_id')  String? customerId, @JsonKey(name: 'status')  String status, @JsonKey(name: 'cas_display_name')  String casType, @JsonKey(name: 'box_number')  String? boxNumber, @JsonKey(name: 'mac_address')  String? macAddress, @JsonKey(name: 'stock_id')  String? stockId, @JsonKey(name: 'device_id')  String? deviceId, @JsonKey(name: 'backend_setup_id')  String? backendSetupId, @JsonKey(name: 'stock_status')  String? stockStatus, @JsonKey(name: 'activation_date')  String? activatedDate, @JsonKey(name: 'assigned_date')  String? assignedDate, @JsonKey(name: 'is_assigned')  int isAssigned, @JsonKey(name: 'installation_address')  String? installationAddress, @JsonKey(name: 'is_temp_deactivated')  int isTempDeactivated, @JsonKey(name: 'stb_type')  String? stbType, @JsonKey(name: 'stb_model')  String? stbModel, @JsonKey(name: 'stock_location')  String? stockLocation, @JsonKey(name: 'customer_name')  String? customerName, @JsonKey(name: 'mobile_no')  String? mobileNo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StbModel() when $default != null:
return $default(_that.stbNo,_that.vcNo,_that.customerId,_that.status,_that.casType,_that.boxNumber,_that.macAddress,_that.stockId,_that.deviceId,_that.backendSetupId,_that.stockStatus,_that.activatedDate,_that.assignedDate,_that.isAssigned,_that.installationAddress,_that.isTempDeactivated,_that.stbType,_that.stbModel,_that.stockLocation,_that.customerName,_that.mobileNo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'serial_number')  String stbNo, @JsonKey(name: 'vc_number')  String vcNo, @JsonKey(name: 'customer_id')  String? customerId, @JsonKey(name: 'status')  String status, @JsonKey(name: 'cas_display_name')  String casType, @JsonKey(name: 'box_number')  String? boxNumber, @JsonKey(name: 'mac_address')  String? macAddress, @JsonKey(name: 'stock_id')  String? stockId, @JsonKey(name: 'device_id')  String? deviceId, @JsonKey(name: 'backend_setup_id')  String? backendSetupId, @JsonKey(name: 'stock_status')  String? stockStatus, @JsonKey(name: 'activation_date')  String? activatedDate, @JsonKey(name: 'assigned_date')  String? assignedDate, @JsonKey(name: 'is_assigned')  int isAssigned, @JsonKey(name: 'installation_address')  String? installationAddress, @JsonKey(name: 'is_temp_deactivated')  int isTempDeactivated, @JsonKey(name: 'stb_type')  String? stbType, @JsonKey(name: 'stb_model')  String? stbModel, @JsonKey(name: 'stock_location')  String? stockLocation, @JsonKey(name: 'customer_name')  String? customerName, @JsonKey(name: 'mobile_no')  String? mobileNo)  $default,) {final _that = this;
switch (_that) {
case _StbModel():
return $default(_that.stbNo,_that.vcNo,_that.customerId,_that.status,_that.casType,_that.boxNumber,_that.macAddress,_that.stockId,_that.deviceId,_that.backendSetupId,_that.stockStatus,_that.activatedDate,_that.assignedDate,_that.isAssigned,_that.installationAddress,_that.isTempDeactivated,_that.stbType,_that.stbModel,_that.stockLocation,_that.customerName,_that.mobileNo);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'serial_number')  String stbNo, @JsonKey(name: 'vc_number')  String vcNo, @JsonKey(name: 'customer_id')  String? customerId, @JsonKey(name: 'status')  String status, @JsonKey(name: 'cas_display_name')  String casType, @JsonKey(name: 'box_number')  String? boxNumber, @JsonKey(name: 'mac_address')  String? macAddress, @JsonKey(name: 'stock_id')  String? stockId, @JsonKey(name: 'device_id')  String? deviceId, @JsonKey(name: 'backend_setup_id')  String? backendSetupId, @JsonKey(name: 'stock_status')  String? stockStatus, @JsonKey(name: 'activation_date')  String? activatedDate, @JsonKey(name: 'assigned_date')  String? assignedDate, @JsonKey(name: 'is_assigned')  int isAssigned, @JsonKey(name: 'installation_address')  String? installationAddress, @JsonKey(name: 'is_temp_deactivated')  int isTempDeactivated, @JsonKey(name: 'stb_type')  String? stbType, @JsonKey(name: 'stb_model')  String? stbModel, @JsonKey(name: 'stock_location')  String? stockLocation, @JsonKey(name: 'customer_name')  String? customerName, @JsonKey(name: 'mobile_no')  String? mobileNo)?  $default,) {final _that = this;
switch (_that) {
case _StbModel() when $default != null:
return $default(_that.stbNo,_that.vcNo,_that.customerId,_that.status,_that.casType,_that.boxNumber,_that.macAddress,_that.stockId,_that.deviceId,_that.backendSetupId,_that.stockStatus,_that.activatedDate,_that.assignedDate,_that.isAssigned,_that.installationAddress,_that.isTempDeactivated,_that.stbType,_that.stbModel,_that.stockLocation,_that.customerName,_that.mobileNo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StbModel implements StbModel {
  const _StbModel({@JsonKey(name: 'serial_number') this.stbNo = '', @JsonKey(name: 'vc_number') this.vcNo = '', @JsonKey(name: 'customer_id') this.customerId, @JsonKey(name: 'status') this.status = '', @JsonKey(name: 'cas_display_name') this.casType = '', @JsonKey(name: 'box_number') this.boxNumber, @JsonKey(name: 'mac_address') this.macAddress, @JsonKey(name: 'stock_id') this.stockId, @JsonKey(name: 'device_id') this.deviceId, @JsonKey(name: 'backend_setup_id') this.backendSetupId, @JsonKey(name: 'stock_status') this.stockStatus, @JsonKey(name: 'activation_date') this.activatedDate, @JsonKey(name: 'assigned_date') this.assignedDate, @JsonKey(name: 'is_assigned') this.isAssigned = 0, @JsonKey(name: 'installation_address') this.installationAddress, @JsonKey(name: 'is_temp_deactivated') this.isTempDeactivated = 0, @JsonKey(name: 'stb_type') this.stbType, @JsonKey(name: 'stb_model') this.stbModel, @JsonKey(name: 'stock_location') this.stockLocation, @JsonKey(name: 'customer_name') this.customerName, @JsonKey(name: 'mobile_no') this.mobileNo});
  factory _StbModel.fromJson(Map<String, dynamic> json) => _$StbModelFromJson(json);

@override@JsonKey(name: 'serial_number') final  String stbNo;
@override@JsonKey(name: 'vc_number') final  String vcNo;
@override@JsonKey(name: 'customer_id') final  String? customerId;
@override@JsonKey(name: 'status') final  String status;
@override@JsonKey(name: 'cas_display_name') final  String casType;
@override@JsonKey(name: 'box_number') final  String? boxNumber;
@override@JsonKey(name: 'mac_address') final  String? macAddress;
@override@JsonKey(name: 'stock_id') final  String? stockId;
@override@JsonKey(name: 'device_id') final  String? deviceId;
@override@JsonKey(name: 'backend_setup_id') final  String? backendSetupId;
@override@JsonKey(name: 'stock_status') final  String? stockStatus;
@override@JsonKey(name: 'activation_date') final  String? activatedDate;
@override@JsonKey(name: 'assigned_date') final  String? assignedDate;
@override@JsonKey(name: 'is_assigned') final  int isAssigned;
@override@JsonKey(name: 'installation_address') final  String? installationAddress;
@override@JsonKey(name: 'is_temp_deactivated') final  int isTempDeactivated;
// New fields from server
@override@JsonKey(name: 'stb_type') final  String? stbType;
@override@JsonKey(name: 'stb_model') final  String? stbModel;
@override@JsonKey(name: 'stock_location') final  String? stockLocation;
@override@JsonKey(name: 'customer_name') final  String? customerName;
@override@JsonKey(name: 'mobile_no') final  String? mobileNo;

/// Create a copy of StbModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StbModelCopyWith<_StbModel> get copyWith => __$StbModelCopyWithImpl<_StbModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StbModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StbModel&&(identical(other.stbNo, stbNo) || other.stbNo == stbNo)&&(identical(other.vcNo, vcNo) || other.vcNo == vcNo)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.status, status) || other.status == status)&&(identical(other.casType, casType) || other.casType == casType)&&(identical(other.boxNumber, boxNumber) || other.boxNumber == boxNumber)&&(identical(other.macAddress, macAddress) || other.macAddress == macAddress)&&(identical(other.stockId, stockId) || other.stockId == stockId)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.backendSetupId, backendSetupId) || other.backendSetupId == backendSetupId)&&(identical(other.stockStatus, stockStatus) || other.stockStatus == stockStatus)&&(identical(other.activatedDate, activatedDate) || other.activatedDate == activatedDate)&&(identical(other.assignedDate, assignedDate) || other.assignedDate == assignedDate)&&(identical(other.isAssigned, isAssigned) || other.isAssigned == isAssigned)&&(identical(other.installationAddress, installationAddress) || other.installationAddress == installationAddress)&&(identical(other.isTempDeactivated, isTempDeactivated) || other.isTempDeactivated == isTempDeactivated)&&(identical(other.stbType, stbType) || other.stbType == stbType)&&(identical(other.stbModel, stbModel) || other.stbModel == stbModel)&&(identical(other.stockLocation, stockLocation) || other.stockLocation == stockLocation)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.mobileNo, mobileNo) || other.mobileNo == mobileNo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,stbNo,vcNo,customerId,status,casType,boxNumber,macAddress,stockId,deviceId,backendSetupId,stockStatus,activatedDate,assignedDate,isAssigned,installationAddress,isTempDeactivated,stbType,stbModel,stockLocation,customerName,mobileNo]);

@override
String toString() {
  return 'StbModel(stbNo: $stbNo, vcNo: $vcNo, customerId: $customerId, status: $status, casType: $casType, boxNumber: $boxNumber, macAddress: $macAddress, stockId: $stockId, deviceId: $deviceId, backendSetupId: $backendSetupId, stockStatus: $stockStatus, activatedDate: $activatedDate, assignedDate: $assignedDate, isAssigned: $isAssigned, installationAddress: $installationAddress, isTempDeactivated: $isTempDeactivated, stbType: $stbType, stbModel: $stbModel, stockLocation: $stockLocation, customerName: $customerName, mobileNo: $mobileNo)';
}


}

/// @nodoc
abstract mixin class _$StbModelCopyWith<$Res> implements $StbModelCopyWith<$Res> {
  factory _$StbModelCopyWith(_StbModel value, $Res Function(_StbModel) _then) = __$StbModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'serial_number') String stbNo,@JsonKey(name: 'vc_number') String vcNo,@JsonKey(name: 'customer_id') String? customerId,@JsonKey(name: 'status') String status,@JsonKey(name: 'cas_display_name') String casType,@JsonKey(name: 'box_number') String? boxNumber,@JsonKey(name: 'mac_address') String? macAddress,@JsonKey(name: 'stock_id') String? stockId,@JsonKey(name: 'device_id') String? deviceId,@JsonKey(name: 'backend_setup_id') String? backendSetupId,@JsonKey(name: 'stock_status') String? stockStatus,@JsonKey(name: 'activation_date') String? activatedDate,@JsonKey(name: 'assigned_date') String? assignedDate,@JsonKey(name: 'is_assigned') int isAssigned,@JsonKey(name: 'installation_address') String? installationAddress,@JsonKey(name: 'is_temp_deactivated') int isTempDeactivated,@JsonKey(name: 'stb_type') String? stbType,@JsonKey(name: 'stb_model') String? stbModel,@JsonKey(name: 'stock_location') String? stockLocation,@JsonKey(name: 'customer_name') String? customerName,@JsonKey(name: 'mobile_no') String? mobileNo
});




}
/// @nodoc
class __$StbModelCopyWithImpl<$Res>
    implements _$StbModelCopyWith<$Res> {
  __$StbModelCopyWithImpl(this._self, this._then);

  final _StbModel _self;
  final $Res Function(_StbModel) _then;

/// Create a copy of StbModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stbNo = null,Object? vcNo = null,Object? customerId = freezed,Object? status = null,Object? casType = null,Object? boxNumber = freezed,Object? macAddress = freezed,Object? stockId = freezed,Object? deviceId = freezed,Object? backendSetupId = freezed,Object? stockStatus = freezed,Object? activatedDate = freezed,Object? assignedDate = freezed,Object? isAssigned = null,Object? installationAddress = freezed,Object? isTempDeactivated = null,Object? stbType = freezed,Object? stbModel = freezed,Object? stockLocation = freezed,Object? customerName = freezed,Object? mobileNo = freezed,}) {
  return _then(_StbModel(
stbNo: null == stbNo ? _self.stbNo : stbNo // ignore: cast_nullable_to_non_nullable
as String,vcNo: null == vcNo ? _self.vcNo : vcNo // ignore: cast_nullable_to_non_nullable
as String,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,casType: null == casType ? _self.casType : casType // ignore: cast_nullable_to_non_nullable
as String,boxNumber: freezed == boxNumber ? _self.boxNumber : boxNumber // ignore: cast_nullable_to_non_nullable
as String?,macAddress: freezed == macAddress ? _self.macAddress : macAddress // ignore: cast_nullable_to_non_nullable
as String?,stockId: freezed == stockId ? _self.stockId : stockId // ignore: cast_nullable_to_non_nullable
as String?,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,backendSetupId: freezed == backendSetupId ? _self.backendSetupId : backendSetupId // ignore: cast_nullable_to_non_nullable
as String?,stockStatus: freezed == stockStatus ? _self.stockStatus : stockStatus // ignore: cast_nullable_to_non_nullable
as String?,activatedDate: freezed == activatedDate ? _self.activatedDate : activatedDate // ignore: cast_nullable_to_non_nullable
as String?,assignedDate: freezed == assignedDate ? _self.assignedDate : assignedDate // ignore: cast_nullable_to_non_nullable
as String?,isAssigned: null == isAssigned ? _self.isAssigned : isAssigned // ignore: cast_nullable_to_non_nullable
as int,installationAddress: freezed == installationAddress ? _self.installationAddress : installationAddress // ignore: cast_nullable_to_non_nullable
as String?,isTempDeactivated: null == isTempDeactivated ? _self.isTempDeactivated : isTempDeactivated // ignore: cast_nullable_to_non_nullable
as int,stbType: freezed == stbType ? _self.stbType : stbType // ignore: cast_nullable_to_non_nullable
as String?,stbModel: freezed == stbModel ? _self.stbModel : stbModel // ignore: cast_nullable_to_non_nullable
as String?,stockLocation: freezed == stockLocation ? _self.stockLocation : stockLocation // ignore: cast_nullable_to_non_nullable
as String?,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,mobileNo: freezed == mobileNo ? _self.mobileNo : mobileNo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
