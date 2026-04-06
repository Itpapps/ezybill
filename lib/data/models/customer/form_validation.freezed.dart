// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'form_validation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FormValidation {

@JsonKey(name: 'column_name') String get columnName;@JsonKey(name: 'is_mandatory') String get isMandatory;
/// Create a copy of FormValidation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FormValidationCopyWith<FormValidation> get copyWith => _$FormValidationCopyWithImpl<FormValidation>(this as FormValidation, _$identity);

  /// Serializes this FormValidation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FormValidation&&(identical(other.columnName, columnName) || other.columnName == columnName)&&(identical(other.isMandatory, isMandatory) || other.isMandatory == isMandatory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,columnName,isMandatory);

@override
String toString() {
  return 'FormValidation(columnName: $columnName, isMandatory: $isMandatory)';
}


}

/// @nodoc
abstract mixin class $FormValidationCopyWith<$Res>  {
  factory $FormValidationCopyWith(FormValidation value, $Res Function(FormValidation) _then) = _$FormValidationCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'column_name') String columnName,@JsonKey(name: 'is_mandatory') String isMandatory
});




}
/// @nodoc
class _$FormValidationCopyWithImpl<$Res>
    implements $FormValidationCopyWith<$Res> {
  _$FormValidationCopyWithImpl(this._self, this._then);

  final FormValidation _self;
  final $Res Function(FormValidation) _then;

/// Create a copy of FormValidation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? columnName = null,Object? isMandatory = null,}) {
  return _then(_self.copyWith(
columnName: null == columnName ? _self.columnName : columnName // ignore: cast_nullable_to_non_nullable
as String,isMandatory: null == isMandatory ? _self.isMandatory : isMandatory // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FormValidation].
extension FormValidationPatterns on FormValidation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FormValidation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FormValidation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FormValidation value)  $default,){
final _that = this;
switch (_that) {
case _FormValidation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FormValidation value)?  $default,){
final _that = this;
switch (_that) {
case _FormValidation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'column_name')  String columnName, @JsonKey(name: 'is_mandatory')  String isMandatory)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FormValidation() when $default != null:
return $default(_that.columnName,_that.isMandatory);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'column_name')  String columnName, @JsonKey(name: 'is_mandatory')  String isMandatory)  $default,) {final _that = this;
switch (_that) {
case _FormValidation():
return $default(_that.columnName,_that.isMandatory);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'column_name')  String columnName, @JsonKey(name: 'is_mandatory')  String isMandatory)?  $default,) {final _that = this;
switch (_that) {
case _FormValidation() when $default != null:
return $default(_that.columnName,_that.isMandatory);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FormValidation implements FormValidation {
  const _FormValidation({@JsonKey(name: 'column_name') required this.columnName, @JsonKey(name: 'is_mandatory') required this.isMandatory});
  factory _FormValidation.fromJson(Map<String, dynamic> json) => _$FormValidationFromJson(json);

@override@JsonKey(name: 'column_name') final  String columnName;
@override@JsonKey(name: 'is_mandatory') final  String isMandatory;

/// Create a copy of FormValidation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FormValidationCopyWith<_FormValidation> get copyWith => __$FormValidationCopyWithImpl<_FormValidation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FormValidationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FormValidation&&(identical(other.columnName, columnName) || other.columnName == columnName)&&(identical(other.isMandatory, isMandatory) || other.isMandatory == isMandatory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,columnName,isMandatory);

@override
String toString() {
  return 'FormValidation(columnName: $columnName, isMandatory: $isMandatory)';
}


}

/// @nodoc
abstract mixin class _$FormValidationCopyWith<$Res> implements $FormValidationCopyWith<$Res> {
  factory _$FormValidationCopyWith(_FormValidation value, $Res Function(_FormValidation) _then) = __$FormValidationCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'column_name') String columnName,@JsonKey(name: 'is_mandatory') String isMandatory
});




}
/// @nodoc
class __$FormValidationCopyWithImpl<$Res>
    implements _$FormValidationCopyWith<$Res> {
  __$FormValidationCopyWithImpl(this._self, this._then);

  final _FormValidation _self;
  final $Res Function(_FormValidation) _then;

/// Create a copy of FormValidation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? columnName = null,Object? isMandatory = null,}) {
  return _then(_FormValidation(
columnName: null == columnName ? _self.columnName : columnName // ignore: cast_nullable_to_non_nullable
as String,isMandatory: null == isMandatory ? _self.isMandatory : isMandatory // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
