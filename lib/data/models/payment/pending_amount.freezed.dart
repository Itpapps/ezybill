// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pending_amount.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PendingAmount {

@JsonKey(name: 'status_code') int get statusCode;@JsonKey(name: 'pendingAmount') double get pendingAmount;@JsonKey(name: 'customerName') String get customerName;@JsonKey(name: 'mobileNumber') String get mobileNumber;@JsonKey(name: 'msoShare') double get msoShare;@JsonKey(name: 'lcoShare') double get lcoShare;@JsonKey(name: 'billingId') String get billingId;
/// Create a copy of PendingAmount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PendingAmountCopyWith<PendingAmount> get copyWith => _$PendingAmountCopyWithImpl<PendingAmount>(this as PendingAmount, _$identity);

  /// Serializes this PendingAmount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingAmount&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.pendingAmount, pendingAmount) || other.pendingAmount == pendingAmount)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.mobileNumber, mobileNumber) || other.mobileNumber == mobileNumber)&&(identical(other.msoShare, msoShare) || other.msoShare == msoShare)&&(identical(other.lcoShare, lcoShare) || other.lcoShare == lcoShare)&&(identical(other.billingId, billingId) || other.billingId == billingId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,statusCode,pendingAmount,customerName,mobileNumber,msoShare,lcoShare,billingId);

@override
String toString() {
  return 'PendingAmount(statusCode: $statusCode, pendingAmount: $pendingAmount, customerName: $customerName, mobileNumber: $mobileNumber, msoShare: $msoShare, lcoShare: $lcoShare, billingId: $billingId)';
}


}

