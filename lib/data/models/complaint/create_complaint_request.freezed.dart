// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_complaint_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateComplaintRequest {

@JsonKey(name: 'customerId') String get customerId;@JsonKey(name: 'categoryId') int get categoryId;@JsonKey(name: 'subCategoryId') int? get subCategoryId;@JsonKey(name: 'description') String get description;@JsonKey(name: 'assignedEmployeeId') String? get assignedEmployeeId;@JsonKey(name: 'priority') String? get priority;@JsonKey(name: 'remarks') String? get remarks;
/// Create a copy of CreateComplaintRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateComplaintRequestCopyWith<CreateComplaintRequest> get copyWith => _$CreateComplaintRequestCopyWithImpl<CreateComplaintRequest>(this as CreateComplaintRequest, _$identity);

  /// Serializes this CreateComplaintRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateComplaintRequest&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.subCategoryId, subCategoryId) || other.subCategoryId == subCategoryId)&&(identical(other.description, description) || other.description == description)&&(identical(other.assignedEmployeeId, assignedEmployeeId) || other.assignedEmployeeId == assignedEmployeeId)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.remarks, remarks) || other.remarks == remarks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,customerId,categoryId,subCategoryId,description,assignedEmployeeId,priority,remarks);

@override
String toString() {
  return 'CreateComplaintRequest(customerId: $customerId, categoryId: $categoryId, subCategoryId: $subCategoryId, description: $description, assignedEmployeeId: $assignedEmployeeId, priority: $priority, remarks: $remarks)';
}


}

