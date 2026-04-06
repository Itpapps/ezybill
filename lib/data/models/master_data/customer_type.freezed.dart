// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer_type.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CustomerType {

@JsonKey(name: 'customer_type_id') int get customerTypeId;@JsonKey(name: 'customer_type') String get customerType;@JsonKey(name: 'description') String get description;@JsonKey(name: 'status') int get status;@JsonKey(name: 'is_commercial_multi_box') int get isCommercialMultiBox;@JsonKey(name: 'enable_display') int get enableDisplay;
/// Create a copy of CustomerType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerTypeCopyWith<CustomerType> get copyWith => _$CustomerTypeCopyWithImpl<CustomerType>(this as CustomerType, _$identity);

  /// Serializes this CustomerType to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerType&&(identical(other.customerTypeId, customerTypeId) || other.customerTypeId == customerTypeId)&&(identical(other.customerType, customerType) || other.customerType == customerType)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.isCommercialMultiBox, isCommercialMultiBox) || other.isCommercialMultiBox == isCommercialMultiBox)&&(identical(other.enableDisplay, enableDisplay) || other.enableDisplay == enableDisplay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,customerTypeId,customerType,description,status,isCommercialMultiBox,enableDisplay);

@override
String toString() {
  return 'CustomerType(customerTypeId: $customerTypeId, customerType: $customerType, description: $description, status: $status, isCommercialMultiBox: $isCommercialMultiBox, enableDisplay: $enableDisplay)';
}


}

/// @nodoc
abstract mixin class $CustomerTypeCopyWith<$Res>  {
  factory $CustomerTypeCopyWith(CustomerType value, $Res Function(CustomerType) _then) = _$CustomerTypeCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'customer_type_id') int customerTypeId,@JsonKey(name: 'customer_type') String customerType,@JsonKey(name: 'description') String description,@JsonKey(name: 'status') int status,@JsonKey(name: 'is_commercial_multi_box') int isCommercialMultiBox,@JsonKey(name: 'enable_display') int enableDisplay
});




}
/// @nodoc
class _$CustomerTypeCopyWithImpl<$Res>
    implements $CustomerTypeCopyWith<$Res> {
  _$CustomerTypeCopyWithImpl(this._self, this._then);

  final CustomerType _self;
  final $Res Function(CustomerType) _then;

/// Create a copy of CustomerType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? customerTypeId = null,Object? customerType = null,Object? description = null,Object? status = null,Object? isCommercialMultiBox = null,Object? enableDisplay = null,}) {
  return _then(_self.copyWith(
customerTypeId: null == customerTypeId ? _self.customerTypeId : customerTypeId // ignore: cast_nullable_to_non_nullable
as int,customerType: null == customerType ? _self.customerType : customerType // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,isCommercialMultiBox: null == isCommercialMultiBox ? _self.isCommercialMultiBox : isCommercialMultiBox // ignore: cast_nullable_to_non_nullable
as int,enableDisplay: null == enableDisplay ? _self.enableDisplay : enableDisplay // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomerType].
extension CustomerTypePatterns on CustomerType {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomerType value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomerType() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomerType value)  $default,){
final _that = this;
switch (_that) {
case _CustomerType():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomerType value)?  $default,){
final _that = this;
switch (_that) {
case _CustomerType() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'customer_type_id')  int customerTypeId, @JsonKey(name: 'customer_type')  String customerType, @JsonKey(name: 'description')  String description, @JsonKey(name: 'status')  int status, @JsonKey(name: 'is_commercial_multi_box')  int isCommercialMultiBox, @JsonKey(name: 'enable_display')  int enableDisplay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomerType() when $default != null:
return $default(_that.customerTypeId,_that.customerType,_that.description,_that.status,_that.isCommercialMultiBox,_that.enableDisplay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'customer_type_id')  int customerTypeId, @JsonKey(name: 'customer_type')  String customerType, @JsonKey(name: 'description')  String description, @JsonKey(name: 'status')  int status, @JsonKey(name: 'is_commercial_multi_box')  int isCommercialMultiBox, @JsonKey(name: 'enable_display')  int enableDisplay)  $default,) {final _that = this;
switch (_that) {
case _CustomerType():
return $default(_that.customerTypeId,_that.customerType,_that.description,_that.status,_that.isCommercialMultiBox,_that.enableDisplay);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'customer_type_id')  int customerTypeId, @JsonKey(name: 'customer_type')  String customerType, @JsonKey(name: 'description')  String description, @JsonKey(name: 'status')  int status, @JsonKey(name: 'is_commercial_multi_box')  int isCommercialMultiBox, @JsonKey(name: 'enable_display')  int enableDisplay)?  $default,) {final _that = this;
switch (_that) {
case _CustomerType() when $default != null:
return $default(_that.customerTypeId,_that.customerType,_that.description,_that.status,_that.isCommercialMultiBox,_that.enableDisplay);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CustomerType implements CustomerType {
  const _CustomerType({@JsonKey(name: 'customer_type_id') this.customerTypeId = 0, @JsonKey(name: 'customer_type') this.customerType = '', @JsonKey(name: 'description') this.description = '', @JsonKey(name: 'status') this.status = 0, @JsonKey(name: 'is_commercial_multi_box') this.isCommercialMultiBox = 0, @JsonKey(name: 'enable_display') this.enableDisplay = 0});
  factory _CustomerType.fromJson(Map<String, dynamic> json) => _$CustomerTypeFromJson(json);

@override@JsonKey(name: 'customer_type_id') final  int customerTypeId;
@override@JsonKey(name: 'customer_type') final  String customerType;
@override@JsonKey(name: 'description') final  String description;
@override@JsonKey(name: 'status') final  int status;
@override@JsonKey(name: 'is_commercial_multi_box') final  int isCommercialMultiBox;
@override@JsonKey(name: 'enable_display') final  int enableDisplay;

/// Create a copy of CustomerType
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerTypeCopyWith<_CustomerType> get copyWith => __$CustomerTypeCopyWithImpl<_CustomerType>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomerTypeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomerType&&(identical(other.customerTypeId, customerTypeId) || other.customerTypeId == customerTypeId)&&(identical(other.customerType, customerType) || other.customerType == customerType)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.isCommercialMultiBox, isCommercialMultiBox) || other.isCommercialMultiBox == isCommercialMultiBox)&&(identical(other.enableDisplay, enableDisplay) || other.enableDisplay == enableDisplay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,customerTypeId,customerType,description,status,isCommercialMultiBox,enableDisplay);

@override
String toString() {
  return 'CustomerType(customerTypeId: $customerTypeId, customerType: $customerType, description: $description, status: $status, isCommercialMultiBox: $isCommercialMultiBox, enableDisplay: $enableDisplay)';
}


}

