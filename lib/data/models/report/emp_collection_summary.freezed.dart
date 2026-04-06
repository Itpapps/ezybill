// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'emp_collection_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EmpCollectionSummary {

@JsonKey(name: 'employee_id') String get employeeId;@JsonKey(name: 'name') String get name;@JsonKey(name: 'Amt') double get amt;
/// Create a copy of EmpCollectionSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmpCollectionSummaryCopyWith<EmpCollectionSummary> get copyWith => _$EmpCollectionSummaryCopyWithImpl<EmpCollectionSummary>(this as EmpCollectionSummary, _$identity);

  /// Serializes this EmpCollectionSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmpCollectionSummary&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.amt, amt) || other.amt == amt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,employeeId,name,amt);

@override
String toString() {
  return 'EmpCollectionSummary(employeeId: $employeeId, name: $name, amt: $amt)';
}


}

/// @nodoc
abstract mixin class $EmpCollectionSummaryCopyWith<$Res>  {
  factory $EmpCollectionSummaryCopyWith(EmpCollectionSummary value, $Res Function(EmpCollectionSummary) _then) = _$EmpCollectionSummaryCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'employee_id') String employeeId,@JsonKey(name: 'name') String name,@JsonKey(name: 'Amt') double amt
});




}
/// @nodoc
class _$EmpCollectionSummaryCopyWithImpl<$Res>
    implements $EmpCollectionSummaryCopyWith<$Res> {
  _$EmpCollectionSummaryCopyWithImpl(this._self, this._then);

  final EmpCollectionSummary _self;
  final $Res Function(EmpCollectionSummary) _then;

/// Create a copy of EmpCollectionSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? employeeId = null,Object? name = null,Object? amt = null,}) {
  return _then(_self.copyWith(
employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,amt: null == amt ? _self.amt : amt // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [EmpCollectionSummary].
extension EmpCollectionSummaryPatterns on EmpCollectionSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmpCollectionSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmpCollectionSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmpCollectionSummary value)  $default,){
final _that = this;
switch (_that) {
case _EmpCollectionSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmpCollectionSummary value)?  $default,){
final _that = this;
switch (_that) {
case _EmpCollectionSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'employee_id')  String employeeId, @JsonKey(name: 'name')  String name, @JsonKey(name: 'Amt')  double amt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmpCollectionSummary() when $default != null:
return $default(_that.employeeId,_that.name,_that.amt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'employee_id')  String employeeId, @JsonKey(name: 'name')  String name, @JsonKey(name: 'Amt')  double amt)  $default,) {final _that = this;
switch (_that) {
case _EmpCollectionSummary():
return $default(_that.employeeId,_that.name,_that.amt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'employee_id')  String employeeId, @JsonKey(name: 'name')  String name, @JsonKey(name: 'Amt')  double amt)?  $default,) {final _that = this;
switch (_that) {
case _EmpCollectionSummary() when $default != null:
return $default(_that.employeeId,_that.name,_that.amt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EmpCollectionSummary implements EmpCollectionSummary {
  const _EmpCollectionSummary({@JsonKey(name: 'employee_id') this.employeeId = '', @JsonKey(name: 'name') this.name = '', @JsonKey(name: 'Amt') this.amt = 0.0});
  factory _EmpCollectionSummary.fromJson(Map<String, dynamic> json) => _$EmpCollectionSummaryFromJson(json);

@override@JsonKey(name: 'employee_id') final  String employeeId;
@override@JsonKey(name: 'name') final  String name;
@override@JsonKey(name: 'Amt') final  double amt;

/// Create a copy of EmpCollectionSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmpCollectionSummaryCopyWith<_EmpCollectionSummary> get copyWith => __$EmpCollectionSummaryCopyWithImpl<_EmpCollectionSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmpCollectionSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmpCollectionSummary&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.amt, amt) || other.amt == amt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,employeeId,name,amt);

@override
String toString() {
  return 'EmpCollectionSummary(employeeId: $employeeId, name: $name, amt: $amt)';
}


}

/// @nodoc
abstract mixin class _$EmpCollectionSummaryCopyWith<$Res> implements $EmpCollectionSummaryCopyWith<$Res> {
  factory _$EmpCollectionSummaryCopyWith(_EmpCollectionSummary value, $Res Function(_EmpCollectionSummary) _then) = __$EmpCollectionSummaryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'employee_id') String employeeId,@JsonKey(name: 'name') String name,@JsonKey(name: 'Amt') double amt
});




}
/// @nodoc
class __$EmpCollectionSummaryCopyWithImpl<$Res>
    implements _$EmpCollectionSummaryCopyWith<$Res> {
  __$EmpCollectionSummaryCopyWithImpl(this._self, this._then);

  final _EmpCollectionSummary _self;
  final $Res Function(_EmpCollectionSummary) _then;

/// Create a copy of EmpCollectionSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? employeeId = null,Object? name = null,Object? amt = null,}) {
  return _then(_EmpCollectionSummary(
employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,amt: null == amt ? _self.amt : amt // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