/// @nodoc
abstract mixin class $CreateComplaintRequestCopyWith<$Res>  {
  factory $CreateComplaintRequestCopyWith(CreateComplaintRequest value, $Res Function(CreateComplaintRequest) _then) = _$CreateComplaintRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'customerId') String customerId,@JsonKey(name: 'categoryId') int categoryId,@JsonKey(name: 'subCategoryId') int? subCategoryId,@JsonKey(name: 'description') String description,@JsonKey(name: 'assignedEmployeeId') String? assignedEmployeeId,@JsonKey(name: 'priority') String? priority,@JsonKey(name: 'remarks') String? remarks
});




}
/// @nodoc
class _$CreateComplaintRequestCopyWithImpl<$Res>
    implements $CreateComplaintRequestCopyWith<$Res> {
  _$CreateComplaintRequestCopyWithImpl(this._self, this._then);

  final CreateComplaintRequest _self;
  final $Res Function(CreateComplaintRequest) _then;

/// Create a copy of CreateComplaintRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? customerId = null,Object? categoryId = null,Object? subCategoryId = freezed,Object? description = null,Object? assignedEmployeeId = freezed,Object? priority = freezed,Object? remarks = freezed,}) {
  return _then(_self.copyWith(
customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,subCategoryId: freezed == subCategoryId ? _self.subCategoryId : subCategoryId // ignore: cast_nullable_to_non_nullable
as int?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,assignedEmployeeId: freezed == assignedEmployeeId ? _self.assignedEmployeeId : assignedEmployeeId // ignore: cast_nullable_to_non_nullable
as String?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String?,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateComplaintRequest].
extension CreateComplaintRequestPatterns on CreateComplaintRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateComplaintRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateComplaintRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateComplaintRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateComplaintRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateComplaintRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateComplaintRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'customerId')  String customerId, @JsonKey(name: 'categoryId')  int categoryId, @JsonKey(name: 'subCategoryId')  int? subCategoryId, @JsonKey(name: 'description')  String description, @JsonKey(name: 'assignedEmployeeId')  String? assignedEmployeeId, @JsonKey(name: 'priority')  String? priority, @JsonKey(name: 'remarks')  String? remarks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateComplaintRequest() when $default != null:
return $default(_that.customerId,_that.categoryId,_that.subCategoryId,_that.description,_that.assignedEmployeeId,_that.priority,_that.remarks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'customerId')  String customerId, @JsonKey(name: 'categoryId')  int categoryId, @JsonKey(name: 'subCategoryId')  int? subCategoryId, @JsonKey(name: 'description')  String description, @JsonKey(name: 'assignedEmployeeId')  String? assignedEmployeeId, @JsonKey(name: 'priority')  String? priority, @JsonKey(name: 'remarks')  String? remarks)  $default,) {final _that = this;
switch (_that) {
case _CreateComplaintRequest():
return $default(_that.customerId,_that.categoryId,_that.subCategoryId,_that.description,_that.assignedEmployeeId,_that.priority,_that.remarks);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'customerId')  String customerId, @JsonKey(name: 'categoryId')  int categoryId, @JsonKey(name: 'subCategoryId')  int? subCategoryId, @JsonKey(name: 'description')  String description, @JsonKey(name: 'assignedEmployeeId')  String? assignedEmployeeId, @JsonKey(name: 'priority')  String? priority, @JsonKey(name: 'remarks')  String? remarks)?  $default,) {final _that = this;
switch (_that) {
case _CreateComplaintRequest() when $default != null:
return $default(_that.customerId,_that.categoryId,_that.subCategoryId,_that.description,_that.assignedEmployeeId,_that.priority,_that.remarks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateComplaintRequest implements CreateComplaintRequest {
  const _CreateComplaintRequest({@JsonKey(name: 'customerId') required this.customerId, @JsonKey(name: 'categoryId') required this.categoryId, @JsonKey(name: 'subCategoryId') this.subCategoryId, @JsonKey(name: 'description') required this.description, @JsonKey(name: 'assignedEmployeeId') this.assignedEmployeeId, @JsonKey(name: 'priority') this.priority, @JsonKey(name: 'remarks') this.remarks});
  factory _CreateComplaintRequest.fromJson(Map<String, dynamic> json) => _$CreateComplaintRequestFromJson(json);

@override@JsonKey(name: 'customerId') final  String customerId;
@override@JsonKey(name: 'categoryId') final  int categoryId;
@override@JsonKey(name: 'subCategoryId') final  int? subCategoryId;
@override@JsonKey(name: 'description') final  String description;
@override@JsonKey(name: 'assignedEmployeeId') final  String? assignedEmployeeId;
@override@JsonKey(name: 'priority') final  String? priority;
@override@JsonKey(name: 'remarks') final  String? remarks;

/// Create a copy of CreateComplaintRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateComplaintRequestCopyWith<_CreateComplaintRequest> get copyWith => __$CreateComplaintRequestCopyWithImpl<_CreateComplaintRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateComplaintRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateComplaintRequest&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.subCategoryId, subCategoryId) || other.subCategoryId == subCategoryId)&&(identical(other.description, description) || other.description == description)&&(identical(other.assignedEmployeeId, assignedEmployeeId) || other.assignedEmployeeId == assignedEmployeeId)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.remarks, remarks) || other.remarks == remarks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,customerId,categoryId,subCategoryId,description,assignedEmployeeId,priority,remarks);

@override
String toString() {
  return 'CreateComplaintRequest(customerId: $customerId, categoryId: $categoryId, subCategoryId: $subCategoryId, description: $description, assignedEmployeeId: $assignedEmployeeId, priority: $priority, remarks: $remarks)';
}


}

/// @nodoc
abstract mixin class _$CreateComplaintRequestCopyWith<$Res> implements $CreateComplaintRequestCopyWith<$Res> {
  factory _$CreateComplaintRequestCopyWith(_CreateComplaintRequest value, $Res Function(_CreateComplaintRequest) _then) = __$CreateComplaintRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'customerId') String customerId,@JsonKey(name: 'categoryId') int categoryId,@JsonKey(name: 'subCategoryId') int? subCategoryId,@JsonKey(name: 'description') String description,@JsonKey(name: 'assignedEmployeeId') String? assignedEmployeeId,@JsonKey(name: 'priority') String? priority,@JsonKey(name: 'remarks') String? remarks
});




}
/// @nodoc
class __$CreateComplaintRequestCopyWithImpl<$Res>
    implements _$CreateComplaintRequestCopyWith<$Res> {
  __$CreateComplaintRequestCopyWithImpl(this._self, this._then);

  final _CreateComplaintRequest _self;
  final $Res Function(_CreateComplaintRequest) _then;

/// Create a copy of CreateComplaintRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? customerId = null,Object? categoryId = null,Object? subCategoryId = freezed,Object? description = null,Object? assignedEmployeeId = freezed,Object? priority = freezed,Object? remarks = freezed,}) {
  return _then(_CreateComplaintRequest(
customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,subCategoryId: freezed == subCategoryId ? _self.subCategoryId : subCategoryId // ignore: cast_nullable_to_non_nullable
as int?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,assignedEmployeeId: freezed == assignedEmployeeId ? _self.assignedEmployeeId : assignedEmployeeId // ignore: cast_nullable_to_non_nullable
as String?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String?,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
