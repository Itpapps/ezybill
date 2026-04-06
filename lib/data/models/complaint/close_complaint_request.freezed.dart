// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'close_complaint_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CloseComplaintRequest {

@JsonKey(name: 'complaintId') String get complaintId;@JsonKey(name: 'ticketNumber') String? get ticketNumber;@JsonKey(name: 'status') String get status;@JsonKey(name: 'comment') String? get comment;@JsonKey(name: 'assignedemp') String? get assignedemp;@JsonKey(name: 'closer_ticket_type_id') String? get closerTicketTypeId;@JsonKey(name: 'closer_reason_id') String? get closerReasonId;
/// Create a copy of CloseComplaintRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CloseComplaintRequestCopyWith<CloseComplaintRequest> get copyWith => _$CloseComplaintRequestCopyWithImpl<CloseComplaintRequest>(this as CloseComplaintRequest, _$identity);

  /// Serializes this CloseComplaintRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CloseComplaintRequest&&(identical(other.complaintId, complaintId) || other.complaintId == complaintId)&&(identical(other.ticketNumber, ticketNumber) || other.ticketNumber == ticketNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.assignedemp, assignedemp) || other.assignedemp == assignedemp)&&(identical(other.closerTicketTypeId, closerTicketTypeId) || other.closerTicketTypeId == closerTicketTypeId)&&(identical(other.closerReasonId, closerReasonId) || other.closerReasonId == closerReasonId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,complaintId,ticketNumber,status,comment,assignedemp,closerTicketTypeId,closerReasonId);

@override
String toString() {
  return 'CloseComplaintRequest(complaintId: $complaintId, ticketNumber: $ticketNumber, status: $status, comment: $comment, assignedemp: $assignedemp, closerTicketTypeId: $closerTicketTypeId, closerReasonId: $closerReasonId)';
}


}

