// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lco_wallet_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LcoWalletEntry {

@JsonKey(name: 'deposite_amount') double get depositeAmount;@JsonKey(name: 'Deposit_Date') String? get depositDate;@JsonKey(name: 'business_name') String? get businessName;@JsonKey(name: 'payment_mode') String? get paymentMode;@JsonKey(name: 'cheque_ddnumber') String? get chequeDdnumber;@JsonKey(name: 'bank') String? get bank;@JsonKey(name: 'branch') String? get branch;@JsonKey(name: 'instrument_date') String? get instrumentDate;@JsonKey(name: 'credit_amount') double get creditAmount;@JsonKey(name: 'debit_amount') double get debitAmount;@JsonKey(name: 'transaction_no') String? get transactionNo;@JsonKey(name: 'receipt_no') String? get receiptNo;@JsonKey(name: 'Remarks') String? get remarks;@JsonKey(name: 'Deposited_By') String? get depositedBy;
/// Create a copy of LcoWalletEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LcoWalletEntryCopyWith<LcoWalletEntry> get copyWith => _$LcoWalletEntryCopyWithImpl<LcoWalletEntry>(this as LcoWalletEntry, _$identity);

  /// Serializes this LcoWalletEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LcoWalletEntry&&(identical(other.depositeAmount, depositeAmount) || other.depositeAmount == depositeAmount)&&(identical(other.depositDate, depositDate) || other.depositDate == depositDate)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.chequeDdnumber, chequeDdnumber) || other.chequeDdnumber == chequeDdnumber)&&(identical(other.bank, bank) || other.bank == bank)&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.instrumentDate, instrumentDate) || other.instrumentDate == instrumentDate)&&(identical(other.creditAmount, creditAmount) || other.creditAmount == creditAmount)&&(identical(other.debitAmount, debitAmount) || other.debitAmount == debitAmount)&&(identical(other.transactionNo, transactionNo) || other.transactionNo == transactionNo)&&(identical(other.receiptNo, receiptNo) || other.receiptNo == receiptNo)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&(identical(other.depositedBy, depositedBy) || other.depositedBy == depositedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,depositeAmount,depositDate,businessName,paymentMode,chequeDdnumber,bank,branch,instrumentDate,creditAmount,debitAmount,transactionNo,receiptNo,remarks,depositedBy);

@override
String toString() {
  return 'LcoWalletEntry(depositeAmount: $depositeAmount, depositDate: $depositDate, businessName: $businessName, paymentMode: $paymentMode, chequeDdnumber: $chequeDdnumber, bank: $bank, branch: $branch, instrumentDate: $instrumentDate, creditAmount: $creditAmount, debitAmount: $debitAmount, transactionNo: $transactionNo, receiptNo: $receiptNo, remarks: $remarks, depositedBy: $depositedBy)';
}


}

