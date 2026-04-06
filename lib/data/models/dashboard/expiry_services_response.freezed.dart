// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expiry_services_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExpiryServicesResponse {

@JsonKey(name: 'status_code') int get statusCode;@JsonKey(name: 'status_msg') String get statusMsg;@JsonKey(name: 'getExpiryServicesList') List<ExpiryDateCount> get expiryServicesList;
/// Create a copy of ExpiryServicesResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpiryServicesResponseCopyWith<ExpiryServicesResponse> get copyWith => _$ExpiryServicesResponseCopyWithImpl<ExpiryServicesResponse>(this as ExpiryServicesResponse, _$identity);

  /// Serializes this ExpiryServicesResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpiryServicesResponse&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.statusMsg, statusMsg) || other.statusMsg == statusMsg)&&const DeepCollectionEquality().equals(other.expiryServicesList, expiryServicesList));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,statusCode,statusMsg,const DeepCollectionEquality().hash(expiryServicesList));

@override
String toString() {
  return 'ExpiryServicesResponse(statusCode: $statusCode, statusMsg: $statusMsg, expiryServicesList: $expiryServicesList)';
}


}

/// @nodoc
abstract mixin class $ExpiryServicesResponseCopyWith<$Res>  {
  factory $ExpiryServicesResponseCopyWith(ExpiryServicesResponse value, $Res Function(ExpiryServicesResponse) _then) = _$ExpiryServicesResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'status_code') int statusCode,@JsonKey(name: 'status_msg') String statusMsg,@JsonKey(name: 'getExpiryServicesList') List<ExpiryDateCount> expiryServicesList
});




}
/// @nodoc
class _$ExpiryServicesResponseCopyWithImpl<$Res>
    implements $ExpiryServicesResponseCopyWith<$Res> {
  _$ExpiryServicesResponseCopyWithImpl(this._self, this._then);

  final ExpiryServicesResponse _self;
  final $Res Function(ExpiryServicesResponse) _then;

/// Create a copy of ExpiryServicesResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? statusCode = null,Object? statusMsg = null,Object? expiryServicesList = null,}) {
  return _then(_self.copyWith(
statusCode: null == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int,statusMsg: null == statusMsg ? _self.statusMsg : statusMsg // ignore: cast_nullable_to_non_nullable
as String,expiryServicesList: null == expiryServicesList ? _self.expiryServicesList : expiryServicesList // ignore: cast_nullable_to_non_nullable
as List<ExpiryDateCount>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExpiryServicesResponse].
extension ExpiryServicesResponsePatterns on ExpiryServicesResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpiryServicesResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpiryServicesResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpiryServicesResponse value)  $default,){
final _that = this;
switch (_that) {
case _ExpiryServicesResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpiryServicesResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ExpiryServicesResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'status_code')  int statusCode, @JsonKey(name: 'status_msg')  String statusMsg, @JsonKey(name: 'getExpiryServicesList')  List<ExpiryDateCount> expiryServicesList)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpiryServicesResponse() when $default != null:
return $default(_that.statusCode,_that.statusMsg,_that.expiryServicesList);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'status_code')  int statusCode, @JsonKey(name: 'status_msg')  String statusMsg, @JsonKey(name: 'getExpiryServicesList')  List<ExpiryDateCount> expiryServicesList)  $default,) {final _that = this;
switch (_that) {
case _ExpiryServicesResponse():
return $default(_that.statusCode,_that.statusMsg,_that.expiryServicesList);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'status_code')  int statusCode, @JsonKey(name: 'status_msg')  String statusMsg, @JsonKey(name: 'getExpiryServicesList')  List<ExpiryDateCount> expiryServicesList)?  $default,) {final _that = this;
switch (_that) {
case _ExpiryServicesResponse() when $default != null:
return $default(_that.statusCode,_that.statusMsg,_that.expiryServicesList);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExpiryServicesResponse implements ExpiryServicesResponse {
  const _ExpiryServicesResponse({@JsonKey(name: 'status_code') this.statusCode = 0, @JsonKey(name: 'status_msg') this.statusMsg = '', @JsonKey(name: 'getExpiryServicesList') final  List<ExpiryDateCount> expiryServicesList = const []}): _expiryServicesList = expiryServicesList;
  factory _ExpiryServicesResponse.fromJson(Map<String, dynamic> json) => _$ExpiryServicesResponseFromJson(json);

@override@JsonKey(name: 'status_code') final  int statusCode;
@override@JsonKey(name: 'status_msg') final  String statusMsg;
 final  List<ExpiryDateCount> _expiryServicesList;
@override@JsonKey(name: 'getExpiryServicesList') List<ExpiryDateCount> get expiryServicesList {
  if (_expiryServicesList is EqualUnmodifiableListView) return _expiryServicesList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_expiryServicesList);
}


/// Create a copy of ExpiryServicesResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpiryServicesResponseCopyWith<_ExpiryServicesResponse> get copyWith => __$ExpiryServicesResponseCopyWithImpl<_ExpiryServicesResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpiryServicesResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpiryServicesResponse&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.statusMsg, statusMsg) || other.statusMsg == statusMsg)&&const DeepCollectionEquality().equals(other._expiryServicesList, _expiryServicesList));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,statusCode,statusMsg,const DeepCollectionEquality().hash(_expiryServicesList));

@override
String toString() {
  return 'ExpiryServicesResponse(statusCode: $statusCode, statusMsg: $statusMsg, expiryServicesList: $expiryServicesList)';
}


}

/// @nodoc
abstract mixin class _$ExpiryServicesResponseCopyWith<$Res> implements $ExpiryServicesResponseCopyWith<$Res> {
  factory _$ExpiryServicesResponseCopyWith(_ExpiryServicesResponse value, $Res Function(_ExpiryServicesResponse) _then) = __$ExpiryServicesResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'status_code') int statusCode,@JsonKey(name: 'status_msg') String statusMsg,@JsonKey(name: 'getExpiryServicesList') List<ExpiryDateCount> expiryServicesList
});




}
/// @nodoc
class __$ExpiryServicesResponseCopyWithImpl<$Res>
    implements _$ExpiryServicesResponseCopyWith<$Res> {
  __$ExpiryServicesResponseCopyWithImpl(this._self, this._then);

  final _ExpiryServicesResponse _self;
  final $Res Function(_ExpiryServicesResponse) _then;

/// Create a copy of ExpiryServicesResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? statusCode = null,Object? statusMsg = null,Object? expiryServicesList = null,}) {
  return _then(_ExpiryServicesResponse(
statusCode: null == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int,statusMsg: null == statusMsg ? _self.statusMsg : statusMsg // ignore: cast_nullable_to_non_nullable
as String,expiryServicesList: null == expiryServicesList ? _self._expiryServicesList : expiryServicesList // ignore: cast_nullable_to_non_nullable
as List<ExpiryDateCount>,
  ));
}


}