/// @nodoc
abstract mixin class $PendingAmountCopyWith<$Res>  {
  factory $PendingAmountCopyWith(PendingAmount value, $Res Function(PendingAmount) _then) = _$PendingAmountCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'status_code') int statusCode,@JsonKey(name: 'pendingAmount') double pendingAmount,@JsonKey(name: 'customerName') String customerName,@JsonKey(name: 'mobileNumber') String mobileNumber,@JsonKey(name: 'msoShare') double msoShare,@JsonKey(name: 'lcoShare') double lcoShare,@JsonKey(name: 'billingId') String billingId
});




}
/// @nodoc
class _$PendingAmountCopyWithImpl<$Res>
    implements $PendingAmountCopyWith<$Res> {
  _$PendingAmountCopyWithImpl(this._self, this._then);

  final PendingAmount _self;
  final $Res Function(PendingAmount) _then;

/// Create a copy of PendingAmount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? statusCode = null,Object? pendingAmount = null,Object? customerName = null,Object? mobileNumber = null,Object? msoShare = null,Object? lcoShare = null,Object? billingId = null,}) {
  return _then(_self.copyWith(
statusCode: null == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int,pendingAmount: null == pendingAmount ? _self.pendingAmount : pendingAmount // ignore: cast_nullable_to_non_nullable
as double,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,mobileNumber: null == mobileNumber ? _self.mobileNumber : mobileNumber // ignore: cast_nullable_to_non_nullable
as String,msoShare: null == msoShare ? _self.msoShare : msoShare // ignore: cast_nullable_to_non_nullable
as double,lcoShare: null == lcoShare ? _self.lcoShare : lcoShare // ignore: cast_nullable_to_non_nullable
as double,billingId: null == billingId ? _self.billingId : billingId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PendingAmount].
extension PendingAmountPatterns on PendingAmount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PendingAmount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PendingAmount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PendingAmount value)  $default,){
final _that = this;
switch (_that) {
case _PendingAmount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PendingAmount value)?  $default,){
final _that = this;
switch (_that) {
case _PendingAmount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'status_code')  int statusCode, @JsonKey(name: 'pendingAmount')  double pendingAmount, @JsonKey(name: 'customerName')  String customerName, @JsonKey(name: 'mobileNumber')  String mobileNumber, @JsonKey(name: 'msoShare')  double msoShare, @JsonKey(name: 'lcoShare')  double lcoShare, @JsonKey(name: 'billingId')  String billingId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PendingAmount() when $default != null:
return $default(_that.statusCode,_that.pendingAmount,_that.customerName,_that.mobileNumber,_that.msoShare,_that.lcoShare,_that.billingId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'status_code')  int statusCode, @JsonKey(name: 'pendingAmount')  double pendingAmount, @JsonKey(name: 'customerName')  String customerName, @JsonKey(name: 'mobileNumber')  String mobileNumber, @JsonKey(name: 'msoShare')  double msoShare, @JsonKey(name: 'lcoShare')  double lcoShare, @JsonKey(name: 'billingId')  String billingId)  $default,) {final _that = this;
switch (_that) {
case _PendingAmount():
return $default(_that.statusCode,_that.pendingAmount,_that.customerName,_that.mobileNumber,_that.msoShare,_that.lcoShare,_that.billingId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'status_code')  int statusCode, @JsonKey(name: 'pendingAmount')  double pendingAmount, @JsonKey(name: 'customerName')  String customerName, @JsonKey(name: 'mobileNumber')  String mobileNumber, @JsonKey(name: 'msoShare')  double msoShare, @JsonKey(name: 'lcoShare')  double lcoShare, @JsonKey(name: 'billingId')  String billingId)?  $default,) {final _that = this;
switch (_that) {
case _PendingAmount() when $default != null:
return $default(_that.statusCode,_that.pendingAmount,_that.customerName,_that.mobileNumber,_that.msoShare,_that.lcoShare,_that.billingId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PendingAmount implements PendingAmount {
  const _PendingAmount({@JsonKey(name: 'status_code') this.statusCode = 0, @JsonKey(name: 'pendingAmount') this.pendingAmount = 0.0, @JsonKey(name: 'customerName') this.customerName = '', @JsonKey(name: 'mobileNumber') this.mobileNumber = '', @JsonKey(name: 'msoShare') this.msoShare = 0.0, @JsonKey(name: 'lcoShare') this.lcoShare = 0.0, @JsonKey(name: 'billingId') this.billingId = ''});
  factory _PendingAmount.fromJson(Map<String, dynamic> json) => _$PendingAmountFromJson(json);

@override@JsonKey(name: 'status_code') final  int statusCode;
@override@JsonKey(name: 'pendingAmount') final  double pendingAmount;
@override@JsonKey(name: 'customerName') final  String customerName;
@override@JsonKey(name: 'mobileNumber') final  String mobileNumber;
@override@JsonKey(name: 'msoShare') final  double msoShare;
@override@JsonKey(name: 'lcoShare') final  double lcoShare;
@override@JsonKey(name: 'billingId') final  String billingId;

/// Create a copy of PendingAmount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PendingAmountCopyWith<_PendingAmount> get copyWith => __$PendingAmountCopyWithImpl<_PendingAmount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PendingAmountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PendingAmount&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.pendingAmount, pendingAmount) || other.pendingAmount == pendingAmount)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.mobileNumber, mobileNumber) || other.mobileNumber == mobileNumber)&&(identical(other.msoShare, msoShare) || other.msoShare == msoShare)&&(identical(other.lcoShare, lcoShare) || other.lcoShare == lcoShare)&&(identical(other.billingId, billingId) || other.billingId == billingId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,statusCode,pendingAmount,customerName,mobileNumber,msoShare,lcoShare,billingId);

@override
String toString() {
  return 'PendingAmount(statusCode: $statusCode, pendingAmount: $pendingAmount, customerName: $customerName, mobileNumber: $mobileNumber, msoShare: $msoShare, lcoShare: $lcoShare, billingId: $billingId)';
}


}

/// @nodoc
abstract mixin class _$PendingAmountCopyWith<$Res> implements $PendingAmountCopyWith<$Res> {
  factory _$PendingAmountCopyWith(_PendingAmount value, $Res Function(_PendingAmount) _then) = __$PendingAmountCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'status_code') int statusCode,@JsonKey(name: 'pendingAmount') double pendingAmount,@JsonKey(name: 'customerName') String customerName,@JsonKey(name: 'mobileNumber') String mobileNumber,@JsonKey(name: 'msoShare') double msoShare,@JsonKey(name: 'lcoShare') double lcoShare,@JsonKey(name: 'billingId') String billingId
});




}
/// @nodoc
class __$PendingAmountCopyWithImpl<$Res>
    implements _$PendingAmountCopyWith<$Res> {
  __$PendingAmountCopyWithImpl(this._self, this._then);

  final _PendingAmount _self;
  final $Res Function(_PendingAmount) _then;

/// Create a copy of PendingAmount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? statusCode = null,Object? pendingAmount = null,Object? customerName = null,Object? mobileNumber = null,Object? msoShare = null,Object? lcoShare = null,Object? billingId = null,}) {
  return _then(_PendingAmount(
statusCode: null == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int,pendingAmount: null == pendingAmount ? _self.pendingAmount : pendingAmount // ignore: cast_nullable_to_non_nullable
as double,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,mobileNumber: null == mobileNumber ? _self.mobileNumber : mobileNumber // ignore: cast_nullable_to_non_nullable
as String,msoShare: null == msoShare ? _self.msoShare : msoShare // ignore: cast_nullable_to_non_nullable
as double,lcoShare: null == lcoShare ? _self.lcoShare : lcoShare // ignore: cast_nullable_to_non_nullable
as double,billingId: null == billingId ? _self.billingId : billingId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