/// @nodoc
abstract mixin class $CloseComplaintRequestCopyWith<$Res>  {
  factory $CloseComplaintRequestCopyWith(CloseComplaintRequest value, $Res Function(CloseComplaintRequest) _then) = _$CloseComplaintRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'complaintId') String complaintId,@JsonKey(name: 'ticketNumber') String? ticketNumber,@JsonKey(name: 'status') String status,@JsonKey(name: 'comment') String? comment,@JsonKey(name: 'assignedemp') String? assignedemp,@JsonKey(name: 'closer_ticket_type_id') String? closerTicketTypeId,@JsonKey(name: 'closer_reason_id') String? closerReasonId
});




}
/// @nodoc
class _$CloseComplaintRequestCopyWithImpl<$Res>
    implements $CloseComplaintRequestCopyWith<$Res> {
  _$CloseComplaintRequestCopyWithImpl(this._self, this._then);

  final CloseComplaintRequest _self;
  final $Res Function(CloseComplaintRequest) _then;

/// Create a copy of CloseComplaintRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? complaintId = null,Object? ticketNumber = freezed,Object? status = null,Object? comment = freezed,Object? assignedemp = freezed,Object? closerTicketTypeId = freezed,Object? closerReasonId = freezed,}) {
  return _then(_self.copyWith(
complaintId: null == complaintId ? _self.complaintId : complaintId // ignore: cast_nullable_to_non_nullable
as String,ticketNumber: freezed == ticketNumber ? _self.ticketNumber : ticketNumber // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,assignedemp: freezed == assignedemp ? _self.assignedemp : assignedemp // ignore: cast_nullable_to_non_nullable
as String?,closerTicketTypeId: freezed == closerTicketTypeId ? _self.closerTicketTypeId : closerTicketTypeId // ignore: cast_nullable_to_non_nullable
as String?,closerReasonId: freezed == closerReasonId ? _self.closerReasonId : closerReasonId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CloseComplaintRequest].
extension CloseComplaintRequestPatterns on CloseComplaintRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CloseComplaintRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CloseComplaintRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CloseComplaintRequest value)  $default,){
final _that = this;
switch (_that) {
case _CloseComplaintRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CloseComplaintRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CloseComplaintRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'complaintId')  String complaintId, @JsonKey(name: 'ticketNumber')  String? ticketNumber, @JsonKey(name: 'status')  String status, @JsonKey(name: 'comment')  String? comment, @JsonKey(name: 'assignedemp')  String? assignedemp, @JsonKey(name: 'closer_ticket_type_id')  String? closerTicketTypeId, @JsonKey(name: 'closer_reason_id')  String? closerReasonId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CloseComplaintRequest() when $default != null:
return $default(_that.complaintId,_that.ticketNumber,_that.status,_that.comment,_that.assignedemp,_that.closerTicketTypeId,_that.closerReasonId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'complaintId')  String complaintId, @JsonKey(name: 'ticketNumber')  String? ticketNumber, @JsonKey(name: 'status')  String status, @JsonKey(name: 'comment')  String? comment, @JsonKey(name: 'assignedemp')  String? assignedemp, @JsonKey(name: 'closer_ticket_type_id')  String? closerTicketTypeId, @JsonKey(name: 'closer_reason_id')  String? closerReasonId)  $default,) {final _that = this;
switch (_that) {
case _CloseComplaintRequest():
return $default(_that.complaintId,_that.ticketNumber,_that.status,_that.comment,_that.assignedemp,_that.closerTicketTypeId,_that.closerReasonId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'complaintId')  String complaintId, @JsonKey(name: 'ticketNumber')  String? ticketNumber, @JsonKey(name: 'status')  String status, @JsonKey(name: 'comment')  String? comment, @JsonKey(name: 'assignedemp')  String? assignedemp, @JsonKey(name: 'closer_ticket_type_id')  String? closerTicketTypeId, @JsonKey(name: 'closer_reason_id')  String? closerReasonId)?  $default,) {final _that = this;
switch (_that) {
case _CloseComplaintRequest() when $default != null:
return $default(_that.complaintId,_that.ticketNumber,_that.status,_that.comment,_that.assignedemp,_that.closerTicketTypeId,_that.closerReasonId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CloseComplaintRequest implements CloseComplaintRequest {
  const _CloseComplaintRequest({@JsonKey(name: 'complaintId') required this.complaintId, @JsonKey(name: 'ticketNumber') this.ticketNumber, @JsonKey(name: 'status') required this.status, @JsonKey(name: 'comment') this.comment, @JsonKey(name: 'assignedemp') this.assignedemp, @JsonKey(name: 'closer_ticket_type_id') this.closerTicketTypeId, @JsonKey(name: 'closer_reason_id') this.closerReasonId});
  factory _CloseComplaintRequest.fromJson(Map<String, dynamic> json) => _$CloseComplaintRequestFromJson(json);

@override@JsonKey(name: 'complaintId') final  String complaintId;
@override@JsonKey(name: 'ticketNumber') final  String? ticketNumber;
@override@JsonKey(name: 'status') final  String status;
@override@JsonKey(name: 'comment') final  String? comment;
@override@JsonKey(name: 'assignedemp') final  String? assignedemp;
@override@JsonKey(name: 'closer_ticket_type_id') final  String? closerTicketTypeId;
@override@JsonKey(name: 'closer_reason_id') final  String? closerReasonId;

/// Create a copy of CloseComplaintRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CloseComplaintRequestCopyWith<_CloseComplaintRequest> get copyWith => __$CloseComplaintRequestCopyWithImpl<_CloseComplaintRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CloseComplaintRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CloseComplaintRequest&&(identical(other.complaintId, complaintId) || other.complaintId == complaintId)&&(identical(other.ticketNumber, ticketNumber) || other.ticketNumber == ticketNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.assignedemp, assignedemp) || other.assignedemp == assignedemp)&&(identical(other.closerTicketTypeId, closerTicketTypeId) || other.closerTicketTypeId == closerTicketTypeId)&&(identical(other.closerReasonId, closerReasonId) || other.closerReasonId == closerReasonId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,complaintId,ticketNumber,status,comment,assignedemp,closerTicketTypeId,closerReasonId);

@override
String toString() {
  return 'CloseComplaintRequest(complaintId: $complaintId, ticketNumber: $ticketNumber, status: $status, comment: $comment, assignedemp: $assignedemp, closerTicketTypeId: $closerTicketTypeId, closerReasonId: $closerReasonId)';
}


}

/// @nodoc
abstract mixin class _$CloseComplaintRequestCopyWith<$Res> implements $CloseComplaintRequestCopyWith<$Res> {
  factory _$CloseComplaintRequestCopyWith(_CloseComplaintRequest value, $Res Function(_CloseComplaintRequest) _then) = __$CloseComplaintRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'complaintId') String complaintId,@JsonKey(name: 'ticketNumber') String? ticketNumber,@JsonKey(name: 'status') String status,@JsonKey(name: 'comment') String? comment,@JsonKey(name: 'assignedemp') String? assignedemp,@JsonKey(name: 'closer_ticket_type_id') String? closerTicketTypeId,@JsonKey(name: 'closer_reason_id') String? closerReasonId
});




}
/// @nodoc
class __$CloseComplaintRequestCopyWithImpl<$Res>
    implements _$CloseComplaintRequestCopyWith<$Res> {
  __$CloseComplaintRequestCopyWithImpl(this._self, this._then);

  final _CloseComplaintRequest _self;
  final $Res Function(_CloseComplaintRequest) _then;

/// Create a copy of CloseComplaintRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? complaintId = null,Object? ticketNumber = freezed,Object? status = null,Object? comment = freezed,Object? assignedemp = freezed,Object? closerTicketTypeId = freezed,Object? closerReasonId = freezed,}) {
  return _then(_CloseComplaintRequest(
complaintId: null == complaintId ? _self.complaintId : complaintId // ignore: cast_nullable_to_non_nullable
as String,ticketNumber: freezed == ticketNumber ? _self.ticketNumber : ticketNumber // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,assignedemp: freezed == assignedemp ? _self.assignedemp : assignedemp // ignore: cast_nullable_to_non_nullable
as String?,closerTicketTypeId: freezed == closerTicketTypeId ? _self.closerTicketTypeId : closerTicketTypeId // ignore: cast_nullable_to_non_nullable
as String?,closerReasonId: freezed == closerReasonId ? _self.closerReasonId : closerReasonId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
