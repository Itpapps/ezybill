// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_mode.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaymentMode {

@JsonKey(name: 'paymentModeId') String get paymentModeId;@JsonKey(name: 'PaymentModeName') String get paymentModeName;
/// Create a copy of PaymentMode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentModeCopyWith<PaymentMode> get copyWith => _$PaymentModeCopyWithImpl<PaymentMode>(this as PaymentMode, _$identity);

  /// Serializes this PaymentMode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentMode&&(identical(other.paymentModeId, paymentModeId) || other.paymentModeId == paymentModeId)&&(identical(other.paymentModeName, paymentModeName) || other.paymentModeName == paymentModeName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,paymentModeId,paymentModeName);

@override
String toString() {
  return 'PaymentMode(paymentModeId: $paymentModeId, paymentModeName: $paymentModeName)';
}


}

/// @nodoc
abstract mixin class $PaymentModeCopyWith<$Res>  {
  factory $PaymentModeCopyWith(PaymentMode value, $Res Function(PaymentMode) _then) = _$PaymentModeCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'paymentModeId') String paymentModeId,@JsonKey(name: 'PaymentModeName') String paymentModeName
});




}
/// @nodoc
class _$PaymentModeCopyWithImpl<$Res>
    implements $PaymentModeCopyWith<$Res> {
  _$PaymentModeCopyWithImpl(this._self, this._then);

  final PaymentMode _self;
  final $Res Function(PaymentMode) _then;

/// Create a copy of PaymentMode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? paymentModeId = null,Object? paymentModeName = null,}) {
  return _then(_self.copyWith(
paymentModeId: null == paymentModeId ? _self.paymentModeId : paymentModeId // ignore: cast_nullable_to_non_nullable
as String,paymentModeName: null == paymentModeName ? _self.paymentModeName : paymentModeName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentMode].
extension PaymentModePatterns on PaymentMode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentMode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentMode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentMode value)  $default,){
final _that = this;
switch (_that) {
case _PaymentMode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentMode value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentMode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'paymentModeId')  String paymentModeId, @JsonKey(name: 'PaymentModeName')  String paymentModeName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentMode() when $default != null:
return $default(_that.paymentModeId,_that.paymentModeName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'paymentModeId')  String paymentModeId, @JsonKey(name: 'PaymentModeName')  String paymentModeName)  $default,) {final _that = this;
switch (_that) {
case _PaymentMode():
return $default(_that.paymentModeId,_that.paymentModeName);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'paymentModeId')  String paymentModeId, @JsonKey(name: 'PaymentModeName')  String paymentModeName)?  $default,) {final _that = this;
switch (_that) {
case _PaymentMode() when $default != null:
return $default(_that.paymentModeId,_that.paymentModeName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentMode implements PaymentMode {
  const _PaymentMode({@JsonKey(name: 'paymentModeId') this.paymentModeId = '', @JsonKey(name: 'PaymentModeName') this.paymentModeName = ''});
  factory _PaymentMode.fromJson(Map<String, dynamic> json) => _$PaymentModeFromJson(json);

@override@JsonKey(name: 'paymentModeId') final  String paymentModeId;
@override@JsonKey(name: 'PaymentModeName') final  String paymentModeName;

/// Create a copy of PaymentMode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentModeCopyWith<_PaymentMode> get copyWith => __$PaymentModeCopyWithImpl<_PaymentMode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentModeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentMode&&(identical(other.paymentModeId, paymentModeId) || other.paymentModeId == paymentModeId)&&(identical(other.paymentModeName, paymentModeName) || other.paymentModeName == paymentModeName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,paymentModeId,paymentModeName);

@override
String toString() {
  return 'PaymentMode(paymentModeId: $paymentModeId, paymentModeName: $paymentModeName)';
}


}

/// @nodoc
abstract mixin class _$PaymentModeCopyWith<$Res> implements $PaymentModeCopyWith<$Res> {
  factory _$PaymentModeCopyWith(_PaymentMode value, $Res Function(_PaymentMode) _then) = __$PaymentModeCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'paymentModeId') String paymentModeId,@JsonKey(name: 'PaymentModeName') String paymentModeName
});




}
/// @nodoc
class __$PaymentModeCopyWithImpl<$Res>
    implements _$PaymentModeCopyWith<$Res> {
  __$PaymentModeCopyWithImpl(this._self, this._then);

  final _PaymentMode _self;
  final $Res Function(_PaymentMode) _then;

/// Create a copy of PaymentMode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? paymentModeId = null,Object? paymentModeName = null,}) {
  return _then(_PaymentMode(
paymentModeId: null == paymentModeId ? _self.paymentModeId : paymentModeId // ignore: cast_nullable_to_non_nullable
as String,paymentModeName: null == paymentModeName ? _self.paymentModeName : paymentModeName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
