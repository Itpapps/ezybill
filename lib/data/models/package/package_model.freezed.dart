// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'package_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PackageModel {

@JsonKey(name: 'product_id') String get packageId;@JsonKey(name: 'pname') String get packageName;@JsonKey(name: 'base_price') double get price;@JsonKey(name: 'is_base_package') int get isBasePackage;@JsonKey(name: 'is_broadcaster_package') int get isBroadcasterPackage;@JsonKey(name: 'alacarte') int get alacarte;@JsonKey(name: 'monthly_or_yearly') String get validity;@JsonKey(name: 'validity_days') int get validityDays;@JsonKey(name: 'sd_channels_count') int get sdChannels;@JsonKey(name: 'hd_channels_count') int get hdChannels;@JsonKey(name: 'pricing_structure_type') String get pricingStructureType;@JsonKey(name: 'end_date') String? get endDate;@JsonKey(name: 'broadcaster_id') int get broadcasterId;@JsonKey(name: 'is_taxble') int get isTaxable;@JsonKey(name: 'tax1') double get tax1;@JsonKey(name: 'tax2') double get tax2;@JsonKey(name: 'tax3') double get tax3;@JsonKey(name: 'tax4') double get tax4;@JsonKey(name: 'tax5') double get tax5;@JsonKey(name: 'tax6') double get tax6;// For assigned packages (getCustomerPackages_splitRest)
@JsonKey(name: 'service_id') String? get serviceId;@JsonKey(name: 'customer_service_id') String? get customerServiceId;@JsonKey(name: 'start_date') String? get startDate;// New fields from server
@JsonKey(name: 'customer_name') String? get customerName;@JsonKey(name: 'cas_server_type') String? get casServerType;@JsonKey(name: 'service_validity_days_v2') String? get serviceValidityDaysV2;@JsonKey(name: 'service_type') String? get serviceType;@JsonKey(name: 'extend_service_enddate') String? get extendServiceEnddate;
/// Create a copy of PackageModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackageModelCopyWith<PackageModel> get copyWith => _$PackageModelCopyWithImpl<PackageModel>(this as PackageModel, _$identity);

  /// Serializes this PackageModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackageModel&&(identical(other.packageId, packageId) || other.packageId == packageId)&&(identical(other.packageName, packageName) || other.packageName == packageName)&&(identical(other.price, price) || other.price == price)&&(identical(other.isBasePackage, isBasePackage) || other.isBasePackage == isBasePackage)&&(identical(other.isBroadcasterPackage, isBroadcasterPackage) || other.isBroadcasterPackage == isBroadcasterPackage)&&(identical(other.alacarte, alacarte) || other.alacarte == alacarte)&&(identical(other.validity, validity) || other.validity == validity)&&(identical(other.validityDays, validityDays) || other.validityDays == validityDays)&&(identical(other.sdChannels, sdChannels) || other.sdChannels == sdChannels)&&(identical(other.hdChannels, hdChannels) || other.hdChannels == hdChannels)&&(identical(other.pricingStructureType, pricingStructureType) || other.pricingStructureType == pricingStructureType)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.broadcasterId, broadcasterId) || other.broadcasterId == broadcasterId)&&(identical(other.isTaxable, isTaxable) || other.isTaxable == isTaxable)&&(identical(other.tax1, tax1) || other.tax1 == tax1)&&(identical(other.tax2, tax2) || other.tax2 == tax2)&&(identical(other.tax3, tax3) || other.tax3 == tax3)&&(identical(other.tax4, tax4) || other.tax4 == tax4)&&(identical(other.tax5, tax5) || other.tax5 == tax5)&&(identical(other.tax6, tax6) || other.tax6 == tax6)&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.customerServiceId, customerServiceId) || other.customerServiceId == customerServiceId)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.casServerType, casServerType) || other.casServerType == casServerType)&&(identical(other.serviceValidityDaysV2, serviceValidityDaysV2) || other.serviceValidityDaysV2 == serviceValidityDaysV2)&&(identical(other.serviceType, serviceType) || other.serviceType == serviceType)&&(identical(other.extendServiceEnddate, extendServiceEnddate) || other.extendServiceEnddate == extendServiceEnddate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,packageId,packageName,price,isBasePackage,isBroadcasterPackage,alacarte,validity,validityDays,sdChannels,hdChannels,pricingStructureType,endDate,broadcasterId,isTaxable,tax1,tax2,tax3,tax4,tax5,tax6,serviceId,customerServiceId,startDate,customerName,casServerType,serviceValidityDaysV2,serviceType,extendServiceEnddate]);

