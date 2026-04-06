// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stb_replacement_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StbReplacementRequest {

@JsonKey(name: 'customerId') String get customerId;@JsonKey(name: 'serialNumber') String get serialNumber;@JsonKey(name: 'accountNumber') String get accountNumber;@JsonKey(name: 'replacementTypeId') int get replacementTypeId;@JsonKey(name: 'amount') double get amount;@JsonKey(name: 'receiptNumber') String get receiptNumber;@JsonKey(name: 'remarks') String get remarks;@JsonKey(name: 'replaceSerialNumber') String get replaceSerialNumber;@JsonKey(name: 'replaceVcNumber') String get replaceVcNumber;@JsonKey(name: 'isPermanentSurrender') int get isPermanentSurrender;@JsonKey(name: 'pairCondition') int get pairCondition;
/// Create a copy of StbReplacementRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StbReplacementRequestCopyWith<StbReplacementRequest> get copyWith => _$StbReplacementRequestCopyWithImpl<StbReplacementRequest>(this as StbReplacementRequest, _$identity);

  /// Serializes this StbReplacementRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StbReplacementRequest&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.replacementTypeId, replacementTypeId) || other.replacementTypeId == replacementTypeId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.receiptNumber, receiptNumber) || other.receiptNumber == receiptNumber)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&(identical(other.replaceSerialNumber, replaceSerialNumber) || other.replaceSerialNumber == replaceSerialNumber)&&(identical(other.replaceVcNumber, replaceVcNumber) || other.replaceVcNumber == replaceVcNumber)&&(identical(other.isPermanentSurrender, isPermanentSurrender) || other.isPermanentSurrender == isPermanentSurrender)&&(identical(other.pairCondition, pairCondition) || other.pairCondition == pairCondition));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,customerId,serialNumber,accountNumber,replacementTypeId,amount,receiptNumber,remarks,replaceSerialNumber,replaceVcNumber,isPermanentSurrender,pairCondition);

@override
String toString() {
  return 'StbReplacementRequest(customerId: $customerId, serialNumber: $serialNumber, accountNumber: $accountNumber, replacementTypeId: $replacementTypeId, amount: $amount, receiptNumber: $receiptNumber, remarks: $remarks, replaceSerialNumber: $replaceSerialNumber, replaceVcNumber: $replaceVcNumber, isPermanentSurrender: $isPermanentSurrender, pairCondition: $pairCondition)';
}


}

