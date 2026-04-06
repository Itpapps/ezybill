// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lco_payment_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LcoPaymentRequest {

@JsonKey(name: 'authToken') String get authToken;@JsonKey(name: 'lcoEmployeeId') String get lcoEmployeeId;@JsonKey(name: 'lcoBillingId') String get lcoBillingId;@JsonKey(name: 'receiptNumber') String get receiptNumber;@JsonKey(name: 'amount') double get amount;@JsonKey(name: 'mode') String get mode;@JsonKey(name: 'adjustFlag') int get adjustFlag;@JsonKey(name: 'dabitCredit') String get dabitCredit;@JsonKey(name: 'accept') int get accept;@JsonKey(name: 'chequeDdnumber') String? get chequeDdnumber;@JsonKey(name: 'chequeDate') String? get chequeDate;@JsonKey(name: 'bank') String? get bank;@JsonKey(name: 'branch') String? get branch;@JsonKey(name: 'remarks') String? get remarks;
/// Create a copy of LcoPaymentRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LcoPaymentRequestCopyWith<LcoPaymentRequest> get copyWith => _$LcoPaymentRequestCopyWithImpl<LcoPaymentRequest>(this as LcoPaymentRequest, _$identity);

  /// Serializes this LcoPaymentRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LcoPaymentRequest&&(identical(other.authToken, authToken) || other.authToken == authToken)&&(identical(other.lcoEmployeeId, lcoEmployeeId) || other.lcoEmployeeId == lcoEmployeeId)&&(identical(other.lcoBillingId, lcoBillingId) || other.lcoBillingId == lcoBillingId)&&(identical(other.receiptNumber, receiptNumber) || other.receiptNumber == receiptNumber)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.adjustFlag, adjustFlag) || other.adjustFlag == adjustFlag)&&(identical(other.dabitCredit, dabitCredit) || other.dabitCredit == dabitCredit)&&(identical(other.accept, accept) || other.accept == accept)&&(identical(other.chequeDdnumber, chequeDdnumber) || other.chequeDdnumber == chequeDdnumber)&&(identical(other.chequeDate, chequeDate) || other.chequeDate == chequeDate)&&(identical(other.bank, bank) || other.bank == bank)&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.remarks, remarks) || other.remarks == remarks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,authToken,lcoEmployeeId,lcoBillingId,receiptNumber,amount,mode,adjustFlag,dabitCredit,accept,chequeDdnumber,chequeDate,bank,branch,remarks);

@override
String toString() {
  return 'LcoPaymentRequest(authToken: $authToken, lcoEmployeeId: $lcoEmployeeId, lcoBillingId: $lcoBillingId, receiptNumber: $receiptNumber, amount: $amount, mode: $mode, adjustFlag: $adjustFlag, dabitCredit: $dabitCredit, accept: $accept, chequeDdnumber: $chequeDdnumber, chequeDate: $chequeDate, bank: $bank, branch: $branch, remarks: $remarks)';
}


}