/// @nodoc
abstract mixin class $LcoWalletEntryCopyWith<$Res>  {
  factory $LcoWalletEntryCopyWith(LcoWalletEntry value, $Res Function(LcoWalletEntry) _then) = _$LcoWalletEntryCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'deposite_amount') double depositeAmount,@JsonKey(name: 'Deposit_Date') String? depositDate,@JsonKey(name: 'business_name') String? businessName,@JsonKey(name: 'payment_mode') String? paymentMode,@JsonKey(name: 'cheque_ddnumber') String? chequeDdnumber,@JsonKey(name: 'bank') String? bank,@JsonKey(name: 'branch') String? branch,@JsonKey(name: 'instrument_date') String? instrumentDate,@JsonKey(name: 'credit_amount') double creditAmount,@JsonKey(name: 'debit_amount') double debitAmount,@JsonKey(name: 'transaction_no') String? transactionNo,@JsonKey(name: 'receipt_no') String? receiptNo,@JsonKey(name: 'Remarks') String? remarks,@JsonKey(name: 'Deposited_By') String? depositedBy
});




}
/// @nodoc
class _$LcoWalletEntryCopyWithImpl<$Res>
    implements $LcoWalletEntryCopyWith<$Res> {
  _$LcoWalletEntryCopyWithImpl(this._self, this._then);

  final LcoWalletEntry _self;
  final $Res Function(LcoWalletEntry) _then;

/// Create a copy of LcoWalletEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? depositeAmount = null,Object? depositDate = freezed,Object? businessName = freezed,Object? paymentMode = freezed,Object? chequeDdnumber = freezed,Object? bank = freezed,Object? branch = freezed,Object? instrumentDate = freezed,Object? creditAmount = null,Object? debitAmount = null,Object? transactionNo = freezed,Object? receiptNo = freezed,Object? remarks = freezed,Object? depositedBy = freezed,}) {
  return _then(_self.copyWith(
depositeAmount: null == depositeAmount ? _self.depositeAmount : depositeAmount // ignore: cast_nullable_to_non_nullable
as double,depositDate: freezed == depositDate ? _self.depositDate : depositDate // ignore: cast_nullable_to_non_nullable
as String?,businessName: freezed == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String?,paymentMode: freezed == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String?,chequeDdnumber: freezed == chequeDdnumber ? _self.chequeDdnumber : chequeDdnumber // ignore: cast_nullable_to_non_nullable
as String?,bank: freezed == bank ? _self.bank : bank // ignore: cast_nullable_to_non_nullable
as String?,branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String?,instrumentDate: freezed == instrumentDate ? _self.instrumentDate : instrumentDate // ignore: cast_nullable_to_non_nullable
as String?,creditAmount: null == creditAmount ? _self.creditAmount : creditAmount // ignore: cast_nullable_to_non_nullable
as double,debitAmount: null == debitAmount ? _self.debitAmount : debitAmount // ignore: cast_nullable_to_non_nullable
as double,transactionNo: freezed == transactionNo ? _self.transactionNo : transactionNo // ignore: cast_nullable_to_non_nullable
as String?,receiptNo: freezed == receiptNo ? _self.receiptNo : receiptNo // ignore: cast_nullable_to_non_nullable
as String?,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,depositedBy: freezed == depositedBy ? _self.depositedBy : depositedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LcoWalletEntry].
extension LcoWalletEntryPatterns on LcoWalletEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LcoWalletEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LcoWalletEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LcoWalletEntry value)  $default,){
final _that = this;
switch (_that) {
case _LcoWalletEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LcoWalletEntry value)?  $default,){
final _that = this;
switch (_that) {
case _LcoWalletEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'deposite_amount')  double depositeAmount, @JsonKey(name: 'Deposit_Date')  String? depositDate, @JsonKey(name: 'business_name')  String? businessName, @JsonKey(name: 'payment_mode')  String? paymentMode, @JsonKey(name: 'cheque_ddnumber')  String? chequeDdnumber, @JsonKey(name: 'bank')  String? bank, @JsonKey(name: 'branch')  String? branch, @JsonKey(name: 'instrument_date')  String? instrumentDate, @JsonKey(name: 'credit_amount')  double creditAmount, @JsonKey(name: 'debit_amount')  double debitAmount, @JsonKey(name: 'transaction_no')  String? transactionNo, @JsonKey(name: 'receipt_no')  String? receiptNo, @JsonKey(name: 'Remarks')  String? remarks, @JsonKey(name: 'Deposited_By')  String? depositedBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LcoWalletEntry() when $default != null:
return $default(_that.depositeAmount,_that.depositDate,_that.businessName,_that.paymentMode,_that.chequeDdnumber,_that.bank,_that.branch,_that.instrumentDate,_that.creditAmount,_that.debitAmount,_that.transactionNo,_that.receiptNo,_that.remarks,_that.depositedBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'deposite_amount')  double depositeAmount, @JsonKey(name: 'Deposit_Date')  String? depositDate, @JsonKey(name: 'business_name')  String? businessName, @JsonKey(name: 'payment_mode')  String? paymentMode, @JsonKey(name: 'cheque_ddnumber')  String? chequeDdnumber, @JsonKey(name: 'bank')  String? bank, @JsonKey(name: 'branch')  String? branch, @JsonKey(name: 'instrument_date')  String? instrumentDate, @JsonKey(name: 'credit_amount')  double creditAmount, @JsonKey(name: 'debit_amount')  double debitAmount, @JsonKey(name: 'transaction_no')  String? transactionNo, @JsonKey(name: 'receipt_no')  String? receiptNo, @JsonKey(name: 'Remarks')  String? remarks, @JsonKey(name: 'Deposited_By')  String? depositedBy)  $default,) {final _that = this;
switch (_that) {
case _LcoWalletEntry():
return $default(_that.depositeAmount,_that.depositDate,_that.businessName,_that.paymentMode,_that.chequeDdnumber,_that.bank,_that.branch,_that.instrumentDate,_that.creditAmount,_that.debitAmount,_that.transactionNo,_that.receiptNo,_that.remarks,_that.depositedBy);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'deposite_amount')  double depositeAmount, @JsonKey(name: 'Deposit_Date')  String? depositDate, @JsonKey(name: 'business_name')  String? businessName, @JsonKey(name: 'payment_mode')  String? paymentMode, @JsonKey(name: 'cheque_ddnumber')  String? chequeDdnumber, @JsonKey(name: 'bank')  String? bank, @JsonKey(name: 'branch')  String? branch, @JsonKey(name: 'instrument_date')  String? instrumentDate, @JsonKey(name: 'credit_amount')  double creditAmount, @JsonKey(name: 'debit_amount')  double debitAmount, @JsonKey(name: 'transaction_no')  String? transactionNo, @JsonKey(name: 'receipt_no')  String? receiptNo, @JsonKey(name: 'Remarks')  String? remarks, @JsonKey(name: 'Deposited_By')  String? depositedBy)?  $default,) {final _that = this;
switch (_that) {
case _LcoWalletEntry() when $default != null:
return $default(_that.depositeAmount,_that.depositDate,_that.businessName,_that.paymentMode,_that.chequeDdnumber,_that.bank,_that.branch,_that.instrumentDate,_that.creditAmount,_that.debitAmount,_that.transactionNo,_that.receiptNo,_that.remarks,_that.depositedBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LcoWalletEntry implements LcoWalletEntry {
  const _LcoWalletEntry({@JsonKey(name: 'deposite_amount') this.depositeAmount = 0.0, @JsonKey(name: 'Deposit_Date') this.depositDate, @JsonKey(name: 'business_name') this.businessName, @JsonKey(name: 'payment_mode') this.paymentMode, @JsonKey(name: 'cheque_ddnumber') this.chequeDdnumber, @JsonKey(name: 'bank') this.bank, @JsonKey(name: 'branch') this.branch, @JsonKey(name: 'instrument_date') this.instrumentDate, @JsonKey(name: 'credit_amount') this.creditAmount = 0.0, @JsonKey(name: 'debit_amount') this.debitAmount = 0.0, @JsonKey(name: 'transaction_no') this.transactionNo, @JsonKey(name: 'receipt_no') this.receiptNo, @JsonKey(name: 'Remarks') this.remarks, @JsonKey(name: 'Deposited_By') this.depositedBy});
  factory _LcoWalletEntry.fromJson(Map<String, dynamic> json) => _$LcoWalletEntryFromJson(json);

@override@JsonKey(name: 'deposite_amount') final  double depositeAmount;
@override@JsonKey(name: 'Deposit_Date') final  String? depositDate;
@override@JsonKey(name: 'business_name') final  String? businessName;
@override@JsonKey(name: 'payment_mode') final  String? paymentMode;
@override@JsonKey(name: 'cheque_ddnumber') final  String? chequeDdnumber;
@override@JsonKey(name: 'bank') final  String? bank;
@override@JsonKey(name: 'branch') final  String? branch;
@override@JsonKey(name: 'instrument_date') final  String? instrumentDate;
@override@JsonKey(name: 'credit_amount') final  double creditAmount;
@override@JsonKey(name: 'debit_amount') final  double debitAmount;
@override@JsonKey(name: 'transaction_no') final  String? transactionNo;
@override@JsonKey(name: 'receipt_no') final  String? receiptNo;
@override@JsonKey(name: 'Remarks') final  String? remarks;
@override@JsonKey(name: 'Deposited_By') final  String? depositedBy;

/// Create a copy of LcoWalletEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LcoWalletEntryCopyWith<_LcoWalletEntry> get copyWith => __$LcoWalletEntryCopyWithImpl<_LcoWalletEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LcoWalletEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LcoWalletEntry&&(identical(other.depositeAmount, depositeAmount) || other.depositeAmount == depositeAmount)&&(identical(other.depositDate, depositDate) || other.depositDate == depositDate)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.chequeDdnumber, chequeDdnumber) || other.chequeDdnumber == chequeDdnumber)&&(identical(other.bank, bank) || other.bank == bank)&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.instrumentDate, instrumentDate) || other.instrumentDate == instrumentDate)&&(identical(other.creditAmount, creditAmount) || other.creditAmount == creditAmount)&&(identical(other.debitAmount, debitAmount) || other.debitAmount == debitAmount)&&(identical(other.transactionNo, transactionNo) || other.transactionNo == transactionNo)&&(identical(other.receiptNo, receiptNo) || other.receiptNo == receiptNo)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&(identical(other.depositedBy, depositedBy) || other.depositedBy == depositedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,depositeAmount,depositDate,businessName,paymentMode,chequeDdnumber,bank,branch,instrumentDate,creditAmount,debitAmount,transactionNo,receiptNo,remarks,depositedBy);

@override
String toString() {
  return 'LcoWalletEntry(depositeAmount: $depositeAmount, depositDate: $depositDate, businessName: $businessName, paymentMode: $paymentMode, chequeDdnumber: $chequeDdnumber, bank: $bank, branch: $branch, instrumentDate: $instrumentDate, creditAmount: $creditAmount, debitAmount: $debitAmount, transactionNo: $transactionNo, receiptNo: $receiptNo, remarks: $remarks, depositedBy: $depositedBy)';
}


}

/// @nodoc
abstract mixin class _$LcoWalletEntryCopyWith<$Res> implements $LcoWalletEntryCopyWith<$Res> {
  factory _$LcoWalletEntryCopyWith(_LcoWalletEntry value, $Res Function(_LcoWalletEntry) _then) = __$LcoWalletEntryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'deposite_amount') double depositeAmount,@JsonKey(name: 'Deposit_Date') String? depositDate,@JsonKey(name: 'business_name') String? businessName,@JsonKey(name: 'payment_mode') String? paymentMode,@JsonKey(name: 'cheque_ddnumber') String? chequeDdnumber,@JsonKey(name: 'bank') String? bank,@JsonKey(name: 'branch') String? branch,@JsonKey(name: 'instrument_date') String? instrumentDate,@JsonKey(name: 'credit_amount') double creditAmount,@JsonKey(name: 'debit_amount') double debitAmount,@JsonKey(name: 'transaction_no') String? transactionNo,@JsonKey(name: 'receipt_no') String? receiptNo,@JsonKey(name: 'Remarks') String? remarks,@JsonKey(name: 'Deposited_By') String? depositedBy
});




}
/// @nodoc
class __$LcoWalletEntryCopyWithImpl<$Res>
    implements _$LcoWalletEntryCopyWith<$Res> {
  __$LcoWalletEntryCopyWithImpl(this._self, this._then);

  final _LcoWalletEntry _self;
  final $Res Function(_LcoWalletEntry) _then;

/// Create a copy of LcoWalletEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? depositeAmount = null,Object? depositDate = freezed,Object? businessName = freezed,Object? paymentMode = freezed,Object? chequeDdnumber = freezed,Object? bank = freezed,Object? branch = freezed,Object? instrumentDate = freezed,Object? creditAmount = null,Object? debitAmount = null,Object? transactionNo = freezed,Object? receiptNo = freezed,Object? remarks = freezed,Object? depositedBy = freezed,}) {
  return _then(_LcoWalletEntry(
depositeAmount: null == depositeAmount ? _self.depositeAmount : depositeAmount // ignore: cast_nullable_to_non_nullable
as double,depositDate: freezed == depositDate ? _self.depositDate : depositDate // ignore: cast_nullable_to_non_nullable
as String?,businessName: freezed == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String?,paymentMode: freezed == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String?,chequeDdnumber: freezed == chequeDdnumber ? _self.chequeDdnumber : chequeDdnumber // ignore: cast_nullable_to_non_nullable
as String?,bank: freezed == bank ? _self.bank : bank // ignore: cast_nullable_to_non_nullable
as String?,branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String?,instrumentDate: freezed == instrumentDate ? _self.instrumentDate : instrumentDate // ignore: cast_nullable_to_non_nullable
as String?,creditAmount: null == creditAmount ? _self.creditAmount : creditAmount // ignore: cast_nullable_to_non_nullable
as double,debitAmount: null == debitAmount ? _self.debitAmount : debitAmount // ignore: cast_nullable_to_non_nullable
as double,transactionNo: freezed == transactionNo ? _self.transactionNo : transactionNo // ignore: cast_nullable_to_non_nullable
as String?,receiptNo: freezed == receiptNo ? _self.receiptNo : receiptNo // ignore: cast_nullable_to_non_nullable
as String?,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,depositedBy: freezed == depositedBy ? _self.depositedBy : depositedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