/// @nodoc
abstract mixin class $StbReplacementRequestCopyWith<$Res>  {
  factory $StbReplacementRequestCopyWith(StbReplacementRequest value, $Res Function(StbReplacementRequest) _then) = _$StbReplacementRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'customerId') String customerId,@JsonKey(name: 'serialNumber') String serialNumber,@JsonKey(name: 'accountNumber') String accountNumber,@JsonKey(name: 'replacementTypeId') int replacementTypeId,@JsonKey(name: 'amount') double amount,@JsonKey(name: 'receiptNumber') String receiptNumber,@JsonKey(name: 'remarks') String remarks,@JsonKey(name: 'replaceSerialNumber') String replaceSerialNumber,@JsonKey(name: 'replaceVcNumber') String replaceVcNumber,@JsonKey(name: 'isPermanentSurrender') int isPermanentSurrender,@JsonKey(name: 'pairCondition') int pairCondition
});




}
/// @nodoc
class _$StbReplacementRequestCopyWithImpl<$Res>
    implements $StbReplacementRequestCopyWith<$Res> {
  _$StbReplacementRequestCopyWithImpl(this._self, this._then);

  final StbReplacementRequest _self;
  final $Res Function(StbReplacementRequest) _then;

/// Create a copy of StbReplacementRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? customerId = null,Object? serialNumber = null,Object? accountNumber = null,Object? replacementTypeId = null,Object? amount = null,Object? receiptNumber = null,Object? remarks = null,Object? replaceSerialNumber = null,Object? replaceVcNumber = null,Object? isPermanentSurrender = null,Object? pairCondition = null,}) {
  return _then(_self.copyWith(
customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,serialNumber: null == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String,accountNumber: null == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String,replacementTypeId: null == replacementTypeId ? _self.replacementTypeId : replacementTypeId // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,receiptNumber: null == receiptNumber ? _self.receiptNumber : receiptNumber // ignore: cast_nullable_to_non_nullable
as String,remarks: null == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String,replaceSerialNumber: null == replaceSerialNumber ? _self.replaceSerialNumber : replaceSerialNumber // ignore: cast_nullable_to_non_nullable
as String,replaceVcNumber: null == replaceVcNumber ? _self.replaceVcNumber : replaceVcNumber // ignore: cast_nullable_to_non_nullable
as String,isPermanentSurrender: null == isPermanentSurrender ? _self.isPermanentSurrender : isPermanentSurrender // ignore: cast_nullable_to_non_nullable
as int,pairCondition: null == pairCondition ? _self.pairCondition : pairCondition // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [StbReplacementRequest].
extension StbReplacementRequestPatterns on StbReplacementRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StbReplacementRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StbReplacementRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StbReplacementRequest value)  $default,){
final _that = this;
switch (_that) {
case _StbReplacementRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StbReplacementRequest value)?  $default,){
final _that = this;
switch (_that) {
case _StbReplacementRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'customerId')  String customerId, @JsonKey(name: 'serialNumber')  String serialNumber, @JsonKey(name: 'accountNumber')  String accountNumber, @JsonKey(name: 'replacementTypeId')  int replacementTypeId, @JsonKey(name: 'amount')  double amount, @JsonKey(name: 'receiptNumber')  String receiptNumber, @JsonKey(name: 'remarks')  String remarks, @JsonKey(name: 'replaceSerialNumber')  String replaceSerialNumber, @JsonKey(name: 'replaceVcNumber')  String replaceVcNumber, @JsonKey(name: 'isPermanentSurrender')  int isPermanentSurrender, @JsonKey(name: 'pairCondition')  int pairCondition)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StbReplacementRequest() when $default != null:
return $default(_that.customerId,_that.serialNumber,_that.accountNumber,_that.replacementTypeId,_that.amount,_that.receiptNumber,_that.remarks,_that.replaceSerialNumber,_that.replaceVcNumber,_that.isPermanentSurrender,_that.pairCondition);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'customerId')  String customerId, @JsonKey(name: 'serialNumber')  String serialNumber, @JsonKey(name: 'accountNumber')  String accountNumber, @JsonKey(name: 'replacementTypeId')  int replacementTypeId, @JsonKey(name: 'amount')  double amount, @JsonKey(name: 'receiptNumber')  String receiptNumber, @JsonKey(name: 'remarks')  String remarks, @JsonKey(name: 'replaceSerialNumber')  String replaceSerialNumber, @JsonKey(name: 'replaceVcNumber')  String replaceVcNumber, @JsonKey(name: 'isPermanentSurrender')  int isPermanentSurrender, @JsonKey(name: 'pairCondition')  int pairCondition)  $default,) {final _that = this;
switch (_that) {
case _StbReplacementRequest():
return $default(_that.customerId,_that.serialNumber,_that.accountNumber,_that.replacementTypeId,_that.amount,_that.receiptNumber,_that.remarks,_that.replaceSerialNumber,_that.replaceVcNumber,_that.isPermanentSurrender,_that.pairCondition);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'customerId')  String customerId, @JsonKey(name: 'serialNumber')  String serialNumber, @JsonKey(name: 'accountNumber')  String accountNumber, @JsonKey(name: 'replacementTypeId')  int replacementTypeId, @JsonKey(name: 'amount')  double amount, @JsonKey(name: 'receiptNumber')  String receiptNumber, @JsonKey(name: 'remarks')  String remarks, @JsonKey(name: 'replaceSerialNumber')  String replaceSerialNumber, @JsonKey(name: 'replaceVcNumber')  String replaceVcNumber, @JsonKey(name: 'isPermanentSurrender')  int isPermanentSurrender, @JsonKey(name: 'pairCondition')  int pairCondition)?  $default,) {final _that = this;
switch (_that) {
case _StbReplacementRequest() when $default != null:
return $default(_that.customerId,_that.serialNumber,_that.accountNumber,_that.replacementTypeId,_that.amount,_that.receiptNumber,_that.remarks,_that.replaceSerialNumber,_that.replaceVcNumber,_that.isPermanentSurrender,_that.pairCondition);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StbReplacementRequest implements StbReplacementRequest {
  const _StbReplacementRequest({@JsonKey(name: 'customerId') required this.customerId, @JsonKey(name: 'serialNumber') required this.serialNumber, @JsonKey(name: 'accountNumber') required this.accountNumber, @JsonKey(name: 'replacementTypeId') required this.replacementTypeId, @JsonKey(name: 'amount') required this.amount, @JsonKey(name: 'receiptNumber') required this.receiptNumber, @JsonKey(name: 'remarks') required this.remarks, @JsonKey(name: 'replaceSerialNumber') required this.replaceSerialNumber, @JsonKey(name: 'replaceVcNumber') required this.replaceVcNumber, @JsonKey(name: 'isPermanentSurrender') required this.isPermanentSurrender, @JsonKey(name: 'pairCondition') required this.pairCondition});
  factory _StbReplacementRequest.fromJson(Map<String, dynamic> json) => _$StbReplacementRequestFromJson(json);

@override@JsonKey(name: 'customerId') final  String customerId;
@override@JsonKey(name: 'serialNumber') final  String serialNumber;
@override@JsonKey(name: 'accountNumber') final  String accountNumber;
@override@JsonKey(name: 'replacementTypeId') final  int replacementTypeId;
@override@JsonKey(name: 'amount') final  double amount;
@override@JsonKey(name: 'receiptNumber') final  String receiptNumber;
@override@JsonKey(name: 'remarks') final  String remarks;
@override@JsonKey(name: 'replaceSerialNumber') final  String replaceSerialNumber;
@override@JsonKey(name: 'replaceVcNumber') final  String replaceVcNumber;
@override@JsonKey(name: 'isPermanentSurrender') final  int isPermanentSurrender;
@override@JsonKey(name: 'pairCondition') final  int pairCondition;

/// Create a copy of StbReplacementRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StbReplacementRequestCopyWith<_StbReplacementRequest> get copyWith => __$StbReplacementRequestCopyWithImpl<_StbReplacementRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StbReplacementRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StbReplacementRequest&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.replacementTypeId, replacementTypeId) || other.replacementTypeId == replacementTypeId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.receiptNumber, receiptNumber) || other.receiptNumber == receiptNumber)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&(identical(other.replaceSerialNumber, replaceSerialNumber) || other.replaceSerialNumber == replaceSerialNumber)&&(identical(other.replaceVcNumber, replaceVcNumber) || other.replaceVcNumber == replaceVcNumber)&&(identical(other.isPermanentSurrender, isPermanentSurrender) || other.isPermanentSurrender == isPermanentSurrender)&&(identical(other.pairCondition, pairCondition) || other.pairCondition == pairCondition));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,customerId,serialNumber,accountNumber,replacementTypeId,amount,receiptNumber,remarks,replaceSerialNumber,replaceVcNumber,isPermanentSurrender,pairCondition);

@override
String toString() {
  return 'StbReplacementRequest(customerId: $customerId, serialNumber: $serialNumber, accountNumber: $accountNumber, replacementTypeId: $replacementTypeId, amount: $amount, receiptNumber: $receiptNumber, remarks: $remarks, replaceSerialNumber: $replaceSerialNumber, replaceVcNumber: $replaceVcNumber, isPermanentSurrender: $isPermanentSurrender, pairCondition: $pairCondition)';
}


}

/// @nodoc
abstract mixin class _$StbReplacementRequestCopyWith<$Res> implements $StbReplacementRequestCopyWith<$Res> {
  factory _$StbReplacementRequestCopyWith(_StbReplacementRequest value, $Res Function(_StbReplacementRequest) _then) = __$StbReplacementRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'customerId') String customerId,@JsonKey(name: 'serialNumber') String serialNumber,@JsonKey(name: 'accountNumber') String accountNumber,@JsonKey(name: 'replacementTypeId') int replacementTypeId,@JsonKey(name: 'amount') double amount,@JsonKey(name: 'receiptNumber') String receiptNumber,@JsonKey(name: 'remarks') String remarks,@JsonKey(name: 'replaceSerialNumber') String replaceSerialNumber,@JsonKey(name: 'replaceVcNumber') String replaceVcNumber,@JsonKey(name: 'isPermanentSurrender') int isPermanentSurrender,@JsonKey(name: 'pairCondition') int pairCondition
});




}
/// @nodoc
class __$StbReplacementRequestCopyWithImpl<$Res>
    implements _$StbReplacementRequestCopyWith<$Res> {
  __$StbReplacementRequestCopyWithImpl(this._self, this._then);

  final _StbReplacementRequest _self;
  final $Res Function(_StbReplacementRequest) _then;

/// Create a copy of StbReplacementRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? customerId = null,Object? serialNumber = null,Object? accountNumber = null,Object? replacementTypeId = null,Object? amount = null,Object? receiptNumber = null,Object? remarks = null,Object? replaceSerialNumber = null,Object? replaceVcNumber = null,Object? isPermanentSurrender = null,Object? pairCondition = null,}) {
  return _then(_StbReplacementRequest(
customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,serialNumber: null == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String,accountNumber: null == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String,replacementTypeId: null == replacementTypeId ? _self.replacementTypeId : replacementTypeId // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,receiptNumber: null == receiptNumber ? _self.receiptNumber : receiptNumber // ignore: cast_nullable_to_non_nullable
as String,remarks: null == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String,replaceSerialNumber: null == replaceSerialNumber ? _self.replaceSerialNumber : replaceSerialNumber // ignore: cast_nullable_to_non_nullable
as String,replaceVcNumber: null == replaceVcNumber ? _self.replaceVcNumber : replaceVcNumber // ignore: cast_nullable_to_non_nullable
as String,isPermanentSurrender: null == isPermanentSurrender ? _self.isPermanentSurrender : isPermanentSurrender // ignore: cast_nullable_to_non_nullable
as int,pairCondition: null == pairCondition ? _self.pairCondition : pairCondition // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