/// @nodoc
mixin _$ExpiryDateCount {

@JsonKey(name: 'date') String get date;@JsonKey(name: 'stb_count') int get stbCount;
/// Create a copy of ExpiryDateCount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpiryDateCountCopyWith<ExpiryDateCount> get copyWith => _$ExpiryDateCountCopyWithImpl<ExpiryDateCount>(this as ExpiryDateCount, _$identity);

  /// Serializes this ExpiryDateCount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpiryDateCount&&(identical(other.date, date) || other.date == date)&&(identical(other.stbCount, stbCount) || other.stbCount == stbCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,stbCount);

@override
String toString() {
  return 'ExpiryDateCount(date: $date, stbCount: $stbCount)';
}


}

/// @nodoc
abstract mixin class $ExpiryDateCountCopyWith<$Res>  {
  factory $ExpiryDateCountCopyWith(ExpiryDateCount value, $Res Function(ExpiryDateCount) _then) = _$ExpiryDateCountCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'date') String date,@JsonKey(name: 'stb_count') int stbCount
});




}
/// @nodoc
class _$ExpiryDateCountCopyWithImpl<$Res>
    implements $ExpiryDateCountCopyWith<$Res> {
  _$ExpiryDateCountCopyWithImpl(this._self, this._then);

  final ExpiryDateCount _self;
  final $Res Function(ExpiryDateCount) _then;

/// Create a copy of ExpiryDateCount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? stbCount = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,stbCount: null == stbCount ? _self.stbCount : stbCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ExpiryDateCount].
extension ExpiryDateCountPatterns on ExpiryDateCount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpiryDateCount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpiryDateCount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpiryDateCount value)  $default,){
final _that = this;
switch (_that) {
case _ExpiryDateCount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpiryDateCount value)?  $default,){
final _that = this;
switch (_that) {
case _ExpiryDateCount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'date')  String date, @JsonKey(name: 'stb_count')  int stbCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpiryDateCount() when $default != null:
return $default(_that.date,_that.stbCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'date')  String date, @JsonKey(name: 'stb_count')  int stbCount)  $default,) {final _that = this;
switch (_that) {
case _ExpiryDateCount():
return $default(_that.date,_that.stbCount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'date')  String date, @JsonKey(name: 'stb_count')  int stbCount)?  $default,) {final _that = this;
switch (_that) {
case _ExpiryDateCount() when $default != null:
return $default(_that.date,_that.stbCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExpiryDateCount implements ExpiryDateCount {
  const _ExpiryDateCount({@JsonKey(name: 'date') this.date = '', @JsonKey(name: 'stb_count') this.stbCount = 0});
  factory _ExpiryDateCount.fromJson(Map<String, dynamic> json) => _$ExpiryDateCountFromJson(json);

@override@JsonKey(name: 'date') final  String date;
@override@JsonKey(name: 'stb_count') final  int stbCount;

/// Create a copy of ExpiryDateCount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpiryDateCountCopyWith<_ExpiryDateCount> get copyWith => __$ExpiryDateCountCopyWithImpl<_ExpiryDateCount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpiryDateCountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpiryDateCount&&(identical(other.date, date) || other.date == date)&&(identical(other.stbCount, stbCount) || other.stbCount == stbCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,stbCount);

@override
String toString() {
  return 'ExpiryDateCount(date: $date, stbCount: $stbCount)';
}


}

/// @nodoc
abstract mixin class _$ExpiryDateCountCopyWith<$Res> implements $ExpiryDateCountCopyWith<$Res> {
  factory _$ExpiryDateCountCopyWith(_ExpiryDateCount value, $Res Function(_ExpiryDateCount) _then) = __$ExpiryDateCountCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'date') String date,@JsonKey(name: 'stb_count') int stbCount
});




}
/// @nodoc
class __$ExpiryDateCountCopyWithImpl<$Res>
    implements _$ExpiryDateCountCopyWith<$Res> {
  __$ExpiryDateCountCopyWithImpl(this._self, this._then);

  final _ExpiryDateCount _self;
  final $Res Function(_ExpiryDateCount) _then;

/// Create a copy of ExpiryDateCount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? stbCount = null,}) {
  return _then(_ExpiryDateCount(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,stbCount: null == stbCount ? _self.stbCount : stbCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
