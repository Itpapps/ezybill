// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'city.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$City {

@JsonKey(name: 'location_id') int get locationId;@JsonKey(name: 'location_name') String get locationName;@JsonKey(name: 'state_id') int get stateId;@JsonKey(name: 'dealer_id') int? get dealerId;@JsonKey(name: 'location_code') String? get locationCode;
/// Create a copy of City
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CityCopyWith<City> get copyWith => _$CityCopyWithImpl<City>(this as City, _$identity);

  /// Serializes this City to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is City&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.locationName, locationName) || other.locationName == locationName)&&(identical(other.stateId, stateId) || other.stateId == stateId)&&(identical(other.dealerId, dealerId) || other.dealerId == dealerId)&&(identical(other.locationCode, locationCode) || other.locationCode == locationCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,locationId,locationName,stateId,dealerId,locationCode);

@override
String toString() {
  return 'City(locationId: $locationId, locationName: $locationName, stateId: $stateId, dealerId: $dealerId, locationCode: $locationCode)';
}


}

/// @nodoc
abstract mixin class $CityCopyWith<$Res>  {
  factory $CityCopyWith(City value, $Res Function(City) _then) = _$CityCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'location_id') int locationId,@JsonKey(name: 'location_name') String locationName,@JsonKey(name: 'state_id') int stateId,@JsonKey(name: 'dealer_id') int? dealerId,@JsonKey(name: 'location_code') String? locationCode
});




}
/// @nodoc
class _$CityCopyWithImpl<$Res>
    implements $CityCopyWith<$Res> {
  _$CityCopyWithImpl(this._self, this._then);

  final City _self;
  final $Res Function(City) _then;

/// Create a copy of City
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? locationId = null,Object? locationName = null,Object? stateId = null,Object? dealerId = freezed,Object? locationCode = freezed,}) {
  return _then(_self.copyWith(
locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,locationName: null == locationName ? _self.locationName : locationName // ignore: cast_nullable_to_non_nullable
as String,stateId: null == stateId ? _self.stateId : stateId // ignore: cast_nullable_to_non_nullable
as int,dealerId: freezed == dealerId ? _self.dealerId : dealerId // ignore: cast_nullable_to_non_nullable
as int?,locationCode: freezed == locationCode ? _self.locationCode : locationCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [City].
extension CityPatterns on City {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _City value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _City() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _City value)  $default,){
final _that = this;
switch (_that) {
case _City():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _City value)?  $default,){
final _that = this;
switch (_that) {
case _City() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'location_id')  int locationId, @JsonKey(name: 'location_name')  String locationName, @JsonKey(name: 'state_id')  int stateId, @JsonKey(name: 'dealer_id')  int? dealerId, @JsonKey(name: 'location_code')  String? locationCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _City() when $default != null:
return $default(_that.locationId,_that.locationName,_that.stateId,_that.dealerId,_that.locationCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'location_id')  int locationId, @JsonKey(name: 'location_name')  String locationName, @JsonKey(name: 'state_id')  int stateId, @JsonKey(name: 'dealer_id')  int? dealerId, @JsonKey(name: 'location_code')  String? locationCode)  $default,) {final _that = this;
switch (_that) {
case _City():
return $default(_that.locationId,_that.locationName,_that.stateId,_that.dealerId,_that.locationCode);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'location_id')  int locationId, @JsonKey(name: 'location_name')  String locationName, @JsonKey(name: 'state_id')  int stateId, @JsonKey(name: 'dealer_id')  int? dealerId, @JsonKey(name: 'location_code')  String? locationCode)?  $default,) {final _that = this;
switch (_that) {
case _City() when $default != null:
return $default(_that.locationId,_that.locationName,_that.stateId,_that.dealerId,_that.locationCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _City implements City {
  const _City({@JsonKey(name: 'location_id') this.locationId = 0, @JsonKey(name: 'location_name') this.locationName = '', @JsonKey(name: 'state_id') this.stateId = 0, @JsonKey(name: 'dealer_id') this.dealerId, @JsonKey(name: 'location_code') this.locationCode});
  factory _City.fromJson(Map<String, dynamic> json) => _$CityFromJson(json);

@override@JsonKey(name: 'location_id') final  int locationId;
@override@JsonKey(name: 'location_name') final  String locationName;
@override@JsonKey(name: 'state_id') final  int stateId;
@override@JsonKey(name: 'dealer_id') final  int? dealerId;
@override@JsonKey(name: 'location_code') final  String? locationCode;

/// Create a copy of City
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CityCopyWith<_City> get copyWith => __$CityCopyWithImpl<_City>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _City&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.locationName, locationName) || other.locationName == locationName)&&(identical(other.stateId, stateId) || other.stateId == stateId)&&(identical(other.dealerId, dealerId) || other.dealerId == dealerId)&&(identical(other.locationCode, locationCode) || other.locationCode == locationCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,locationId,locationName,stateId,dealerId,locationCode);

@override
String toString() {
  return 'City(locationId: $locationId, locationName: $locationName, stateId: $stateId, dealerId: $dealerId, locationCode: $locationCode)';
}


}

/// @nodoc
abstract mixin class _$CityCopyWith<$Res> implements $CityCopyWith<$Res> {
  factory _$CityCopyWith(_City value, $Res Function(_City) _then) = __$CityCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'location_id') int locationId,@JsonKey(name: 'location_name') String locationName,@JsonKey(name: 'state_id') int stateId,@JsonKey(name: 'dealer_id') int? dealerId,@JsonKey(name: 'location_code') String? locationCode
});




}
/// @nodoc
class __$CityCopyWithImpl<$Res>
    implements _$CityCopyWith<$Res> {
  __$CityCopyWithImpl(this._self, this._then);

  final _City _self;
  final $Res Function(_City) _then;

/// Create a copy of City
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? locationId = null,Object? locationName = null,Object? stateId = null,Object? dealerId = freezed,Object? locationCode = freezed,}) {
  return _then(_City(
locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,locationName: null == locationName ? _self.locationName : locationName // ignore: cast_nullable_to_non_nullable
as String,stateId: null == stateId ? _self.stateId : stateId // ignore: cast_nullable_to_non_nullable
as int,dealerId: freezed == dealerId ? _self.dealerId : dealerId // ignore: cast_nullable_to_non_nullable
as int?,locationCode: freezed == locationCode ? _self.locationCode : locationCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
