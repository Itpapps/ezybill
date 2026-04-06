// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deactivation_reason.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeactivationReason {

@JsonKey(name: 'reasonId') int get reasonId;@JsonKey(name: 'reasonName') String get reasonName;@JsonKey(name: 'display_name') String get displayName;@JsonKey(name: 'act_deact_reason_id') int get actDeactReasonId;@JsonKey(name: 'global_reason') int get globalReason;@JsonKey(name: 'disable_for_dpo') int get disableForDpo;
/// Create a copy of DeactivationReason
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeactivationReasonCopyWith<DeactivationReason> get copyWith => _$DeactivationReasonCopyWithImpl<DeactivationReason>(this as DeactivationReason, _$identity);

  /// Serializes this DeactivationReason to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeactivationReason&&(identical(other.reasonId, reasonId) || other.reasonId == reasonId)&&(identical(other.reasonName, reasonName) || other.reasonName == reasonName)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.actDeactReasonId, actDeactReasonId) || other.actDeactReasonId == actDeactReasonId)&&(identical(other.globalReason, globalReason) || other.globalReason == globalReason)&&(identical(other.disableForDpo, disableForDpo) || other.disableForDpo == disableForDpo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reasonId,reasonName,displayName,actDeactReasonId,globalReason,disableForDpo);

@override
String toString() {
  return 'DeactivationReason(reasonId: $reasonId, reasonName: $reasonName, displayName: $displayName, actDeactReasonId: $actDeactReasonId, globalReason: $globalReason, disableForDpo: $disableForDpo)';
}


}

