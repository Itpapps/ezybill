// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_history_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaymentHistoryItem {

@JsonKey(name: 'paymentId') String get paymentId;@JsonKey(name: 'paidOn') String get paidOn;@JsonKey(name: 'paidAmount') double get paidAmount;@JsonKey(name: 'receiptNo') String get receiptNo;@JsonKey(name: 'paymentMode') String get paymentMode;@JsonKey(name: 'remarks') String? get remarks;@JsonKey(name: 'employeeName') String? get employeeName;
/// Create a copy of PaymentHistoryItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentHistoryItemCopyWith<PaymentHistoryItem> get copyWith => _$PaymentHistoryItemCopyWithImpl<PaymentHistoryItem>(this as PaymentHistoryItem, _$identity);

  /// Serializes this PaymentHistoryItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentHistoryItem&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId)&&(identical(other.paidOn, paidOn) || other.paidOn == paidOn)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.receiptNo, receiptNo) || other.receiptNo == receiptNo)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&(identical(other.employeeName, employeeName) || other.employeeName == employeeName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,paymentId,paidOn,paidAmount,receiptNo,paymentMode,remarks,employeeName);

@override
String toString() {
  return 'PaymentHistoryItem(paymentId: $paymentId, paidOn: $paidOn, paidAmount: $paidAmount, receiptNo: $receiptNo, paymentMode: $paymentMode, remarks: $remarks, employeeName: $employeeName)';
}


}

