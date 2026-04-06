// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service_employee.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ServiceEmployee {

@JsonKey(name: 'employeeId') String get employeeId;@JsonKey(name: 'employeeName') String get employeeName;@JsonKey(name: 'phone') String? get phone;@JsonKey(name: 'serviceArea') String? get serviceArea;
/// Create a copy of ServiceEmployee
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServiceEmployeeCopyWith<ServiceEmployee> get copyWith => _$ServiceEmployeeCopyWithImpl<ServiceEmployee>(this as ServiceEmployee, _$identity);

  /// Serializes this ServiceEmployee to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServiceEmployee&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.employeeName, employeeName) || other.employeeName == employeeName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.serviceArea, serviceArea) || other.serviceArea == serviceArea));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,employeeId,employeeName,phone,serviceArea);

@override
String toString() {
  return 'ServiceEmployee(employeeId: $employeeId, employeeName: $employeeName, phone: $phone, serviceArea: $serviceArea)';
}


}

/// @nodoc
abstract mixin class $ServiceEmployeeCopyWith<$Res>  {
  factory $ServiceEmployeeCopyWith(ServiceEmployee value, $Res Function(ServiceEmployee) _then) = _$ServiceEmployeeCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'employeeId') String employeeId,@JsonKey(name: 'employeeName') String employeeName,@JsonKey(name: 'phone') String? phone,@JsonKey(name: 'serviceArea') String? serviceArea
});




}
/// @nodoc
class _$ServiceEmployeeCopyWithImpl<$Res>
    implements $ServiceEmployeeCopyWith<$Res> {
  _$ServiceEmployeeCopyWithImpl(this._self, this._then);

  final ServiceEmployee _self;
  final $Res Function(ServiceEmployee) _then;

/// Create a copy of ServiceEmployee
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? employeeId = null,Object? employeeName = null,Object? phone = freezed,Object? serviceArea = freezed,}) {
  return _then(_self.copyWith(
employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,employeeName: null == employeeName ? _self.employeeName : employeeName // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,serviceArea: freezed == serviceArea ? _self.serviceArea : serviceArea // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ServiceEmployee].
extension ServiceEmployeePatterns on ServiceEmployee {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServiceEmployee value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServiceEmployee() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServiceEmployee value)  $default,){
final _that = this;
switch (_that) {
case _ServiceEmployee():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServiceEmployee value)?  $default,){
final _that = this;
switch (_that) {
case _ServiceEmployee() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'employeeId')  String employeeId, @JsonKey(name: 'employeeName')  String employeeName, @JsonKey(name: 'phone')  String? phone, @JsonKey(name: 'serviceArea')  String? serviceArea)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServiceEmployee() when $default != null:
return $default(_that.employeeId,_that.employeeName,_that.phone,_that.serviceArea);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'employeeId')  String employeeId, @JsonKey(name: 'employeeName')  String employeeName, @JsonKey(name: 'phone')  String? phone, @JsonKey(name: 'serviceArea')  String? serviceArea)  $default,) {final _that = this;
switch (_that) {
case _ServiceEmployee():
return $default(_that.employeeId,_that.employeeName,_that.phone,_that.serviceArea);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'employeeId')  String employeeId, @JsonKey(name: 'employeeName')  String employeeName, @JsonKey(name: 'phone')  String? phone, @JsonKey(name: 'serviceArea')  String? serviceArea)?  $default,) {final _that = this;
switch (_that) {
case _ServiceEmployee() when $default != null:
return $default(_that.employeeId,_that.employeeName,_that.phone,_that.serviceArea);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ServiceEmployee implements ServiceEmployee {
  const _ServiceEmployee({@JsonKey(name: 'employeeId') required this.employeeId, @JsonKey(name: 'employeeName') required this.employeeName, @JsonKey(name: 'phone') this.phone, @JsonKey(name: 'serviceArea') this.serviceArea});
  factory _ServiceEmployee.fromJson(Map<String, dynamic> json) => _$ServiceEmployeeFromJson(json);

@override@JsonKey(name: 'employeeId') final  String employeeId;
@override@JsonKey(name: 'employeeName') final  String employeeName;
@override@JsonKey(name: 'phone') final  String? phone;
@override@JsonKey(name: 'serviceArea') final  String? serviceArea;

/// Create a copy of ServiceEmployee
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServiceEmployeeCopyWith<_ServiceEmployee> get copyWith => __$ServiceEmployeeCopyWithImpl<_ServiceEmployee>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ServiceEmployeeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServiceEmployee&&(identical(other.employeeId, employeeId) || other.employeeId == employeeId)&&(identical(other.employeeName, employeeName) || other.employeeName == employeeName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.serviceArea, serviceArea) || other.serviceArea == serviceArea));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,employeeId,employeeName,phone,serviceArea);

@override
String toString() {
  return 'ServiceEmployee(employeeId: $employeeId, employeeName: $employeeName, phone: $phone, serviceArea: $serviceArea)';
}


}

/// @nodoc
abstract mixin class _$ServiceEmployeeCopyWith<$Res> implements $ServiceEmployeeCopyWith<$Res> {
  factory _$ServiceEmployeeCopyWith(_ServiceEmployee value, $Res Function(_ServiceEmployee) _then) = __$ServiceEmployeeCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'employeeId') String employeeId,@JsonKey(name: 'employeeName') String employeeName,@JsonKey(name: 'phone') String? phone,@JsonKey(name: 'serviceArea') String? serviceArea
});




}
/// @nodoc
class __$ServiceEmployeeCopyWithImpl<$Res>
    implements _$ServiceEmployeeCopyWith<$Res> {
  __$ServiceEmployeeCopyWithImpl(this._self, this._then);

  final _ServiceEmployee _self;
  final $Res Function(_ServiceEmployee) _then;

/// Create a copy of ServiceEmployee
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? employeeId = null,Object? employeeName = null,Object? phone = freezed,Object? serviceArea = freezed,}) {
  return _then(_ServiceEmployee(
employeeId: null == employeeId ? _self.employeeId : employeeId // ignore: cast_nullable_to_non_nullable
as String,employeeName: null == employeeName ? _self.employeeName : employeeName // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,serviceArea: freezed == serviceArea ? _self.serviceArea : serviceArea // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