/// @nodoc
abstract mixin class $DeactivationReasonCopyWith<$Res>  {
  factory $DeactivationReasonCopyWith(DeactivationReason value, $Res Function(DeactivationReason) _then) = _$DeactivationReasonCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'reasonId') int reasonId,@JsonKey(name: 'reasonName') String reasonName,@JsonKey(name: 'display_name') String displayName,@JsonKey(name: 'act_deact_reason_id') int actDeactReasonId,@JsonKey(name: 'global_reason') int globalReason,@JsonKey(name: 'disable_for_dpo') int disableForDpo
});




}
/// @nodoc
class _$DeactivationReasonCopyWithImpl<$Res>
    implements $DeactivationReasonCopyWith<$Res> {
  _$DeactivationReasonCopyWithImpl(this._self, this._then);

  final DeactivationReason _self;
  final $Res Function(DeactivationReason) _then;

/// Create a copy of DeactivationReason
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reasonId = null,Object? reasonName = null,Object? displayName = null,Object? actDeactReasonId = null,Object? globalReason = null,Object? disableForDpo = null,}) {
  return _then(_self.copyWith(
reasonId: null == reasonId ? _self.reasonId : reasonId // ignore: cast_nullable_to_non_nullable
as int,reasonName: null == reasonName ? _self.reasonName : reasonName // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,actDeactReasonId: null == actDeactReasonId ? _self.actDeactReasonId : actDeactReasonId // ignore: cast_nullable_to_non_nullable
as int,globalReason: null == globalReason ? _self.globalReason : globalReason // ignore: cast_nullable_to_non_nullable
as int,disableForDpo: null == disableForDpo ? _self.disableForDpo : disableForDpo // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DeactivationReason].
extension DeactivationReasonPatterns on DeactivationReason {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeactivationReason value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeactivationReason() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeactivationReason value)  $default,){
final _that = this;
switch (_that) {
case _DeactivationReason():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeactivationReason value)?  $default,){
final _that = this;
switch (_that) {
case _DeactivationReason() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'reasonId')  int reasonId, @JsonKey(name: 'reasonName')  String reasonName, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'act_deact_reason_id')  int actDeactReasonId, @JsonKey(name: 'global_reason')  int globalReason, @JsonKey(name: 'disable_for_dpo')  int disableForDpo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeactivationReason() when $default != null:
return $default(_that.reasonId,_that.reasonName,_that.displayName,_that.actDeactReasonId,_that.globalReason,_that.disableForDpo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'reasonId')  int reasonId, @JsonKey(name: 'reasonName')  String reasonName, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'act_deact_reason_id')  int actDeactReasonId, @JsonKey(name: 'global_reason')  int globalReason, @JsonKey(name: 'disable_for_dpo')  int disableForDpo)  $default,) {final _that = this;
switch (_that) {
case _DeactivationReason():
return $default(_that.reasonId,_that.reasonName,_that.displayName,_that.actDeactReasonId,_that.globalReason,_that.disableForDpo);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'reasonId')  int reasonId, @JsonKey(name: 'reasonName')  String reasonName, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'act_deact_reason_id')  int actDeactReasonId, @JsonKey(name: 'global_reason')  int globalReason, @JsonKey(name: 'disable_for_dpo')  int disableForDpo)?  $default,) {final _that = this;
switch (_that) {
case _DeactivationReason() when $default != null:
return $default(_that.reasonId,_that.reasonName,_that.displayName,_that.actDeactReasonId,_that.globalReason,_that.disableForDpo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeactivationReason implements DeactivationReason {
  const _DeactivationReason({@JsonKey(name: 'reasonId') this.reasonId = 0, @JsonKey(name: 'reasonName') this.reasonName = '', @JsonKey(name: 'display_name') this.displayName = '', @JsonKey(name: 'act_deact_reason_id') this.actDeactReasonId = 0, @JsonKey(name: 'global_reason') this.globalReason = 0, @JsonKey(name: 'disable_for_dpo') this.disableForDpo = 0});
  factory _DeactivationReason.fromJson(Map<String, dynamic> json) => _$DeactivationReasonFromJson(json);

@override@JsonKey(name: 'reasonId') final  int reasonId;
@override@JsonKey(name: 'reasonName') final  String reasonName;
@override@JsonKey(name: 'display_name') final  String displayName;
@override@JsonKey(name: 'act_deact_reason_id') final  int actDeactReasonId;
@override@JsonKey(name: 'global_reason') final  int globalReason;
@override@JsonKey(name: 'disable_for_dpo') final  int disableForDpo;

/// Create a copy of DeactivationReason
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeactivationReasonCopyWith<_DeactivationReason> get copyWith => __$DeactivationReasonCopyWithImpl<_DeactivationReason>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeactivationReasonToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeactivationReason&&(identical(other.reasonId, reasonId) || other.reasonId == reasonId)&&(identical(other.reasonName, reasonName) || other.reasonName == reasonName)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.actDeactReasonId, actDeactReasonId) || other.actDeactReasonId == actDeactReasonId)&&(identical(other.globalReason, globalReason) || other.globalReason == globalReason)&&(identical(other.disableForDpo, disableForDpo) || other.disableForDpo == disableForDpo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reasonId,reasonName,displayName,actDeactReasonId,globalReason,disableForDpo);

@override
String toString() {
  return 'DeactivationReason(reasonId: $reasonId, reasonName: $reasonName, displayName: $displayName, actDeactReasonId: $actDeactReasonId, globalReason: $globalReason, disableForDpo: $disableForDpo)';
}


}

/// @nodoc
abstract mixin class _$DeactivationReasonCopyWith<$Res> implements $DeactivationReasonCopyWith<$Res> {
  factory _$DeactivationReasonCopyWith(_DeactivationReason value, $Res Function(_DeactivationReason) _then) = __$DeactivationReasonCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'reasonId') int reasonId,@JsonKey(name: 'reasonName') String reasonName,@JsonKey(name: 'display_name') String displayName,@JsonKey(name: 'act_deact_reason_id') int actDeactReasonId,@JsonKey(name: 'global_reason') int globalReason,@JsonKey(name: 'disable_for_dpo') int disableForDpo
});




}
/// @nodoc
class __$DeactivationReasonCopyWithImpl<$Res>
    implements _$DeactivationReasonCopyWith<$Res> {
  __$DeactivationReasonCopyWithImpl(this._self, this._then);

  final _DeactivationReason _self;
  final $Res Function(_DeactivationReason) _then;

/// Create a copy of DeactivationReason
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reasonId = null,Object? reasonName = null,Object? displayName = null,Object? actDeactReasonId = null,Object? globalReason = null,Object? disableForDpo = null,}) {
  return _then(_DeactivationReason(
reasonId: null == reasonId ? _self.reasonId : reasonId // ignore: cast_nullable_to_non_nullable
as int,reasonName: null == reasonName ? _self.reasonName : reasonName // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,actDeactReasonId: null == actDeactReasonId ? _self.actDeactReasonId : actDeactReasonId // ignore: cast_nullable_to_non_nullable
as int,globalReason: null == globalReason ? _self.globalReason : globalReason // ignore: cast_nullable_to_non_nullable
as int,disableForDpo: null == disableForDpo ? _self.disableForDpo : disableForDpo // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
