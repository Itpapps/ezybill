// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mini_day_report_row.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MiniDayReportRow {

@JsonKey(name: 'payment_mode') String get paymentMode;@JsonKey(name: 'cust_count') int get custCount;@JsonKey(name: 'total') double get total;
/// Create a copy of MiniDayReportRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MiniDayReportRowCopyWith<MiniDayReportRow> get copyWith => _$MiniDayReportRowCopyWithImpl<MiniDayReportRow>(this as MiniDayReportRow, _$identity);

  /// Serializes this MiniDayReportRow to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MiniDayReportRow&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.custCount, custCount) || other.custCount == custCount)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,paymentMode,custCount,total);

@override
String toString() {
  return 'MiniDayReportRow(paymentMode: $paymentMode, custCount: $custCount, total: $total)';
}


}

/// @nodoc
abstract mixin class $MiniDayReportRowCopyWith<$Res>  {
  factory $MiniDayReportRowCopyWith(MiniDayReportRow value, $Res Function(MiniDayReportRow) _then) = _$MiniDayReportRowCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'payment_mode') String paymentMode,@JsonKey(name: 'cust_count') int custCount,@JsonKey(name: 'total') double total
});




}
/// @nodoc
class _$MiniDayReportRowCopyWithImpl<$Res>
    implements $MiniDayReportRowCopyWith<$Res> {
  _$MiniDayReportRowCopyWithImpl(this._self, this._then);

  final MiniDayReportRow _self;
  final $Res Function(MiniDayReportRow) _then;

/// Create a copy of MiniDayReportRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? paymentMode = null,Object? custCount = null,Object? total = null,}) {
  return _then(_self.copyWith(
paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,custCount: null == custCount ? _self.custCount : custCount // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [MiniDayReportRow].
extension MiniDayReportRowPatterns on MiniDayReportRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MiniDayReportRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MiniDayReportRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MiniDayReportRow value)  $default,){
final _that = this;
switch (_that) {
case _MiniDayReportRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MiniDayReportRow value)?  $default,){
final _that = this;
switch (_that) {
case _MiniDayReportRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'payment_mode')  String paymentMode, @JsonKey(name: 'cust_count')  int custCount, @JsonKey(name: 'total')  double total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MiniDayReportRow() when $default != null:
return $default(_that.paymentMode,_that.custCount,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'payment_mode')  String paymentMode, @JsonKey(name: 'cust_count')  int custCount, @JsonKey(name: 'total')  double total)  $default,) {final _that = this;
switch (_that) {
case _MiniDayReportRow():
return $default(_that.paymentMode,_that.custCount,_that.total);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'payment_mode')  String paymentMode, @JsonKey(name: 'cust_count')  int custCount, @JsonKey(name: 'total')  double total)?  $default,) {final _that = this;
switch (_that) {
case _MiniDayReportRow() when $default != null:
return $default(_that.paymentMode,_that.custCount,_that.total);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MiniDayReportRow implements MiniDayReportRow {
  const _MiniDayReportRow({@JsonKey(name: 'payment_mode') this.paymentMode = '', @JsonKey(name: 'cust_count') this.custCount = 0, @JsonKey(name: 'total') this.total = 0.0});
  factory _MiniDayReportRow.fromJson(Map<String, dynamic> json) => _$MiniDayReportRowFromJson(json);

@override@JsonKey(name: 'payment_mode') final  String paymentMode;
@override@JsonKey(name: 'cust_count') final  int custCount;
@override@JsonKey(name: 'total') final  double total;

/// Create a copy of MiniDayReportRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MiniDayReportRowCopyWith<_MiniDayReportRow> get copyWith => __$MiniDayReportRowCopyWithImpl<_MiniDayReportRow>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MiniDayReportRowToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MiniDayReportRow&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.custCount, custCount) || other.custCount == custCount)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,paymentMode,custCount,total);

@override
String toString() {
  return 'MiniDayReportRow(paymentMode: $paymentMode, custCount: $custCount, total: $total)';
}


}

/// @nodoc
abstract mixin class _$MiniDayReportRowCopyWith<$Res> implements $MiniDayReportRowCopyWith<$Res> {
  factory _$MiniDayReportRowCopyWith(_MiniDayReportRow value, $Res Function(_MiniDayReportRow) _then) = __$MiniDayReportRowCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'payment_mode') String paymentMode,@JsonKey(name: 'cust_count') int custCount,@JsonKey(name: 'total') double total
});




}
/// @nodoc
class __$MiniDayReportRowCopyWithImpl<$Res>
    implements _$MiniDayReportRowCopyWith<$Res> {
  __$MiniDayReportRowCopyWithImpl(this._self, this._then);

  final _MiniDayReportRow _self;
  final $Res Function(_MiniDayReportRow) _then;

/// Create a copy of MiniDayReportRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? paymentMode = null,Object? custCount = null,Object? total = null,}) {
  return _then(_MiniDayReportRow(
paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,custCount: null == custCount ? _self.custCount : custCount // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
