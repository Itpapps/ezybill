// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'receipt_range.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReceiptRange {

@JsonKey(name: 'rangeId') String get rangeId;@JsonKey(name: 'fromNumber') String get fromNumber;@JsonKey(name: 'toNumber') String get toNumber;@JsonKey(name: 'currentNumber') String get currentNumber;
/// Create a copy of ReceiptRange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceiptRangeCopyWith<ReceiptRange> get copyWith => _$ReceiptRangeCopyWithImpl<ReceiptRange>(this as ReceiptRange, _$identity);

  /// Serializes this ReceiptRange to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceiptRange&&(identical(other.rangeId, rangeId) || other.rangeId == rangeId)&&(identical(other.fromNumber, fromNumber) || other.fromNumber == fromNumber)&&(identical(other.toNumber, toNumber) || other.toNumber == toNumber)&&(identical(other.currentNumber, currentNumber) || other.currentNumber == currentNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rangeId,fromNumber,toNumber,currentNumber);

@override
String toString() {
  return 'ReceiptRange(rangeId: $rangeId, fromNumber: $fromNumber, toNumber: $toNumber, currentNumber: $currentNumber)';
}


}

/// @nodoc
abstract mixin class $ReceiptRangeCopyWith<$Res>  {
  factory $ReceiptRangeCopyWith(ReceiptRange value, $Res Function(ReceiptRange) _then) = _$ReceiptRangeCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'rangeId') String rangeId,@JsonKey(name: 'fromNumber') String fromNumber,@JsonKey(name: 'toNumber') String toNumber,@JsonKey(name: 'currentNumber') String currentNumber
});




}
/// @nodoc
class _$ReceiptRangeCopyWithImpl<$Res>
    implements $ReceiptRangeCopyWith<$Res> {
  _$ReceiptRangeCopyWithImpl(this._self, this._then);

  final ReceiptRange _self;
  final $Res Function(ReceiptRange) _then;

/// Create a copy of ReceiptRange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rangeId = null,Object? fromNumber = null,Object? toNumber = null,Object? currentNumber = null,}) {
  return _then(_self.copyWith(
rangeId: null == rangeId ? _self.rangeId : rangeId // ignore: cast_nullable_to_non_nullable
as String,fromNumber: null == fromNumber ? _self.fromNumber : fromNumber // ignore: cast_nullable_to_non_nullable
as String,toNumber: null == toNumber ? _self.toNumber : toNumber // ignore: cast_nullable_to_non_nullable
as String,currentNumber: null == currentNumber ? _self.currentNumber : currentNumber // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReceiptRange].
extension ReceiptRangePatterns on ReceiptRange {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReceiptRange value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReceiptRange() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReceiptRange value)  $default,){
final _that = this;
switch (_that) {
case _ReceiptRange():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReceiptRange value)?  $default,){
final _that = this;
switch (_that) {
case _ReceiptRange() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'rangeId')  String rangeId, @JsonKey(name: 'fromNumber')  String fromNumber, @JsonKey(name: 'toNumber')  String toNumber, @JsonKey(name: 'currentNumber')  String currentNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReceiptRange() when $default != null:
return $default(_that.rangeId,_that.fromNumber,_that.toNumber,_that.currentNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'rangeId')  String rangeId, @JsonKey(name: 'fromNumber')  String fromNumber, @JsonKey(name: 'toNumber')  String toNumber, @JsonKey(name: 'currentNumber')  String currentNumber)  $default,) {final _that = this;
switch (_that) {
case _ReceiptRange():
return $default(_that.rangeId,_that.fromNumber,_that.toNumber,_that.currentNumber);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'rangeId')  String rangeId, @JsonKey(name: 'fromNumber')  String fromNumber, @JsonKey(name: 'toNumber')  String toNumber, @JsonKey(name: 'currentNumber')  String currentNumber)?  $default,) {final _that = this;
switch (_that) {
case _ReceiptRange() when $default != null:
return $default(_that.rangeId,_that.fromNumber,_that.toNumber,_that.currentNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReceiptRange implements ReceiptRange {
  const _ReceiptRange({@JsonKey(name: 'rangeId') required this.rangeId, @JsonKey(name: 'fromNumber') required this.fromNumber, @JsonKey(name: 'toNumber') required this.toNumber, @JsonKey(name: 'currentNumber') required this.currentNumber});
  factory _ReceiptRange.fromJson(Map<String, dynamic> json) => _$ReceiptRangeFromJson(json);

@override@JsonKey(name: 'rangeId') final  String rangeId;
@override@JsonKey(name: 'fromNumber') final  String fromNumber;
@override@JsonKey(name: 'toNumber') final  String toNumber;
@override@JsonKey(name: 'currentNumber') final  String currentNumber;

/// Create a copy of ReceiptRange
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReceiptRangeCopyWith<_ReceiptRange> get copyWith => __$ReceiptRangeCopyWithImpl<_ReceiptRange>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReceiptRangeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReceiptRange&&(identical(other.rangeId, rangeId) || other.rangeId == rangeId)&&(identical(other.fromNumber, fromNumber) || other.fromNumber == fromNumber)&&(identical(other.toNumber, toNumber) || other.toNumber == toNumber)&&(identical(other.currentNumber, currentNumber) || other.currentNumber == currentNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rangeId,fromNumber,toNumber,currentNumber);

@override
String toString() {
  return 'ReceiptRange(rangeId: $rangeId, fromNumber: $fromNumber, toNumber: $toNumber, currentNumber: $currentNumber)';
}


}

/// @nodoc
abstract mixin class _$ReceiptRangeCopyWith<$Res> implements $ReceiptRangeCopyWith<$Res> {
  factory _$ReceiptRangeCopyWith(_ReceiptRange value, $Res Function(_ReceiptRange) _then) = __$ReceiptRangeCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'rangeId') String rangeId,@JsonKey(name: 'fromNumber') String fromNumber,@JsonKey(name: 'toNumber') String toNumber,@JsonKey(name: 'currentNumber') String currentNumber
});




}
/// @nodoc
class __$ReceiptRangeCopyWithImpl<$Res>
    implements _$ReceiptRangeCopyWith<$Res> {
  __$ReceiptRangeCopyWithImpl(this._self, this._then);

  final _ReceiptRange _self;
  final $Res Function(_ReceiptRange) _then;

/// Create a copy of ReceiptRange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rangeId = null,Object? fromNumber = null,Object? toNumber = null,Object? currentNumber = null,}) {
  return _then(_ReceiptRange(
rangeId: null == rangeId ? _self.rangeId : rangeId // ignore: cast_nullable_to_non_nullable
as String,fromNumber: null == fromNumber ? _self.fromNumber : fromNumber // ignore: cast_nullable_to_non_nullable
as String,toNumber: null == toNumber ? _self.toNumber : toNumber // ignore: cast_nullable_to_non_nullable
as String,currentNumber: null == currentNumber ? _self.currentNumber : currentNumber // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
