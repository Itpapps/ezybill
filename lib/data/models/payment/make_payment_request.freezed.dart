// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'make_payment_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MakePaymentRequest {

@JsonKey(name: 'altCustomerId') String get altCustomerId;@JsonKey(name: 'amount') double get amount;@JsonKey(name: 'modeType') String get modeType;@JsonKey(name: 'receiptNumber') String? get receiptNumber;@JsonKey(name: 'altReceiptNumber') String? get altReceiptNumber;@JsonKey(name: 'remarks') String? get remarks;@JsonKey(name: 'billingId') String? get billingId;@JsonKey(name: 'chequeNo') String? get chequeNo;@JsonKey(name: 'bank') String? get bank;@JsonKey(name: 'branch') String? get branch;@JsonKey(name: 'chequeDate') String? get chequeDate;@JsonKey(name: 'rrnNo') String? get rrnNo;@JsonKey(name: 'cardholderName') String? get cardholderName;@JsonKey(name: 'cardType') String? get cardType;@JsonKey(name: 'voucherCode') String? get voucherCode;@JsonKey(name: 'imei') String? get imei;
/// Create a copy of MakePaymentRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MakePaymentRequestCopyWith<MakePaymentRequest> get copyWith => _$MakePaymentRequestCopyWithImpl<MakePaymentRequest>(this as MakePaymentRequest, _$identity);

  /// Serializes this MakePaymentRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MakePaymentRequest&&(identical(other.altCustomerId, altCustomerId) || other.altCustomerId == altCustomerId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.modeType, modeType) || other.modeType == modeType)&&(identical(other.receiptNumber, receiptNumber) || other.receiptNumber == receiptNumber)&&(identical(other.altReceiptNumber, altReceiptNumber) || other.altReceiptNumber == altReceiptNumber)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&(identical(other.billingId, billingId) || other.billingId == billingId)&&(identical(other.chequeNo, chequeNo) || other.chequeNo == chequeNo)&&(identical(other.bank, bank) || other.bank == bank)&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.chequeDate, chequeDate) || other.chequeDate == chequeDate)&&(identical(other.rrnNo, rrnNo) || other.rrnNo == rrnNo)&&(identical(other.cardholderName, cardholderName) || other.cardholderName == cardholderName)&&(identical(other.cardType, cardType) || other.cardType == cardType)&&(identical(other.voucherCode, voucherCode) || other.voucherCode == voucherCode)&&(identical(other.imei, imei) || other.imei == imei));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,altCustomerId,amount,modeType,receiptNumber,altReceiptNumber,remarks,billingId,chequeNo,bank,branch,chequeDate,rrnNo,cardholderName,cardType,voucherCode,imei);

@override
String toString() {
  return 'MakePaymentRequest(altCustomerId: $altCustomerId, amount: $amount, modeType: $modeType, receiptNumber: $receiptNumber, altReceiptNumber: $altReceiptNumber, remarks: $remarks, billingId: $billingId, chequeNo: $chequeNo, bank: $bank, branch: $branch, chequeDate: $chequeDate, rrnNo: $rrnNo, cardholderName: $cardholderName, cardType: $cardType, voucherCode: $voucherCode, imei: $imei)';
}


}

