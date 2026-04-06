// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mandal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Mandal {

@JsonKey(name: 'district_id') int get districtId;@JsonKey(name: 'mandal_id') int get mandalId;@JsonKey(name: 'mandal_name') String get mandalName;
/// Create a copy of Mandal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MandalCopyWith<Mandal> get copyWith => _$MandalCopyWithImpl<Mandal>(this as Mandal, _$identity);

  /// Serializes this Mandal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Mandal&&(identical(other.districtId, districtId) || other.districtId == districtId)&&(identical(other.mandalId, mandalId) || other.mandalId == mandalId)&&(identical(other.mandalName, mandalName) || other.mandalName == mandalName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,districtId,mandalId,mandalName);

@override
String toString() {
  return 'Mandal(districtId: $districtId, mandalId: $mandalId, mandalName: $mandalName)';
}


}

/// @nodoc
abstract mixin class $MandalCopyWith<$Res>  {
  factory $MandalCopyWith(Mandal value, $Res Function(Mandal) _then) = _$MandalCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'district_id') int districtId,@JsonKey(name: 'mandal_id') int mandalId,@JsonKey(name: 'mandal_name') String mandalName
});




}
/// @nodoc
class _$MandalCopyWithImpl<$Res>
    implements $MandalCopyWith<$Res> {
  _$MandalCopyWithImpl(this._self, this._then);

  final Mandal _self;
  final $Res Function(Mandal) _then;

/// Create a copy of Mandal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? districtId = null,Object? mandalId = null,Object? mandalName = null,}) {
  return _then(_self.copyWith(
districtId: null == districtId ? _self.districtId : districtId // ignore: cast_nullable_to_non_nullable
as int,mandalId: null == mandalId ? _self.mandalId : mandalId // ignore: cast_nullable_to_non_nullable
as int,mandalName: null == mandalName ? _self.mandalName : mandalName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Mandal].
extension MandalPatterns on Mandal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Mandal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Mandal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Mandal value)  $default,){
final _that = this;
switch (_that) {
case _Mandal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Mandal value)?  $default,){
final _that = this;
switch (_that) {
case _Mandal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'district_id')  int districtId, @JsonKey(name: 'mandal_id')  int mandalId, @JsonKey(name: 'mandal_name')  String mandalName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Mandal() when $default != null:
return $default(_that.districtId,_that.mandalId,_that.mandalName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'district_id')  int districtId, @JsonKey(name: 'mandal_id')  int mandalId, @JsonKey(name: 'mandal_name')  String mandalName)  $default,) {final _that = this;
switch (_that) {
case _Mandal():
return $default(_that.districtId,_that.mandalId,_that.mandalName);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'district_id')  int districtId, @JsonKey(name: 'mandal_id')  int mandalId, @JsonKey(name: 'mandal_name')  String mandalName)?  $default,) {final _that = this;
switch (_that) {
case _Mandal() when $default != null:
return $default(_that.districtId,_that.mandalId,_that.mandalName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Mandal implements Mandal {
  const _Mandal({@JsonKey(name: 'district_id') this.districtId = 0, @JsonKey(name: 'mandal_id') this.mandalId = 0, @JsonKey(name: 'mandal_name') this.mandalName = ''});
  factory _Mandal.fromJson(Map<String, dynamic> json) => _$MandalFromJson(json);

@override@JsonKey(name: 'district_id') final  int districtId;
@override@JsonKey(name: 'mandal_id') final  int mandalId;
@override@JsonKey(name: 'mandal_name') final  String mandalName;

/// Create a copy of Mandal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MandalCopyWith<_Mandal> get copyWith => __$MandalCopyWithImpl<_Mandal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MandalToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Mandal&&(identical(other.districtId, districtId) || other.districtId == districtId)&&(identical(other.mandalId, mandalId) || other.mandalId == mandalId)&&(identical(other.mandalName, mandalName) || other.mandalName == mandalName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,districtId,mandalId,mandalName);

@override
String toString() {
  return 'Mandal(districtId: $districtId, mandalId: $mandalId, mandalName: $mandalName)';
}


}

/// @nodoc
abstract mixin class _$MandalCopyWith<$Res> implements $MandalCopyWith<$Res> {
  factory _$MandalCopyWith(_Mandal value, $Res Function(_Mandal) _then) = __$MandalCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'district_id') int districtId,@JsonKey(name: 'mandal_id') int mandalId,@JsonKey(name: 'mandal_name') String mandalName
});




}
/// @nodoc
class __$MandalCopyWithImpl<$Res>
    implements _$MandalCopyWith<$Res> {
  __$MandalCopyWithImpl(this._self, this._then);

  final _Mandal _self;
  final $Res Function(_Mandal) _then;

/// Create a copy of Mandal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? districtId = null,Object? mandalId = null,Object? mandalName = null,}) {
  return _then(_Mandal(
districtId: null == districtId ? _self.districtId : districtId // ignore: cast_nullable_to_non_nullable
as int,mandalId: null == mandalId ? _self.mandalId : mandalId // ignore: cast_nullable_to_non_nullable
as int,mandalName: null == mandalName ? _self.mandalName : mandalName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
