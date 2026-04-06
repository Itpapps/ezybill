// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'id_type.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IdType {

@JsonKey(name: 'id_type_id') int get id;@JsonKey(name: 'type') String get name;
/// Create a copy of IdType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IdTypeCopyWith<IdType> get copyWith => _$IdTypeCopyWithImpl<IdType>(this as IdType, _$identity);

  /// Serializes this IdType to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IdType&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'IdType(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $IdTypeCopyWith<$Res>  {
  factory $IdTypeCopyWith(IdType value, $Res Function(IdType) _then) = _$IdTypeCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id_type_id') int id,@JsonKey(name: 'type') String name
});




}
/// @nodoc
class _$IdTypeCopyWithImpl<$Res>
    implements $IdTypeCopyWith<$Res> {
  _$IdTypeCopyWithImpl(this._self, this._then);

  final IdType _self;
  final $Res Function(IdType) _then;

/// Create a copy of IdType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [IdType].
extension IdTypePatterns on IdType {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IdType value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IdType() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IdType value)  $default,){
final _that = this;
switch (_that) {
case _IdType():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IdType value)?  $default,){
final _that = this;
switch (_that) {
case _IdType() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id_type_id')  int id, @JsonKey(name: 'type')  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IdType() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id_type_id')  int id, @JsonKey(name: 'type')  String name)  $default,) {final _that = this;
switch (_that) {
case _IdType():
return $default(_that.id,_that.name);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id_type_id')  int id, @JsonKey(name: 'type')  String name)?  $default,) {final _that = this;
switch (_that) {
case _IdType() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IdType implements IdType {
  const _IdType({@JsonKey(name: 'id_type_id') this.id = 0, @JsonKey(name: 'type') this.name = ''});
  factory _IdType.fromJson(Map<String, dynamic> json) => _$IdTypeFromJson(json);

@override@JsonKey(name: 'id_type_id') final  int id;
@override@JsonKey(name: 'type') final  String name;

/// Create a copy of IdType
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IdTypeCopyWith<_IdType> get copyWith => __$IdTypeCopyWithImpl<_IdType>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IdTypeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IdType&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'IdType(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$IdTypeCopyWith<$Res> implements $IdTypeCopyWith<$Res> {
  factory _$IdTypeCopyWith(_IdType value, $Res Function(_IdType) _then) = __$IdTypeCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id_type_id') int id,@JsonKey(name: 'type') String name
});




}
/// @nodoc
class __$IdTypeCopyWithImpl<$Res>
    implements _$IdTypeCopyWith<$Res> {
  __$IdTypeCopyWithImpl(this._self, this._then);

  final _IdType _self;
  final $Res Function(_IdType) _then;

/// Create a copy of IdType
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_IdType(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