@override
String toString() {
  return 'PackageModel(packageId: $packageId, packageName: $packageName, price: $price, isBasePackage: $isBasePackage, isBroadcasterPackage: $isBroadcasterPackage, alacarte: $alacarte, validity: $validity, validityDays: $validityDays, sdChannels: $sdChannels, hdChannels: $hdChannels, pricingStructureType: $pricingStructureType, endDate: $endDate, broadcasterId: $broadcasterId, isTaxable: $isTaxable, tax1: $tax1, tax2: $tax2, tax3: $tax3, tax4: $tax4, tax5: $tax5, tax6: $tax6, serviceId: $serviceId, customerServiceId: $customerServiceId, startDate: $startDate, customerName: $customerName, casServerType: $casServerType, serviceValidityDaysV2: $serviceValidityDaysV2, serviceType: $serviceType, extendServiceEnddate: $extendServiceEnddate)';
}


}

/// @nodoc
abstract mixin class $PackageModelCopyWith<$Res>  {
  factory $PackageModelCopyWith(PackageModel value, $Res Function(PackageModel) _then) = _$PackageModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'product_id') String packageId,@JsonKey(name: 'pname') String packageName,@JsonKey(name: 'base_price') double price,@JsonKey(name: 'is_base_package') int isBasePackage,@JsonKey(name: 'is_broadcaster_package') int isBroadcasterPackage,@JsonKey(name: 'alacarte') int alacarte,@JsonKey(name: 'monthly_or_yearly') String validity,@JsonKey(name: 'validity_days') int validityDays,@JsonKey(name: 'sd_channels_count') int sdChannels,@JsonKey(name: 'hd_channels_count') int hdChannels,@JsonKey(name: 'pricing_structure_type') String pricingStructureType,@JsonKey(name: 'end_date') String? endDate,@JsonKey(name: 'broadcaster_id') int broadcasterId,@JsonKey(name: 'is_taxble') int isTaxable,@JsonKey(name: 'tax1') double tax1,@JsonKey(name: 'tax2') double tax2,@JsonKey(name: 'tax3') double tax3,@JsonKey(name: 'tax4') double tax4,@JsonKey(name: 'tax5') double tax5,@JsonKey(name: 'tax6') double tax6,@JsonKey(name: 'service_id') String? serviceId,@JsonKey(name: 'customer_service_id') String? customerServiceId,@JsonKey(name: 'start_date') String? startDate,@JsonKey(name: 'customer_name') String? customerName,@JsonKey(name: 'cas_server_type') String? casServerType,@JsonKey(name: 'service_validity_days_v2') String? serviceValidityDaysV2,@JsonKey(name: 'service_type') String? serviceType,@JsonKey(name: 'extend_service_enddate') String? extendServiceEnddate
});




}
/// @nodoc
class _$PackageModelCopyWithImpl<$Res>
    implements $PackageModelCopyWith<$Res> {
  _$PackageModelCopyWithImpl(this._self, this._then);

  final PackageModel _self;
  final $Res Function(PackageModel) _then;

/// Create a copy of PackageModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? packageId = null,Object? packageName = null,Object? price = null,Object? isBasePackage = null,Object? isBroadcasterPackage = null,Object? alacarte = null,Object? validity = null,Object? validityDays = null,Object? sdChannels = null,Object? hdChannels = null,Object? pricingStructureType = null,Object? endDate = freezed,Object? broadcasterId = null,Object? isTaxable = null,Object? tax1 = null,Object? tax2 = null,Object? tax3 = null,Object? tax4 = null,Object? tax5 = null,Object? tax6 = null,Object? serviceId = freezed,Object? customerServiceId = freezed,Object? startDate = freezed,Object? customerName = freezed,Object? casServerType = freezed,Object? serviceValidityDaysV2 = freezed,Object? serviceType = freezed,Object? extendServiceEnddate = freezed,}) {
  return _then(_self.copyWith(
packageId: null == packageId ? _self.packageId : packageId // ignore: cast_nullable_to_non_nullable
as String,packageName: null == packageName ? _self.packageName : packageName // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,isBasePackage: null == isBasePackage ? _self.isBasePackage : isBasePackage // ignore: cast_nullable_to_non_nullable
as int,isBroadcasterPackage: null == isBroadcasterPackage ? _self.isBroadcasterPackage : isBroadcasterPackage // ignore: cast_nullable_to_non_nullable
as int,alacarte: null == alacarte ? _self.alacarte : alacarte // ignore: cast_nullable_to_non_nullable
as int,validity: null == validity ? _self.validity : validity // ignore: cast_nullable_to_non_nullable
as String,validityDays: null == validityDays ? _self.validityDays : validityDays // ignore: cast_nullable_to_non_nullable
as int,sdChannels: null == sdChannels ? _self.sdChannels : sdChannels // ignore: cast_nullable_to_non_nullable
as int,hdChannels: null == hdChannels ? _self.hdChannels : hdChannels // ignore: cast_nullable_to_non_nullable
as int,pricingStructureType: null == pricingStructureType ? _self.pricingStructureType : pricingStructureType // ignore: cast_nullable_to_non_nullable
as String,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,broadcasterId: null == broadcasterId ? _self.broadcasterId : broadcasterId // ignore: cast_nullable_to_non_nullable
as int,isTaxable: null == isTaxable ? _self.isTaxable : isTaxable // ignore: cast_nullable_to_non_nullable
as int,tax1: null == tax1 ? _self.tax1 : tax1 // ignore: cast_nullable_to_non_nullable
as double,tax2: null == tax2 ? _self.tax2 : tax2 // ignore: cast_nullable_to_non_nullable
as double,tax3: null == tax3 ? _self.tax3 : tax3 // ignore: cast_nullable_to_non_nullable
as double,tax4: null == tax4 ? _self.tax4 : tax4 // ignore: cast_nullable_to_non_nullable
as double,tax5: null == tax5 ? _self.tax5 : tax5 // ignore: cast_nullable_to_non_nullable
as double,tax6: null == tax6 ? _self.tax6 : tax6 // ignore: cast_nullable_to_non_nullable
as double,serviceId: freezed == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String?,customerServiceId: freezed == customerServiceId ? _self.customerServiceId : customerServiceId // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,casServerType: freezed == casServerType ? _self.casServerType : casServerType // ignore: cast_nullable_to_non_nullable
as String?,serviceValidityDaysV2: freezed == serviceValidityDaysV2 ? _self.serviceValidityDaysV2 : serviceValidityDaysV2 // ignore: cast_nullable_to_non_nullable
as String?,serviceType: freezed == serviceType ? _self.serviceType : serviceType // ignore: cast_nullable_to_non_nullable
as String?,extendServiceEnddate: freezed == extendServiceEnddate ? _self.extendServiceEnddate : extendServiceEnddate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PackageModel].
extension PackageModelPatterns on PackageModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PackageModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PackageModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PackageModel value)  $default,){
final _that = this;
switch (_that) {
case _PackageModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PackageModel value)?  $default,){
final _that = this;
switch (_that) {
case _PackageModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'product_id')  String packageId, @JsonKey(name: 'pname')  String packageName, @JsonKey(name: 'base_price')  double price, @JsonKey(name: 'is_base_package')  int isBasePackage, @JsonKey(name: 'is_broadcaster_package')  int isBroadcasterPackage, @JsonKey(name: 'alacarte')  int alacarte, @JsonKey(name: 'monthly_or_yearly')  String validity, @JsonKey(name: 'validity_days')  int validityDays, @JsonKey(name: 'sd_channels_count')  int sdChannels, @JsonKey(name: 'hd_channels_count')  int hdChannels, @JsonKey(name: 'pricing_structure_type')  String pricingStructureType, @JsonKey(name: 'end_date')  String? endDate, @JsonKey(name: 'broadcaster_id')  int broadcasterId, @JsonKey(name: 'is_taxble')  int isTaxable, @JsonKey(name: 'tax1')  double tax1, @JsonKey(name: 'tax2')  double tax2, @JsonKey(name: 'tax3')  double tax3, @JsonKey(name: 'tax4')  double tax4, @JsonKey(name: 'tax5')  double tax5, @JsonKey(name: 'tax6')  double tax6, @JsonKey(name: 'service_id')  String? serviceId, @JsonKey(name: 'customer_service_id')  String? customerServiceId, @JsonKey(name: 'start_date')  String? startDate, @JsonKey(name: 'customer_name')  String? customerName, @JsonKey(name: 'cas_server_type')  String? casServerType, @JsonKey(name: 'service_validity_days_v2')  String? serviceValidityDaysV2, @JsonKey(name: 'service_type')  String? serviceType, @JsonKey(name: 'extend_service_enddate')  String? extendServiceEnddate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackageModel() when $default != null:
return $default(_that.packageId,_that.packageName,_that.price,_that.isBasePackage,_that.isBroadcasterPackage,_that.alacarte,_that.validity,_that.validityDays,_that.sdChannels,_that.hdChannels,_that.pricingStructureType,_that.endDate,_that.broadcasterId,_that.isTaxable,_that.tax1,_that.tax2,_that.tax3,_that.tax4,_that.tax5,_that.tax6,_that.serviceId,_that.customerServiceId,_that.startDate,_that.customerName,_that.casServerType,_that.serviceValidityDaysV2,_that.serviceType,_that.extendServiceEnddate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'product_id')  String packageId, @JsonKey(name: 'pname')  String packageName, @JsonKey(name: 'base_price')  double price, @JsonKey(name: 'is_base_package')  int isBasePackage, @JsonKey(name: 'is_broadcaster_package')  int isBroadcasterPackage, @JsonKey(name: 'alacarte')  int alacarte, @JsonKey(name: 'monthly_or_yearly')  String validity, @JsonKey(name: 'validity_days')  int validityDays, @JsonKey(name: 'sd_channels_count')  int sdChannels, @JsonKey(name: 'hd_channels_count')  int hdChannels, @JsonKey(name: 'pricing_structure_type')  String pricingStructureType, @JsonKey(name: 'end_date')  String? endDate, @JsonKey(name: 'broadcaster_id')  int broadcasterId, @JsonKey(name: 'is_taxble')  int isTaxable, @JsonKey(name: 'tax1')  double tax1, @JsonKey(name: 'tax2')  double tax2, @JsonKey(name: 'tax3')  double tax3, @JsonKey(name: 'tax4')  double tax4, @JsonKey(name: 'tax5')  double tax5, @JsonKey(name: 'tax6')  double tax6, @JsonKey(name: 'service_id')  String? serviceId, @JsonKey(name: 'customer_service_id')  String? customerServiceId, @JsonKey(name: 'start_date')  String? startDate, @JsonKey(name: 'customer_name')  String? customerName, @JsonKey(name: 'cas_server_type')  String? casServerType, @JsonKey(name: 'service_validity_days_v2')  String? serviceValidityDaysV2, @JsonKey(name: 'service_type')  String? serviceType, @JsonKey(name: 'extend_service_enddate')  String? extendServiceEnddate)  $default,) {final _that = this;
switch (_that) {
case _PackageModel():
return $default(_that.packageId,_that.packageName,_that.price,_that.isBasePackage,_that.isBroadcasterPackage,_that.alacarte,_that.validity,_that.validityDays,_that.sdChannels,_that.hdChannels,_that.pricingStructureType,_that.endDate,_that.broadcasterId,_that.isTaxable,_that.tax1,_that.tax2,_that.tax3,_that.tax4,_that.tax5,_that.tax6,_that.serviceId,_that.customerServiceId,_that.startDate,_that.customerName,_that.casServerType,_that.serviceValidityDaysV2,_that.serviceType,_that.extendServiceEnddate);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'product_id')  String packageId, @JsonKey(name: 'pname')  String packageName, @JsonKey(name: 'base_price')  double price, @JsonKey(name: 'is_base_package')  int isBasePackage, @JsonKey(name: 'is_broadcaster_package')  int isBroadcasterPackage, @JsonKey(name: 'alacarte')  int alacarte, @JsonKey(name: 'monthly_or_yearly')  String validity, @JsonKey(name: 'validity_days')  int validityDays, @JsonKey(name: 'sd_channels_count')  int sdChannels, @JsonKey(name: 'hd_channels_count')  int hdChannels, @JsonKey(name: 'pricing_structure_type')  String pricingStructureType, @JsonKey(name: 'end_date')  String? endDate, @JsonKey(name: 'broadcaster_id')  int broadcasterId, @JsonKey(name: 'is_taxble')  int isTaxable, @JsonKey(name: 'tax1')  double tax1, @JsonKey(name: 'tax2')  double tax2, @JsonKey(name: 'tax3')  double tax3, @JsonKey(name: 'tax4')  double tax4, @JsonKey(name: 'tax5')  double tax5, @JsonKey(name: 'tax6')  double tax6, @JsonKey(name: 'service_id')  String? serviceId, @JsonKey(name: 'customer_service_id')  String? customerServiceId, @JsonKey(name: 'start_date')  String? startDate, @JsonKey(name: 'customer_name')  String? customerName, @JsonKey(name: 'cas_server_type')  String? casServerType, @JsonKey(name: 'service_validity_days_v2')  String? serviceValidityDaysV2, @JsonKey(name: 'service_type')  String? serviceType, @JsonKey(name: 'extend_service_enddate')  String? extendServiceEnddate)?  $default,) {final _that = this;
switch (_that) {
case _PackageModel() when $default != null:
return $default(_that.packageId,_that.packageName,_that.price,_that.isBasePackage,_that.isBroadcasterPackage,_that.alacarte,_that.validity,_that.validityDays,_that.sdChannels,_that.hdChannels,_that.pricingStructureType,_that.endDate,_that.broadcasterId,_that.isTaxable,_that.tax1,_that.tax2,_that.tax3,_that.tax4,_that.tax5,_that.tax6,_that.serviceId,_that.customerServiceId,_that.startDate,_that.customerName,_that.casServerType,_that.serviceValidityDaysV2,_that.serviceType,_that.extendServiceEnddate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PackageModel implements PackageModel {
  const _PackageModel({@JsonKey(name: 'product_id') this.packageId = '', @JsonKey(name: 'pname') this.packageName = '', @JsonKey(name: 'base_price') this.price = 0.0, @JsonKey(name: 'is_base_package') this.isBasePackage = 0, @JsonKey(name: 'is_broadcaster_package') this.isBroadcasterPackage = 0, @JsonKey(name: 'alacarte') this.alacarte = 0, @JsonKey(name: 'monthly_or_yearly') this.validity = '', @JsonKey(name: 'validity_days') this.validityDays = 0, @JsonKey(name: 'sd_channels_count') this.sdChannels = 0, @JsonKey(name: 'hd_channels_count') this.hdChannels = 0, @JsonKey(name: 'pricing_structure_type') this.pricingStructureType = '', @JsonKey(name: 'end_date') this.endDate, @JsonKey(name: 'broadcaster_id') this.broadcasterId = 0, @JsonKey(name: 'is_taxble') this.isTaxable = 0, @JsonKey(name: 'tax1') this.tax1 = 0.0, @JsonKey(name: 'tax2') this.tax2 = 0.0, @JsonKey(name: 'tax3') this.tax3 = 0.0, @JsonKey(name: 'tax4') this.tax4 = 0.0, @JsonKey(name: 'tax5') this.tax5 = 0.0, @JsonKey(name: 'tax6') this.tax6 = 0.0, @JsonKey(name: 'service_id') this.serviceId, @JsonKey(name: 'customer_service_id') this.customerServiceId, @JsonKey(name: 'start_date') this.startDate, @JsonKey(name: 'customer_name') this.customerName, @JsonKey(name: 'cas_server_type') this.casServerType, @JsonKey(name: 'service_validity_days_v2') this.serviceValidityDaysV2, @JsonKey(name: 'service_type') this.serviceType, @JsonKey(name: 'extend_service_enddate') this.extendServiceEnddate});
  factory _PackageModel.fromJson(Map<String, dynamic> json) => _$PackageModelFromJson(json);

@override@JsonKey(name: 'product_id') final  String packageId;
@override@JsonKey(name: 'pname') final  String packageName;
@override@JsonKey(name: 'base_price') final  double price;
@override@JsonKey(name: 'is_base_package') final  int isBasePackage;
@override@JsonKey(name: 'is_broadcaster_package') final  int isBroadcasterPackage;
@override@JsonKey(name: 'alacarte') final  int alacarte;
@override@JsonKey(name: 'monthly_or_yearly') final  String validity;
@override@JsonKey(name: 'validity_days') final  int validityDays;
@override@JsonKey(name: 'sd_channels_count') final  int sdChannels;
@override@JsonKey(name: 'hd_channels_count') final  int hdChannels;
@override@JsonKey(name: 'pricing_structure_type') final  String pricingStructureType;
@override@JsonKey(name: 'end_date') final  String? endDate;
@override@JsonKey(name: 'broadcaster_id') final  int broadcasterId;
@override@JsonKey(name: 'is_taxble') final  int isTaxable;
@override@JsonKey(name: 'tax1') final  double tax1;
@override@JsonKey(name: 'tax2') final  double tax2;
@override@JsonKey(name: 'tax3') final  double tax3;
@override@JsonKey(name: 'tax4') final  double tax4;
@override@JsonKey(name: 'tax5') final  double tax5;
@override@JsonKey(name: 'tax6') final  double tax6;
// For assigned packages (getCustomerPackages_splitRest)
@override@JsonKey(name: 'service_id') final  String? serviceId;
@override@JsonKey(name: 'customer_service_id') final  String? customerServiceId;
@override@JsonKey(name: 'start_date') final  String? startDate;
// New fields from server
@override@JsonKey(name: 'customer_name') final  String? customerName;
@override@JsonKey(name: 'cas_server_type') final  String? casServerType;
@override@JsonKey(name: 'service_validity_days_v2') final  String? serviceValidityDaysV2;
@override@JsonKey(name: 'service_type') final  String? serviceType;
@override@JsonKey(name: 'extend_service_enddate') final  String? extendServiceEnddate;

/// Create a copy of PackageModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackageModelCopyWith<_PackageModel> get copyWith => __$PackageModelCopyWithImpl<_PackageModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PackageModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackageModel&&(identical(other.packageId, packageId) || other.packageId == packageId)&&(identical(other.packageName, packageName) || other.packageName == packageName)&&(identical(other.price, price) || other.price == price)&&(identical(other.isBasePackage, isBasePackage) || other.isBasePackage == isBasePackage)&&(identical(other.isBroadcasterPackage, isBroadcasterPackage) || other.isBroadcasterPackage == isBroadcasterPackage)&&(identical(other.alacarte, alacarte) || other.alacarte == alacarte)&&(identical(other.validity, validity) || other.validity == validity)&&(identical(other.validityDays, validityDays) || other.validityDays == validityDays)&&(identical(other.sdChannels, sdChannels) || other.sdChannels == sdChannels)&&(identical(other.hdChannels, hdChannels) || other.hdChannels == hdChannels)&&(identical(other.pricingStructureType, pricingStructureType) || other.pricingStructureType == pricingStructureType)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.broadcasterId, broadcasterId) || other.broadcasterId == broadcasterId)&&(identical(other.isTaxable, isTaxable) || other.isTaxable == isTaxable)&&(identical(other.tax1, tax1) || other.tax1 == tax1)&&(identical(other.tax2, tax2) || other.tax2 == tax2)&&(identical(other.tax3, tax3) || other.tax3 == tax3)&&(identical(other.tax4, tax4) || other.tax4 == tax4)&&(identical(other.tax5, tax5) || other.tax5 == tax5)&&(identical(other.tax6, tax6) || other.tax6 == tax6)&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.customerServiceId, customerServiceId) || other.customerServiceId == customerServiceId)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.casServerType, casServerType) || other.casServerType == casServerType)&&(identical(other.serviceValidityDaysV2, serviceValidityDaysV2) || other.serviceValidityDaysV2 == serviceValidityDaysV2)&&(identical(other.serviceType, serviceType) || other.serviceType == serviceType)&&(identical(other.extendServiceEnddate, extendServiceEnddate) || other.extendServiceEnddate == extendServiceEnddate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,packageId,packageName,price,isBasePackage,isBroadcasterPackage,alacarte,validity,validityDays,sdChannels,hdChannels,pricingStructureType,endDate,broadcasterId,isTaxable,tax1,tax2,tax3,tax4,tax5,tax6,serviceId,customerServiceId,startDate,customerName,casServerType,serviceValidityDaysV2,serviceType,extendServiceEnddate]);

@override
String toString() {
  return 'PackageModel(packageId: $packageId, packageName: $packageName, price: $price, isBasePackage: $isBasePackage, isBroadcasterPackage: $isBroadcasterPackage, alacarte: $alacarte, validity: $validity, validityDays: $validityDays, sdChannels: $sdChannels, hdChannels: $hdChannels, pricingStructureType: $pricingStructureType, endDate: $endDate, broadcasterId: $broadcasterId, isTaxable: $isTaxable, tax1: $tax1, tax2: $tax2, tax3: $tax3, tax4: $tax4, tax5: $tax5, tax6: $tax6, serviceId: $serviceId, customerServiceId: $customerServiceId, startDate: $startDate, customerName: $customerName, casServerType: $casServerType, serviceValidityDaysV2: $serviceValidityDaysV2, serviceType: $serviceType, extendServiceEnddate: $extendServiceEnddate)';
}


}

/// @nodoc
abstract mixin class _$PackageModelCopyWith<$Res> implements $PackageModelCopyWith<$Res> {
  factory _$PackageModelCopyWith(_PackageModel value, $Res Function(_PackageModel) _then) = __$PackageModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'product_id') String packageId,@JsonKey(name: 'pname') String packageName,@JsonKey(name: 'base_price') double price,@JsonKey(name: 'is_base_package') int isBasePackage,@JsonKey(name: 'is_broadcaster_package') int isBroadcasterPackage,@JsonKey(name: 'alacarte') int alacarte,@JsonKey(name: 'monthly_or_yearly') String validity,@JsonKey(name: 'validity_days') int validityDays,@JsonKey(name: 'sd_channels_count') int sdChannels,@JsonKey(name: 'hd_channels_count') int hdChannels,@JsonKey(name: 'pricing_structure_type') String pricingStructureType,@JsonKey(name: 'end_date') String? endDate,@JsonKey(name: 'broadcaster_id') int broadcasterId,@JsonKey(name: 'is_taxble') int isTaxable,@JsonKey(name: 'tax1') double tax1,@JsonKey(name: 'tax2') double tax2,@JsonKey(name: 'tax3') double tax3,@JsonKey(name: 'tax4') double tax4,@JsonKey(name: 'tax5') double tax5,@JsonKey(name: 'tax6') double tax6,@JsonKey(name: 'service_id') String? serviceId,@JsonKey(name: 'customer_service_id') String? customerServiceId,@JsonKey(name: 'start_date') String? startDate,@JsonKey(name: 'customer_name') String? customerName,@JsonKey(name: 'cas_server_type') String? casServerType,@JsonKey(name: 'service_validity_days_v2') String? serviceValidityDaysV2,@JsonKey(name: 'service_type') String? serviceType,@JsonKey(name: 'extend_service_enddate') String? extendServiceEnddate
});




}
/// @nodoc
class __$PackageModelCopyWithImpl<$Res>
    implements _$PackageModelCopyWith<$Res> {
  __$PackageModelCopyWithImpl(this._self, this._then);

  final _PackageModel _self;
  final $Res Function(_PackageModel) _then;

/// Create a copy of PackageModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? packageId = null,Object? packageName = null,Object? price = null,Object? isBasePackage = null,Object? isBroadcasterPackage = null,Object? alacarte = null,Object? validity = null,Object? validityDays = null,Object? sdChannels = null,Object? hdChannels = null,Object? pricingStructureType = null,Object? endDate = freezed,Object? broadcasterId = null,Object? isTaxable = null,Object? tax1 = null,Object? tax2 = null,Object? tax3 = null,Object? tax4 = null,Object? tax5 = null,Object? tax6 = null,Object? serviceId = freezed,Object? customerServiceId = freezed,Object? startDate = freezed,Object? customerName = freezed,Object? casServerType = freezed,Object? serviceValidityDaysV2 = freezed,Object? serviceType = freezed,Object? extendServiceEnddate = freezed,}) {
  return _then(_PackageModel(
packageId: null == packageId ? _self.packageId : packageId // ignore: cast_nullable_to_non_nullable
as String,packageName: null == packageName ? _self.packageName : packageName // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,isBasePackage: null == isBasePackage ? _self.isBasePackage : isBasePackage // ignore: cast_nullable_to_non_nullable
as int,isBroadcasterPackage: null == isBroadcasterPackage ? _self.isBroadcasterPackage : isBroadcasterPackage // ignore: cast_nullable_to_non_nullable
as int,alacarte: null == alacarte ? _self.alacarte : alacarte // ignore: cast_nullable_to_non_nullable
as int,validity: null == validity ? _self.validity : validity // ignore: cast_nullable_to_non_nullable
as String,validityDays: null == validityDays ? _self.validityDays : validityDays // ignore: cast_nullable_to_non_nullable
as int,sdChannels: null == sdChannels ? _self.sdChannels : sdChannels // ignore: cast_nullable_to_non_nullable
as int,hdChannels: null == hdChannels ? _self.hdChannels : hdChannels // ignore: cast_nullable_to_non_nullable
as int,pricingStructureType: null == pricingStructureType ? _self.pricingStructureType : pricingStructureType // ignore: cast_nullable_to_non_nullable
as String,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,broadcasterId: null == broadcasterId ? _self.broadcasterId : broadcasterId // ignore: cast_nullable_to_non_nullable
as int,isTaxable: null == isTaxable ? _self.isTaxable : isTaxable // ignore: cast_nullable_to_non_nullable
as int,tax1: null == tax1 ? _self.tax1 : tax1 // ignore: cast_nullable_to_non_nullable
as double,tax2: null == tax2 ? _self.tax2 : tax2 // ignore: cast_nullable_to_non_nullable
as double,tax3: null == tax3 ? _self.tax3 : tax3 // ignore: cast_nullable_to_non_nullable
as double,tax4: null == tax4 ? _self.tax4 : tax4 // ignore: cast_nullable_to_non_nullable
as double,tax5: null == tax5 ? _self.tax5 : tax5 // ignore: cast_nullable_to_non_nullable
as double,tax6: null == tax6 ? _self.tax6 : tax6 // ignore: cast_nullable_to_non_nullable
as double,serviceId: freezed == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String?,customerServiceId: freezed == customerServiceId ? _self.customerServiceId : customerServiceId // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,casServerType: freezed == casServerType ? _self.casServerType : casServerType // ignore: cast_nullable_to_non_nullable
as String?,serviceValidityDaysV2: freezed == serviceValidityDaysV2 ? _self.serviceValidityDaysV2 : serviceValidityDaysV2 // ignore: cast_nullable_to_non_nullable
as String?,serviceType: freezed == serviceType ? _self.serviceType : serviceType // ignore: cast_nullable_to_non_nullable
as String?,extendServiceEnddate: freezed == extendServiceEnddate ? _self.extendServiceEnddate : extendServiceEnddate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