/// @nodoc
abstract mixin class $LcoPaymentRequestCopyWith<$Res>  {
  factory $LcoPaymentRequestCopyWith(LcoPaymentRequest value, $Res Function(LcoPaymentRequest) _then) = _$LcoPaymentRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'authToken') String authToken,@JsonKey(name: 'lcoEmployeeId') String lcoEmployeeId,@JsonKey(name: 'lcoBillingId') String lcoBillingId,@JsonKey(name: 'receiptNumber') String receiptNumber,@JsonKey(name: 'amount') double amount,@JsonKey(name: 'mode') String mode,@JsonKey(name: 'adjustFlag') int adjustFlag,@JsonKey(name: 'dabitCredit') String dabitCredit,@JsonKey(name: 'accept') int accept,@JsonKey(name: 'chequeDdnumber') String? chequeDdnumber,@JsonKey(name: 'chequeDate') String? chequeDate,@JsonKey(name: 'bank') String? bank,@JsonKey(name: 'branch') String? branch,@JsonKey(name: 'remarks') String? remarks
});




}
/// @nodoc
class _$LcoPaymentRequestCopyWithImpl<$Res>
    implements $LcoPaymentRequestCopyWith<$Res> {
  _$LcoPaymentRequestCopyWithImpl(this._self, this._then);

  final LcoPaymentRequest _self;
  final $Res Function(LcoPaymentRequest) _then;

/// Create a copy of LcoPaymentRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? authToken = null,Object? lcoEmployeeId = null,Object? lcoBillingId = null,Object? receiptNumber = null,Object? amount = null,Object? mode = null,Object? adjustFlag = null,Object? dabitCredit = null,Object? accept = null,Object? chequeDdnumber = freezed,Object? chequeDate = freezed,Object? bank = freezed,Object? branch = freezed,Object? remarks = freezed,}) {
  return _then(_self.copyWith(
authToken: null == authToken ? _self.authToken : authToken // ignore: cast_nullable_to_non_nullable
as String,lcoEmployeeId: null == lcoEmployeeId ? _self.lcoEmployeeId : lcoEmployeeId // ignore: cast_nullable_to_non_nullable
as String,lcoBillingId: null == lcoBillingId ? _self.lcoBillingId : lcoBillingId // ignore: cast_nullable_to_non_nullable
as String,receiptNumber: null == receiptNumber ? _self.receiptNumber : receiptNumber // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as String,adjustFlag: null == adjustFlag ? _self.adjustFlag : adjustFlag // ignore: cast_nullable_to_non_nullable
as int,dabitCredit: null == dabitCredit ? _self.dabitCredit : dabitCredit // ignore: cast_nullable_to_non_nullable
as String,accept: null == accept ? _self.accept : accept // ignore: cast_nullable_to_non_nullable
as int,chequeDdnumber: freezed == chequeDdnumber ? _self.chequeDdnumber : chequeDdnumber // ignore: cast_nullable_to_non_nullable
as String?,chequeDate: freezed == chequeDate ? _self.chequeDate : chequeDate // ignore: cast_nullable_to_non_nullable
as String?,bank: freezed == bank ? _self.bank : bank // ignore: cast_nullable_to_non_nullable
as String?,branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String?,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LcoPaymentRequest].
extension LcoPaymentRequestPatterns on LcoPaymentRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LcoPaymentRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LcoPaymentRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LcoPaymentRequest value)  $default,){
final _that = this;
switch (_that) {
case _LcoPaymentRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LcoPaymentRequest value)?  $default,){
final _that = this;
switch (_that) {
case _LcoPaymentRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'authToken')  String authToken, @JsonKey(name: 'lcoEmployeeId')  String lcoEmployeeId, @JsonKey(name: 'lcoBillingId')  String lcoBillingId, @JsonKey(name: 'receiptNumber')  String receiptNumber, @JsonKey(name: 'amount')  double amount, @JsonKey(name: 'mode')  String mode, @JsonKey(name: 'adjustFlag')  int adjustFlag, @JsonKey(name: 'dabitCredit')  String dabitCredit, @JsonKey(name: 'accept')  int accept, @JsonKey(name: 'chequeDdnumber')  String? chequeDdnumber, @JsonKey(name: 'chequeDate')  String? chequeDate, @JsonKey(name: 'bank')  String? bank, @JsonKey(name: 'branch')  String? branch, @JsonKey(name: 'remarks')  String? remarks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LcoPaymentRequest() when $default != null:
return $default(_that.authToken,_that.lcoEmployeeId,_that.lcoBillingId,_that.receiptNumber,_that.amount,_that.mode,_that.adjustFlag,_that.dabitCredit,_that.accept,_that.chequeDdnumber,_that.chequeDate,_that.bank,_that.branch,_that.remarks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'authToken')  String authToken, @JsonKey(name: 'lcoEmployeeId')  String lcoEmployeeId, @JsonKey(name: 'lcoBillingId')  String lcoBillingId, @JsonKey(name: 'receiptNumber')  String receiptNumber, @JsonKey(name: 'amount')  double amount, @JsonKey(name: 'mode')  String mode, @JsonKey(name: 'adjustFlag')  int adjustFlag, @JsonKey(name: 'dabitCredit')  String dabitCredit, @JsonKey(name: 'accept')  int accept, @JsonKey(name: 'chequeDdnumber')  String? chequeDdnumber, @JsonKey(name: 'chequeDate')  String? chequeDate, @JsonKey(name: 'bank')  String? bank, @JsonKey(name: 'branch')  String? branch, @JsonKey(name: 'remarks')  String? remarks)  $default,) {final _that = this;
switch (_that) {
case _LcoPaymentRequest():
return $default(_that.authToken,_that.lcoEmployeeId,_that.lcoBillingId,_that.receiptNumber,_that.amount,_that.mode,_that.adjustFlag,_that.dabitCredit,_that.accept,_that.chequeDdnumber,_that.chequeDate,_that.bank,_that.branch,_that.remarks);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'authToken')  String authToken, @JsonKey(name: 'lcoEmployeeId')  String lcoEmployeeId, @JsonKey(name: 'lcoBillingId')  String lcoBillingId, @JsonKey(name: 'receiptNumber')  String receiptNumber, @JsonKey(name: 'amount')  double amount, @JsonKey(name: 'mode')  String mode, @JsonKey(name: 'adjustFlag')  int adjustFlag, @JsonKey(name: 'dabitCredit')  String dabitCredit, @JsonKey(name: 'accept')  int accept, @JsonKey(name: 'chequeDdnumber')  String? chequeDdnumber, @JsonKey(name: 'chequeDate')  String? chequeDate, @JsonKey(name: 'bank')  String? bank, @JsonKey(name: 'branch')  String? branch, @JsonKey(name: 'remarks')  String? remarks)?  $default,) {final _that = this;
switch (_that) {
case _LcoPaymentRequest() when $default != null:
return $default(_that.authToken,_that.lcoEmployeeId,_that.lcoBillingId,_that.receiptNumber,_that.amount,_that.mode,_that.adjustFlag,_that.dabitCredit,_that.accept,_that.chequeDdnumber,_that.chequeDate,_that.bank,_that.branch,_that.remarks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LcoPaymentRequest implements LcoPaymentRequest {
  const _LcoPaymentRequest({@JsonKey(name: 'authToken') this.authToken = '', @JsonKey(name: 'lcoEmployeeId') this.lcoEmployeeId = '', @JsonKey(name: 'lcoBillingId') this.lcoBillingId = '', @JsonKey(name: 'receiptNumber') this.receiptNumber = '', @JsonKey(name: 'amount') this.amount = 0.0, @JsonKey(name: 'mode') this.mode = '', @JsonKey(name: 'adjustFlag') this.adjustFlag = 0, @JsonKey(name: 'dabitCredit') this.dabitCredit = '', @JsonKey(name: 'accept') this.accept = 0, @JsonKey(name: 'chequeDdnumber') this.chequeDdnumber, @JsonKey(name: 'chequeDate') this.chequeDate, @JsonKey(name: 'bank') this.bank, @JsonKey(name: 'branch') this.branch, @JsonKey(name: 'remarks') this.remarks});
  factory _LcoPaymentRequest.fromJson(Map<String, dynamic> json) => _$LcoPaymentRequestFromJson(json);

@override@JsonKey(name: 'authToken') final  String authToken;
@override@JsonKey(name: 'lcoEmployeeId') final  String lcoEmployeeId;
@override@JsonKey(name: 'lcoBillingId') final  String lcoBillingId;
@override@JsonKey(name: 'receiptNumber') final  String receiptNumber;
@override@JsonKey(name: 'amount') final  double amount;
@override@JsonKey(name: 'mode') final  String mode;
@override@JsonKey(name: 'adjustFlag') final  int adjustFlag;
@override@JsonKey(name: 'dabitCredit') final  String dabitCredit;
@override@JsonKey(name: 'accept') final  int accept;
@override@JsonKey(name: 'chequeDdnumber') final  String? chequeDdnumber;
@override@JsonKey(name: 'chequeDate') final  String? chequeDate;
@override@JsonKey(name: 'bank') final  String? bank;
@override@JsonKey(name: 'branch') final  String? branch;
@override@JsonKey(name: 'remarks') final  String? remarks;

/// Create a copy of LcoPaymentRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LcoPaymentRequestCopyWith<_LcoPaymentRequest> get copyWith => __$LcoPaymentRequestCopyWithImpl<_LcoPaymentRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LcoPaymentRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LcoPaymentRequest&&(identical(other.authToken, authToken) || other.authToken == authToken)&&(identical(other.lcoEmployeeId, lcoEmployeeId) || other.lcoEmployeeId == lcoEmployeeId)&&(identical(other.lcoBillingId, lcoBillingId) || other.lcoBillingId == lcoBillingId)&&(identical(other.receiptNumber, receiptNumber) || other.receiptNumber == receiptNumber)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.adjustFlag, adjustFlag) || other.adjustFlag == adjustFlag)&&(identical(other.dabitCredit, dabitCredit) || other.dabitCredit == dabitCredit)&&(identical(other.accept, accept) || other.accept == accept)&&(identical(other.chequeDdnumber, chequeDdnumber) || other.chequeDdnumber == chequeDdnumber)&&(identical(other.chequeDate, chequeDate) || other.chequeDate == chequeDate)&&(identical(other.bank, bank) || other.bank == bank)&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.remarks, remarks) || other.remarks == remarks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,authToken,lcoEmployeeId,lcoBillingId,receiptNumber,amount,mode,adjustFlag,dabitCredit,accept,chequeDdnumber,chequeDate,bank,branch,remarks);

@override
String toString() {
  return 'LcoPaymentRequest(authToken: $authToken, lcoEmployeeId: $lcoEmployeeId, lcoBillingId: $lcoBillingId, receiptNumber: $receiptNumber, amount: $amount, mode: $mode, adjustFlag: $adjustFlag, dabitCredit: $dabitCredit, accept: $accept, chequeDdnumber: $chequeDdnumber, chequeDate: $chequeDate, bank: $bank, branch: $branch, remarks: $remarks)';
}


}

/// @nodoc
abstract mixin class _$LcoPaymentRequestCopyWith<$Res> implements $LcoPaymentRequestCopyWith<$Res> {
  factory _$LcoPaymentRequestCopyWith(_LcoPaymentRequest value, $Res Function(_LcoPaymentRequest) _then) = __$LcoPaymentRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'authToken') String authToken,@JsonKey(name: 'lcoEmployeeId') String lcoEmployeeId,@JsonKey(name: 'lcoBillingId') String lcoBillingId,@JsonKey(name: 'receiptNumber') String receiptNumber,@JsonKey(name: 'amount') double amount,@JsonKey(name: 'mode') String mode,@JsonKey(name: 'adjustFlag') int adjustFlag,@JsonKey(name: 'dabitCredit') String dabitCredit,@JsonKey(name: 'accept') int accept,@JsonKey(name: 'chequeDdnumber') String? chequeDdnumber,@JsonKey(name: 'chequeDate') String? chequeDate,@JsonKey(name: 'bank') String? bank,@JsonKey(name: 'branch') String? branch,@JsonKey(name: 'remarks') String? remarks
});




}
/// @nodoc
class __$LcoPaymentRequestCopyWithImpl<$Res>
    implements _$LcoPaymentRequestCopyWith<$Res> {
  __$LcoPaymentRequestCopyWithImpl(this._self, this._then);

  final _LcoPaymentRequest _self;
  final $Res Function(_LcoPaymentRequest) _then;

/// Create a copy of LcoPaymentRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? authToken = null,Object? lcoEmployeeId = null,Object? lcoBillingId = null,Object? receiptNumber = null,Object? amount = null,Object? mode = null,Object? adjustFlag = null,Object? dabitCredit = null,Object? accept = null,Object? chequeDdnumber = freezed,Object? chequeDate = freezed,Object? bank = freezed,Object? branch = freezed,Object? remarks = freezed,}) {
  return _then(_LcoPaymentRequest(
authToken: null == authToken ? _self.authToken : authToken // ignore: cast_nullable_to_non_nullable
as String,lcoEmployeeId: null == lcoEmployeeId ? _self.lcoEmployeeId : lcoEmployeeId // ignore: cast_nullable_to_non_nullable
as String,lcoBillingId: null == lcoBillingId ? _self.lcoBillingId : lcoBillingId // ignore: cast_nullable_to_non_nullable
as String,receiptNumber: null == receiptNumber ? _self.receiptNumber : receiptNumber // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as String,adjustFlag: null == adjustFlag ? _self.adjustFlag : adjustFlag // ignore: cast_nullable_to_non_nullable
as int,dabitCredit: null == dabitCredit ? _self.dabitCredit : dabitCredit // ignore: cast_nullable_to_non_nullable
as String,accept: null == accept ? _self.accept : accept // ignore: cast_nullable_to_non_nullable
as int,chequeDdnumber: freezed == chequeDdnumber ? _self.chequeDdnumber : chequeDdnumber // ignore: cast_nullable_to_non_nullable
as String?,chequeDate: freezed == chequeDate ? _self.chequeDate : chequeDate // ignore: cast_nullable_to_non_nullable
as String?,bank: freezed == bank ? _self.bank : bank // ignore: cast_nullable_to_non_nullable
as String?,branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String?,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
