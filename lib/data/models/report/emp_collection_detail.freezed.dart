// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'emp_collection_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EmpCollectionDetail {

@JsonKey(name: 'customerId') String get customerId;@JsonKey(name: 'customerName') String get customerName;@JsonKey(name: 'paidAmount') double get paidAmount;@JsonKey(name: 'paidOn') String get paidOn;@JsonKey(name: 'paymentMode') String get paymentMode;@JsonKey(name: 'paymentId') String get paymentId;
/// Create a copy of EmpCollectionDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmpCollectionDetailCopyWith<EmpCollectionDetail> get copyWith => _$EmpCollectionDetailCopyWithImpl<EmpCollectionDetail>(this as EmpCollectionDetail, _$identity);

  /// Serializes this EmpCollectionDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmpCollectionDetail&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.paidOn, paidOn) || other.paidOn == paidOn)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,customerId,customerName,paidAmount,paidOn,paymentMode,paymentId);

@override
String toString() {
  return 'EmpCollectionDetail(customerId: $customerId, customerName: $customerName, paidAmount: $paidAmount, paidOn: $paidOn, paymentMode: $paymentMode, paymentId: $paymentId)';
}


}

/// @nodoc
abstract mixin class $EmpCollectionDetailCopyWith<$Res>  {
  factory $EmpCollectionDetailCopyWith(EmpCollectionDetail value, $Res Function(EmpCollectionDetail) _then) = _$EmpCollectionDetailCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'customerId') String customerId,@JsonKey(name: 'customerName') String customerName,@JsonKey(name: 'paidAmount') double paidAmount,@JsonKey(name: 'paidOn') String paidOn,@JsonKey(name: 'paymentMode') String paymentMode,@JsonKey(name: 'paymentId') String paymentId
});




}
/// @nodoc
class _$EmpCollectionDetailCopyWithImpl<$Res>
    implements $EmpCollectionDetailCopyWith<$Res> {
  _$EmpCollectionDetailCopyWithImpl(this._self, this._then);

  final EmpCollectionDetail _self;
  final $Res Function(EmpCollectionDetail) _then;

/// Create a copy of EmpCollectionDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? customerId = null,Object? customerName = null,Object? paidAmount = null,Object? paidOn = null,Object? paymentMode = null,Object? paymentId = null,}) {
  return _then(_self.copyWith(
customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as double,paidOn: null == paidOn ? _self.paidOn : paidOn // ignore: cast_nullable_to_non_nullable
as String,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,paymentId: null == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [EmpCollectionDetail].
extension EmpCollectionDetailPatterns on EmpCollectionDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmpCollectionDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmpCollectionDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmpCollectionDetail value)  $default,){
final _that = this;
switch (_that) {
case _EmpCollectionDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmpCollectionDetail value)?  $default,){
final _that = this;
switch (_that) {
case _EmpCollectionDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'customerId')  String customerId, @JsonKey(name: 'customerName')  String customerName, @JsonKey(name: 'paidAmount')  double paidAmount, @JsonKey(name: 'paidOn')  String paidOn, @JsonKey(name: 'paymentMode')  String paymentMode, @JsonKey(name: 'paymentId')  String paymentId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmpCollectionDetail() when $default != null:
return $default(_that.customerId,_that.customerName,_that.paidAmount,_that.paidOn,_that.paymentMode,_that.paymentId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'customerId')  String customerId, @JsonKey(name: 'customerName')  String customerName, @JsonKey(name: 'paidAmount')  double paidAmount, @JsonKey(name: 'paidOn')  String paidOn, @JsonKey(name: 'paymentMode')  String paymentMode, @JsonKey(name: 'paymentId')  String paymentId)  $default,) {final _that = this;
switch (_that) {
case _EmpCollectionDetail():
return $default(_that.customerId,_that.customerName,_that.paidAmount,_that.paidOn,_that.paymentMode,_that.paymentId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'customerId')  String customerId, @JsonKey(name: 'customerName')  String customerName, @JsonKey(name: 'paidAmount')  double paidAmount, @JsonKey(name: 'paidOn')  String paidOn, @JsonKey(name: 'paymentMode')  String paymentMode, @JsonKey(name: 'paymentId')  String paymentId)?  $default,) {final _that = this;
switch (_that) {
case _EmpCollectionDetail() when $default != null:
return $default(_that.customerId,_that.customerName,_that.paidAmount,_that.paidOn,_that.paymentMode,_that.paymentId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EmpCollectionDetail implements EmpCollectionDetail {
  const _EmpCollectionDetail({@JsonKey(name: 'customerId') this.customerId = '', @JsonKey(name: 'customerName') this.customerName = '', @JsonKey(name: 'paidAmount') this.paidAmount = 0.0, @JsonKey(name: 'paidOn') this.paidOn = '', @JsonKey(name: 'paymentMode') this.paymentMode = '', @JsonKey(name: 'paymentId') this.paymentId = ''});
  factory _EmpCollectionDetail.fromJson(Map<String, dynamic> json) => _$EmpCollectionDetailFromJson(json);

@override@JsonKey(name: 'customerId') final  String customerId;
@override@JsonKey(name: 'customerName') final  String customerName;
@override@JsonKey(name: 'paidAmount') final  double paidAmount;
@override@JsonKey(name: 'paidOn') final  String paidOn;
@override@JsonKey(name: 'paymentMode') final  String paymentMode;
@override@JsonKey(name: 'paymentId') final  String paymentId;

/// Create a copy of EmpCollectionDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmpCollectionDetailCopyWith<_EmpCollectionDetail> get copyWith => __$EmpCollectionDetailCopyWithImpl<_EmpCollectionDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmpCollectionDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmpCollectionDetail&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.paidOn, paidOn) || other.paidOn == paidOn)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,customerId,customerName,paidAmount,paidOn,paymentMode,paymentId);

@override
String toString() {
  return 'EmpCollectionDetail(customerId: $customerId, customerName: $customerName, paidAmount: $paidAmount, paidOn: $paidOn, paymentMode: $paymentMode, paymentId: $paymentId)';
}


}

/// @nodoc
abstract mixin class _$EmpCollectionDetailCopyWith<$Res> implements $EmpCollectionDetailCopyWith<$Res> {
  factory _$EmpCollectionDetailCopyWith(_EmpCollectionDetail value, $Res Function(_EmpCollectionDetail) _then) = __$EmpCollectionDetailCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'customerId') String customerId,@JsonKey(name: 'customerName') String customerName,@JsonKey(name: 'paidAmount') double paidAmount,@JsonKey(name: 'paidOn') String paidOn,@JsonKey(name: 'paymentMode') String paymentMode,@JsonKey(name: 'paymentId') String paymentId
});




}
/// @nodoc
class __$EmpCollectionDetailCopyWithImpl<$Res>
    implements _$EmpCollectionDetailCopyWith<$Res> {
  __$EmpCollectionDetailCopyWithImpl(this._self, this._then);

  final _EmpCollectionDetail _self;
  final $Res Function(_EmpCollectionDetail) _then;

/// Create a copy of EmpCollectionDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? customerId = null,Object? customerName = null,Object? paidAmount = null,Object? paidOn = null,Object? paymentMode = null,Object? paymentId = null,}) {
  return _then(_EmpCollectionDetail(
customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as double,paidOn: null == paidOn ? _self.paidOn : paidOn // ignore: cast_nullable_to_non_nullable
as String,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,paymentId: null == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