/// @nodoc
abstract mixin class _$CustomerTypeCopyWith<$Res> implements $CustomerTypeCopyWith<$Res> {
  factory _$CustomerTypeCopyWith(_CustomerType value, $Res Function(_CustomerType) _then) = __$CustomerTypeCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'customer_type_id') int customerTypeId,@JsonKey(name: 'customer_type') String customerType,@JsonKey(name: 'description') String description,@JsonKey(name: 'status') int status,@JsonKey(name: 'is_commercial_multi_box') int isCommercialMultiBox,@JsonKey(name: 'enable_display') int enableDisplay
});




}
/// @nodoc
class __$CustomerTypeCopyWithImpl<$Res>
    implements _$CustomerTypeCopyWith<$Res> {
  __$CustomerTypeCopyWithImpl(this._self, this._then);

  final _CustomerType _self;
  final $Res Function(_CustomerType) _then;

/// Create a copy of CustomerType
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? customerTypeId = null,Object? customerType = null,Object? description = null,Object? status = null,Object? isCommercialMultiBox = null,Object? enableDisplay = null,}) {
  return _then(_CustomerType(
customerTypeId: null == customerTypeId ? _self.customerTypeId : customerTypeId // ignore: cast_nullable_to_non_nullable
as int,customerType: null == customerType ? _self.customerType : customerType // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,isCommercialMultiBox: null == isCommercialMultiBox ? _self.isCommercialMultiBox : isCommercialMultiBox // ignore: cast_nullable_to_non_nullable
as int,enableDisplay: null == enableDisplay ? _self.enableDisplay : enableDisplay // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