/// @nodoc
abstract mixin class $PaymentHistoryItemCopyWith<$Res>  {
  factory $PaymentHistoryItemCopyWith(PaymentHistoryItem value, $Res Function(PaymentHistoryItem) _then) = _$PaymentHistoryItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'paymentId') String paymentId,@JsonKey(name: 'paidOn') String paidOn,@JsonKey(name: 'paidAmount') double paidAmount,@JsonKey(name: 'receiptNo') String receiptNo,@JsonKey(name: 'paymentMode') String paymentMode,@JsonKey(name: 'remarks') String? remarks,@JsonKey(name: 'employeeName') String? employeeName
});




}
/// @nodoc
class _$PaymentHistoryItemCopyWithImpl<$Res>
    implements $PaymentHistoryItemCopyWith<$Res> {
  _$PaymentHistoryItemCopyWithImpl(this._self, this._then);

  final PaymentHistoryItem _self;
  final $Res Function(PaymentHistoryItem) _then;

/// Create a copy of PaymentHistoryItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? paymentId = null,Object? paidOn = null,Object? paidAmount = null,Object? receiptNo = null,Object? paymentMode = null,Object? remarks = freezed,Object? employeeName = freezed,}) {
  return _then(_self.copyWith(
paymentId: null == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String,paidOn: null == paidOn ? _self.paidOn : paidOn // ignore: cast_nullable_to_non_nullable
as String,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as double,receiptNo: null == receiptNo ? _self.receiptNo : receiptNo // ignore: cast_nullable_to_non_nullable
as String,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,employeeName: freezed == employeeName ? _self.employeeName : employeeName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentHistoryItem].
extension PaymentHistoryItemPatterns on PaymentHistoryItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentHistoryItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentHistoryItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentHistoryItem value)  $default,){
final _that = this;
switch (_that) {
case _PaymentHistoryItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentHistoryItem value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentHistoryItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'paymentId')  String paymentId, @JsonKey(name: 'paidOn')  String paidOn, @JsonKey(name: 'paidAmount')  double paidAmount, @JsonKey(name: 'receiptNo')  String receiptNo, @JsonKey(name: 'paymentMode')  String paymentMode, @JsonKey(name: 'remarks')  String? remarks, @JsonKey(name: 'employeeName')  String? employeeName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentHistoryItem() when $default != null:
return $default(_that.paymentId,_that.paidOn,_that.paidAmount,_that.receiptNo,_that.paymentMode,_that.remarks,_that.employeeName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'paymentId')  String paymentId, @JsonKey(name: 'paidOn')  String paidOn, @JsonKey(name: 'paidAmount')  double paidAmount, @JsonKey(name: 'receiptNo')  String receiptNo, @JsonKey(name: 'paymentMode')  String paymentMode, @JsonKey(name: 'remarks')  String? remarks, @JsonKey(name: 'employeeName')  String? employeeName)  $default,) {final _that = this;
switch (_that) {
case _PaymentHistoryItem():
return $default(_that.paymentId,_that.paidOn,_that.paidAmount,_that.receiptNo,_that.paymentMode,_that.remarks,_that.employeeName);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'paymentId')  String paymentId, @JsonKey(name: 'paidOn')  String paidOn, @JsonKey(name: 'paidAmount')  double paidAmount, @JsonKey(name: 'receiptNo')  String receiptNo, @JsonKey(name: 'paymentMode')  String paymentMode, @JsonKey(name: 'remarks')  String? remarks, @JsonKey(name: 'employeeName')  String? employeeName)?  $default,) {final _that = this;
switch (_that) {
case _PaymentHistoryItem() when $default != null:
return $default(_that.paymentId,_that.paidOn,_that.paidAmount,_that.receiptNo,_that.paymentMode,_that.remarks,_that.employeeName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentHistoryItem implements PaymentHistoryItem {
  const _PaymentHistoryItem({@JsonKey(name: 'paymentId') this.paymentId = '', @JsonKey(name: 'paidOn') this.paidOn = '', @JsonKey(name: 'paidAmount') this.paidAmount = 0.0, @JsonKey(name: 'receiptNo') this.receiptNo = '', @JsonKey(name: 'paymentMode') this.paymentMode = '', @JsonKey(name: 'remarks') this.remarks, @JsonKey(name: 'employeeName') this.employeeName});
  factory _PaymentHistoryItem.fromJson(Map<String, dynamic> json) => _$PaymentHistoryItemFromJson(json);

@override@JsonKey(name: 'paymentId') final  String paymentId;
@override@JsonKey(name: 'paidOn') final  String paidOn;
@override@JsonKey(name: 'paidAmount') final  double paidAmount;
@override@JsonKey(name: 'receiptNo') final  String receiptNo;
@override@JsonKey(name: 'paymentMode') final  String paymentMode;
@override@JsonKey(name: 'remarks') final  String? remarks;
@override@JsonKey(name: 'employeeName') final  String? employeeName;

/// Create a copy of PaymentHistoryItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentHistoryItemCopyWith<_PaymentHistoryItem> get copyWith => __$PaymentHistoryItemCopyWithImpl<_PaymentHistoryItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentHistoryItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentHistoryItem&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId)&&(identical(other.paidOn, paidOn) || other.paidOn == paidOn)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.receiptNo, receiptNo) || other.receiptNo == receiptNo)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&(identical(other.employeeName, employeeName) || other.employeeName == employeeName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,paymentId,paidOn,paidAmount,receiptNo,paymentMode,remarks,employeeName);

@override
String toString() {
  return 'PaymentHistoryItem(paymentId: $paymentId, paidOn: $paidOn, paidAmount: $paidAmount, receiptNo: $receiptNo, paymentMode: $paymentMode, remarks: $remarks, employeeName: $employeeName)';
}


}

/// @nodoc
abstract mixin class _$PaymentHistoryItemCopyWith<$Res> implements $PaymentHistoryItemCopyWith<$Res> {
  factory _$PaymentHistoryItemCopyWith(_PaymentHistoryItem value, $Res Function(_PaymentHistoryItem) _then) = __$PaymentHistoryItemCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'paymentId') String paymentId,@JsonKey(name: 'paidOn') String paidOn,@JsonKey(name: 'paidAmount') double paidAmount,@JsonKey(name: 'receiptNo') String receiptNo,@JsonKey(name: 'paymentMode') String paymentMode,@JsonKey(name: 'remarks') String? remarks,@JsonKey(name: 'employeeName') String? employeeName
});




}
/// @nodoc
class __$PaymentHistoryItemCopyWithImpl<$Res>
    implements _$PaymentHistoryItemCopyWith<$Res> {
  __$PaymentHistoryItemCopyWithImpl(this._self, this._then);

  final _PaymentHistoryItem _self;
  final $Res Function(_PaymentHistoryItem) _then;

/// Create a copy of PaymentHistoryItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? paymentId = null,Object? paidOn = null,Object? paidAmount = null,Object? receiptNo = null,Object? paymentMode = null,Object? remarks = freezed,Object? employeeName = freezed,}) {
  return _then(_PaymentHistoryItem(
paymentId: null == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String,paidOn: null == paidOn ? _self.paidOn : paidOn // ignore: cast_nullable_to_non_nullable
as String,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as double,receiptNo: null == receiptNo ? _self.receiptNo : receiptNo // ignore: cast_nullable_to_non_nullable
as String,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,employeeName: freezed == employeeName ? _self.employeeName : employeeName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