/// @nodoc
abstract mixin class $MakePaymentRequestCopyWith<$Res>  {
  factory $MakePaymentRequestCopyWith(MakePaymentRequest value, $Res Function(MakePaymentRequest) _then) = _$MakePaymentRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'altCustomerId') String altCustomerId,@JsonKey(name: 'amount') double amount,@JsonKey(name: 'modeType') String modeType,@JsonKey(name: 'receiptNumber') String? receiptNumber,@JsonKey(name: 'altReceiptNumber') String? altReceiptNumber,@JsonKey(name: 'remarks') String? remarks,@JsonKey(name: 'billingId') String? billingId,@JsonKey(name: 'chequeNo') String? chequeNo,@JsonKey(name: 'bank') String? bank,@JsonKey(name: 'branch') String? branch,@JsonKey(name: 'chequeDate') String? chequeDate,@JsonKey(name: 'rrnNo') String? rrnNo,@JsonKey(name: 'cardholderName') String? cardholderName,@JsonKey(name: 'cardType') String? cardType,@JsonKey(name: 'voucherCode') String? voucherCode,@JsonKey(name: 'imei') String? imei
});




}
/// @nodoc
class _$MakePaymentRequestCopyWithImpl<$Res>
    implements $MakePaymentRequestCopyWith<$Res> {
  _$MakePaymentRequestCopyWithImpl(this._self, this._then);

  final MakePaymentRequest _self;
  final $Res Function(MakePaymentRequest) _then;

/// Create a copy of MakePaymentRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? altCustomerId = null,Object? amount = null,Object? modeType = null,Object? receiptNumber = freezed,Object? altReceiptNumber = freezed,Object? remarks = freezed,Object? billingId = freezed,Object? chequeNo = freezed,Object? bank = freezed,Object? branch = freezed,Object? chequeDate = freezed,Object? rrnNo = freezed,Object? cardholderName = freezed,Object? cardType = freezed,Object? voucherCode = freezed,Object? imei = freezed,}) {
  return _then(_self.copyWith(
altCustomerId: null == altCustomerId ? _self.altCustomerId : altCustomerId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,modeType: null == modeType ? _self.modeType : modeType // ignore: cast_nullable_to_non_nullable
as String,receiptNumber: freezed == receiptNumber ? _self.receiptNumber : receiptNumber // ignore: cast_nullable_to_non_nullable
as String?,altReceiptNumber: freezed == altReceiptNumber ? _self.altReceiptNumber : altReceiptNumber // ignore: cast_nullable_to_non_nullable
as String?,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,billingId: freezed == billingId ? _self.billingId : billingId // ignore: cast_nullable_to_non_nullable
as String?,chequeNo: freezed == chequeNo ? _self.chequeNo : chequeNo // ignore: cast_nullable_to_non_nullable
as String?,bank: freezed == bank ? _self.bank : bank // ignore: cast_nullable_to_non_nullable
as String?,branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String?,chequeDate: freezed == chequeDate ? _self.chequeDate : chequeDate // ignore: cast_nullable_to_non_nullable
as String?,rrnNo: freezed == rrnNo ? _self.rrnNo : rrnNo // ignore: cast_nullable_to_non_nullable
as String?,cardholderName: freezed == cardholderName ? _self.cardholderName : cardholderName // ignore: cast_nullable_to_non_nullable
as String?,cardType: freezed == cardType ? _self.cardType : cardType // ignore: cast_nullable_to_non_nullable
as String?,voucherCode: freezed == voucherCode ? _self.voucherCode : voucherCode // ignore: cast_nullable_to_non_nullable
as String?,imei: freezed == imei ? _self.imei : imei // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MakePaymentRequest].
extension MakePaymentRequestPatterns on MakePaymentRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MakePaymentRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MakePaymentRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MakePaymentRequest value)  $default,){
final _that = this;
switch (_that) {
case _MakePaymentRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MakePaymentRequest value)?  $default,){
final _that = this;
switch (_that) {
case _MakePaymentRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'altCustomerId')  String altCustomerId, @JsonKey(name: 'amount')  double amount, @JsonKey(name: 'modeType')  String modeType, @JsonKey(name: 'receiptNumber')  String? receiptNumber, @JsonKey(name: 'altReceiptNumber')  String? altReceiptNumber, @JsonKey(name: 'remarks')  String? remarks, @JsonKey(name: 'billingId')  String? billingId, @JsonKey(name: 'chequeNo')  String? chequeNo, @JsonKey(name: 'bank')  String? bank, @JsonKey(name: 'branch')  String? branch, @JsonKey(name: 'chequeDate')  String? chequeDate, @JsonKey(name: 'rrnNo')  String? rrnNo, @JsonKey(name: 'cardholderName')  String? cardholderName, @JsonKey(name: 'cardType')  String? cardType, @JsonKey(name: 'voucherCode')  String? voucherCode, @JsonKey(name: 'imei')  String? imei)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MakePaymentRequest() when $default != null:
return $default(_that.altCustomerId,_that.amount,_that.modeType,_that.receiptNumber,_that.altReceiptNumber,_that.remarks,_that.billingId,_that.chequeNo,_that.bank,_that.branch,_that.chequeDate,_that.rrnNo,_that.cardholderName,_that.cardType,_that.voucherCode,_that.imei);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'altCustomerId')  String altCustomerId, @JsonKey(name: 'amount')  double amount, @JsonKey(name: 'modeType')  String modeType, @JsonKey(name: 'receiptNumber')  String? receiptNumber, @JsonKey(name: 'altReceiptNumber')  String? altReceiptNumber, @JsonKey(name: 'remarks')  String? remarks, @JsonKey(name: 'billingId')  String? billingId, @JsonKey(name: 'chequeNo')  String? chequeNo, @JsonKey(name: 'bank')  String? bank, @JsonKey(name: 'branch')  String? branch, @JsonKey(name: 'chequeDate')  String? chequeDate, @JsonKey(name: 'rrnNo')  String? rrnNo, @JsonKey(name: 'cardholderName')  String? cardholderName, @JsonKey(name: 'cardType')  String? cardType, @JsonKey(name: 'voucherCode')  String? voucherCode, @JsonKey(name: 'imei')  String? imei)  $default,) {final _that = this;
switch (_that) {
case _MakePaymentRequest():
return $default(_that.altCustomerId,_that.amount,_that.modeType,_that.receiptNumber,_that.altReceiptNumber,_that.remarks,_that.billingId,_that.chequeNo,_that.bank,_that.branch,_that.chequeDate,_that.rrnNo,_that.cardholderName,_that.cardType,_that.voucherCode,_that.imei);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'altCustomerId')  String altCustomerId, @JsonKey(name: 'amount')  double amount, @JsonKey(name: 'modeType')  String modeType, @JsonKey(name: 'receiptNumber')  String? receiptNumber, @JsonKey(name: 'altReceiptNumber')  String? altReceiptNumber, @JsonKey(name: 'remarks')  String? remarks, @JsonKey(name: 'billingId')  String? billingId, @JsonKey(name: 'chequeNo')  String? chequeNo, @JsonKey(name: 'bank')  String? bank, @JsonKey(name: 'branch')  String? branch, @JsonKey(name: 'chequeDate')  String? chequeDate, @JsonKey(name: 'rrnNo')  String? rrnNo, @JsonKey(name: 'cardholderName')  String? cardholderName, @JsonKey(name: 'cardType')  String? cardType, @JsonKey(name: 'voucherCode')  String? voucherCode, @JsonKey(name: 'imei')  String? imei)?  $default,) {final _that = this;
switch (_that) {
case _MakePaymentRequest() when $default != null:
return $default(_that.altCustomerId,_that.amount,_that.modeType,_that.receiptNumber,_that.altReceiptNumber,_that.remarks,_that.billingId,_that.chequeNo,_that.bank,_that.branch,_that.chequeDate,_that.rrnNo,_that.cardholderName,_that.cardType,_that.voucherCode,_that.imei);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MakePaymentRequest implements MakePaymentRequest {
  const _MakePaymentRequest({@JsonKey(name: 'altCustomerId') required this.altCustomerId, @JsonKey(name: 'amount') required this.amount, @JsonKey(name: 'modeType') required this.modeType, @JsonKey(name: 'receiptNumber') this.receiptNumber, @JsonKey(name: 'altReceiptNumber') this.altReceiptNumber, @JsonKey(name: 'remarks') this.remarks, @JsonKey(name: 'billingId') this.billingId, @JsonKey(name: 'chequeNo') this.chequeNo, @JsonKey(name: 'bank') this.bank, @JsonKey(name: 'branch') this.branch, @JsonKey(name: 'chequeDate') this.chequeDate, @JsonKey(name: 'rrnNo') this.rrnNo, @JsonKey(name: 'cardholderName') this.cardholderName, @JsonKey(name: 'cardType') this.cardType, @JsonKey(name: 'voucherCode') this.voucherCode, @JsonKey(name: 'imei') this.imei});
  factory _MakePaymentRequest.fromJson(Map<String, dynamic> json) => _$MakePaymentRequestFromJson(json);

@override@JsonKey(name: 'altCustomerId') final  String altCustomerId;
@override@JsonKey(name: 'amount') final  double amount;
@override@JsonKey(name: 'modeType') final  String modeType;
@override@JsonKey(name: 'receiptNumber') final  String? receiptNumber;
@override@JsonKey(name: 'altReceiptNumber') final  String? altReceiptNumber;
@override@JsonKey(name: 'remarks') final  String? remarks;
@override@JsonKey(name: 'billingId') final  String? billingId;
@override@JsonKey(name: 'chequeNo') final  String? chequeNo;
@override@JsonKey(name: 'bank') final  String? bank;
@override@JsonKey(name: 'branch') final  String? branch;
@override@JsonKey(name: 'chequeDate') final  String? chequeDate;
@override@JsonKey(name: 'rrnNo') final  String? rrnNo;
@override@JsonKey(name: 'cardholderName') final  String? cardholderName;
@override@JsonKey(name: 'cardType') final  String? cardType;
@override@JsonKey(name: 'voucherCode') final  String? voucherCode;
@override@JsonKey(name: 'imei') final  String? imei;

/// Create a copy of MakePaymentRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MakePaymentRequestCopyWith<_MakePaymentRequest> get copyWith => __$MakePaymentRequestCopyWithImpl<_MakePaymentRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MakePaymentRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MakePaymentRequest&&(identical(other.altCustomerId, altCustomerId) || other.altCustomerId == altCustomerId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.modeType, modeType) || other.modeType == modeType)&&(identical(other.receiptNumber, receiptNumber) || other.receiptNumber == receiptNumber)&&(identical(other.altReceiptNumber, altReceiptNumber) || other.altReceiptNumber == altReceiptNumber)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&(identical(other.billingId, billingId) || other.billingId == billingId)&&(identical(other.chequeNo, chequeNo) || other.chequeNo == chequeNo)&&(identical(other.bank, bank) || other.bank == bank)&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.chequeDate, chequeDate) || other.chequeDate == chequeDate)&&(identical(other.rrnNo, rrnNo) || other.rrnNo == rrnNo)&&(identical(other.cardholderName, cardholderName) || other.cardholderName == cardholderName)&&(identical(other.cardType, cardType) || other.cardType == cardType)&&(identical(other.voucherCode, voucherCode) || other.voucherCode == voucherCode)&&(identical(other.imei, imei) || other.imei == imei));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,altCustomerId,amount,modeType,receiptNumber,altReceiptNumber,remarks,billingId,chequeNo,bank,branch,chequeDate,rrnNo,cardholderName,cardType,voucherCode,imei);

@override
String toString() {
  return 'MakePaymentRequest(altCustomerId: $altCustomerId, amount: $amount, modeType: $modeType, receiptNumber: $receiptNumber, altReceiptNumber: $altReceiptNumber, remarks: $remarks, billingId: $billingId, chequeNo: $chequeNo, bank: $bank, branch: $branch, chequeDate: $chequeDate, rrnNo: $rrnNo, cardholderName: $cardholderName, cardType: $cardType, voucherCode: $voucherCode, imei: $imei)';
}


}

/// @nodoc
abstract mixin class _$MakePaymentRequestCopyWith<$Res> implements $MakePaymentRequestCopyWith<$Res> {
  factory _$MakePaymentRequestCopyWith(_MakePaymentRequest value, $Res Function(_MakePaymentRequest) _then) = __$MakePaymentRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'altCustomerId') String altCustomerId,@JsonKey(name: 'amount') double amount,@JsonKey(name: 'modeType') String modeType,@JsonKey(name: 'receiptNumber') String? receiptNumber,@JsonKey(name: 'altReceiptNumber') String? altReceiptNumber,@JsonKey(name: 'remarks') String? remarks,@JsonKey(name: 'billingId') String? billingId,@JsonKey(name: 'chequeNo') String? chequeNo,@JsonKey(name: 'bank') String? bank,@JsonKey(name: 'branch') String? branch,@JsonKey(name: 'chequeDate') String? chequeDate,@JsonKey(name: 'rrnNo') String? rrnNo,@JsonKey(name: 'cardholderName') String? cardholderName,@JsonKey(name: 'cardType') String? cardType,@JsonKey(name: 'voucherCode') String? voucherCode,@JsonKey(name: 'imei') String? imei
});




}
/// @nodoc
class __$MakePaymentRequestCopyWithImpl<$Res>
    implements _$MakePaymentRequestCopyWith<$Res> {
  __$MakePaymentRequestCopyWithImpl(this._self, this._then);

  final _MakePaymentRequest _self;
  final $Res Function(_MakePaymentRequest) _then;

/// Create a copy of MakePaymentRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? altCustomerId = null,Object? amount = null,Object? modeType = null,Object? receiptNumber = freezed,Object? altReceiptNumber = freezed,Object? remarks = freezed,Object? billingId = freezed,Object? chequeNo = freezed,Object? bank = freezed,Object? branch = freezed,Object? chequeDate = freezed,Object? rrnNo = freezed,Object? cardholderName = freezed,Object? cardType = freezed,Object? voucherCode = freezed,Object? imei = freezed,}) {
  return _then(_MakePaymentRequest(
altCustomerId: null == altCustomerId ? _self.altCustomerId : altCustomerId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,modeType: null == modeType ? _self.modeType : modeType // ignore: cast_nullable_to_non_nullable
as String,receiptNumber: freezed == receiptNumber ? _self.receiptNumber : receiptNumber // ignore: cast_nullable_to_non_nullable
as String?,altReceiptNumber: freezed == altReceiptNumber ? _self.altReceiptNumber : altReceiptNumber // ignore: cast_nullable_to_non_nullable
as String?,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,billingId: freezed == billingId ? _self.billingId : billingId // ignore: cast_nullable_to_non_nullable
as String?,chequeNo: freezed == chequeNo ? _self.chequeNo : chequeNo // ignore: cast_nullable_to_non_nullable
as String?,bank: freezed == bank ? _self.bank : bank // ignore: cast_nullable_to_non_nullable
as String?,branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String?,chequeDate: freezed == chequeDate ? _self.chequeDate : chequeDate // ignore: cast_nullable_to_non_nullable
as String?,rrnNo: freezed == rrnNo ? _self.rrnNo : rrnNo // ignore: cast_nullable_to_non_nullable
as String?,cardholderName: freezed == cardholderName ? _self.cardholderName : cardholderName // ignore: cast_nullable_to_non_nullable
as String?,cardType: freezed == cardType ? _self.cardType : cardType // ignore: cast_nullable_to_non_nullable
as String?,voucherCode: freezed == voucherCode ? _self.voucherCode : voucherCode // ignore: cast_nullable_to_non_nullable
as String?,imei: freezed == imei ? _self.imei : imei // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
