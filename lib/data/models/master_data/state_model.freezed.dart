// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'state_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StateModel {

@JsonKey(name: 'id') int get id;@JsonKey(name: 'name') String get name;@JsonKey(name: 'country_code') String get countryCode;@JsonKey(name: 'abbrev') String? get abbrev;
/// Create a copy of StateModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StateModelCopyWith<StateModel> get copyWith => _$StateModelCopyWithImpl<StateModel>(this as StateModel, _$identity);

  /// Serializes this StateModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StateModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.abbrev, abbrev) || other.abbrev == abbrev));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,countryCode,abbrev);

@override
String toString() {
  return 'StateModel(id: $id, name: $name, countryCode: $countryCode, abbrev: $abbrev)';
}


}

/// @nodoc
abstract mixin class $StateModelCopyWith<$Res>  {
  factory $StateModelCopyWith(StateModel value, $Res Function(StateModel) _then) = _$StateModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') int id,@JsonKey(name: 'name') String name,@JsonKey(name: 'country_code') String countryCode,@JsonKey(name: 'abbrev') String? abbrev
});




}
/// @nodoc
class _$StateModelCopyWithImpl<$Res>
    implements $StateModelCopyWith<$Res> {
  _$StateModelCopyWithImpl(this._self, this._then);

  final StateModel _self;
  final $Res Function(StateModel) _then;

/// Create a copy of StateModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? countryCode = null,Object? abbrev = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,abbrev: freezed == abbrev ? _self.abbrev : abbrev // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StateModel].
extension StateModelPatterns on StateModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StateModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StateModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StateModel value)  $default,){
final _that = this;
switch (_that) {
case _StateModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StateModel value)?  $default,){
final _that = this;
switch (_that) {
case _StateModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  int id, @JsonKey(name: 'name')  String name, @JsonKey(name: 'country_code')  String countryCode, @JsonKey(name: 'abbrev')  String? abbrev)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StateModel() when $default != null:
return $default(_that.id,_that.name,_that.countryCode,_that.abbrev);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  int id, @JsonKey(name: 'name')  String name, @JsonKey(name: 'country_code')  String countryCode, @JsonKey(name: 'abbrev')  String? abbrev)  $default,) {final _that = this;
switch (_that) {
case _StateModel():
return $default(_that.id,_that.name,_that.countryCode,_that.abbrev);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  int id, @JsonKey(name: 'name')  String name, @JsonKey(name: 'country_code')  String countryCode, @JsonKey(name: 'abbrev')  String? abbrev)?  $default,) {final _that = this;
switch (_that) {
case _StateModel() when $default != null:
return $default(_that.id,_that.name,_that.countryCode,_that.abbrev);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StateModel implements StateModel {
  const _StateModel({@JsonKey(name: 'id') this.id = 0, @JsonKey(name: 'name') this.name = '', @JsonKey(name: 'country_code') this.countryCode = '', @JsonKey(name: 'abbrev') this.abbrev});
  factory _StateModel.fromJson(Map<String, dynamic> json) => _$StateModelFromJson(json);

@override@JsonKey(name: 'id') final  int id;
@override@JsonKey(name: 'name') final  String name;
@override@JsonKey(name: 'country_code') final  String countryCode;
@override@JsonKey(name: 'abbrev') final  String? abbrev;

/// Create a copy of StateModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StateModelCopyWith<_StateModel> get copyWith => __$StateModelCopyWithImpl<_StateModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StateModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StateModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.abbrev, abbrev) || other.abbrev == abbrev));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,countryCode,abbrev);

@override
String toString() {
  return 'StateModel(id: $id, name: $name, countryCode: $countryCode, abbrev: $abbrev)';
}


}

/// @nodoc
abstract mixin class _$StateModelCopyWith<$Res> implements $StateModelCopyWith<$Res> {
  factory _$StateModelCopyWith(_StateModel value, $Res Function(_StateModel) _then) = __$StateModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') int id,@JsonKey(name: 'name') String name,@JsonKey(name: 'country_code') String countryCode,@JsonKey(name: 'abbrev') String? abbrev
});




}
/// @nodoc
class __$StateModelCopyWithImpl<$Res>
    implements _$StateModelCopyWith<$Res> {
  __$StateModelCopyWithImpl(this._self, this._then);

  final _StateModel _self;
  final $Res Function(_StateModel) _then;

/// Create a copy of StateModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? countryCode = null,Object? abbrev = freezed,}) {
  return _then(_StateModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,abbrev: freezed == abbrev ? _self.abbrev : abbrev // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
