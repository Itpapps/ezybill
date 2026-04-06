// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'access_control_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AccessControlResponse {

// status_code 0 = success (inverted convention!)
@JsonKey(name: 'status_code') int get statusCode;@JsonKey(name: 'status_msg') String get statusMsg;@JsonKey(name: 'int_bulk_payment') int get intBulkPayment;@JsonKey(name: 'invoice_page_access') int get invoicePageAccess;@JsonKey(name: 'payment_hist_page_access') int get paymentHistPageAccess;@JsonKey(name: 'access_for_complaints') int get accessForComplaints;@JsonKey(name: 'int_stb_activation') int get intStbActivation;@JsonKey(name: 'int_stb_deactivation') int get intStbDeactivation;@JsonKey(name: 'int_stb_reactivation') int get intStbReactivation;@JsonKey(name: 'int_payment_transaction_report_access') int get pgTransactionReportAccess;@JsonKey(name: 'pgtransaction') int get pgtransaction;
/// Create a copy of AccessControlResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccessControlResponseCopyWith<AccessControlResponse> get copyWith => _$AccessControlResponseCopyWithImpl<AccessControlResponse>(this as AccessControlResponse, _$identity);

  /// Serializes this AccessControlResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccessControlResponse&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.statusMsg, statusMsg) || other.statusMsg == statusMsg)&&(identical(other.intBulkPayment, intBulkPayment) || other.intBulkPayment == intBulkPayment)&&(identical(other.invoicePageAccess, invoicePageAccess) || other.invoicePageAccess == invoicePageAccess)&&(identical(other.paymentHistPageAccess, paymentHistPageAccess) || other.paymentHistPageAccess == paymentHistPageAccess)&&(identical(other.accessForComplaints, accessForComplaints) || other.accessForComplaints == accessForComplaints)&&(identical(other.intStbActivation, intStbActivation) || other.intStbActivation == intStbActivation)&&(identical(other.intStbDeactivation, intStbDeactivation) || other.intStbDeactivation == intStbDeactivation)&&(identical(other.intStbReactivation, intStbReactivation) || other.intStbReactivation == intStbReactivation)&&(identical(other.pgTransactionReportAccess, pgTransactionReportAccess) || other.pgTransactionReportAccess == pgTransactionReportAccess)&&(identical(other.pgtransaction, pgtransaction) || other.pgtransaction == pgtransaction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,statusCode,statusMsg,intBulkPayment,invoicePageAccess,paymentHistPageAccess,accessForComplaints,intStbActivation,intStbDeactivation,intStbReactivation,pgTransactionReportAccess,pgtransaction);

@override
String toString() {
  return 'AccessControlResponse(statusCode: $statusCode, statusMsg: $statusMsg, intBulkPayment: $intBulkPayment, invoicePageAccess: $invoicePageAccess, paymentHistPageAccess: $paymentHistPageAccess, accessForComplaints: $accessForComplaints, intStbActivation: $intStbActivation, intStbDeactivation: $intStbDeactivation, intStbReactivation: $intStbReactivation, pgTransactionReportAccess: $pgTransactionReportAccess, pgtransaction: $pgtransaction)';
}


}

/// @nodoc
abstract mixin class $AccessControlResponseCopyWith<$Res>  {
  factory $AccessControlResponseCopyWith(AccessControlResponse value, $Res Function(AccessControlResponse) _then) = _$AccessControlResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'status_code') int statusCode,@JsonKey(name: 'status_msg') String statusMsg,@JsonKey(name: 'int_bulk_payment') int intBulkPayment,@JsonKey(name: 'invoice_page_access') int invoicePageAccess,@JsonKey(name: 'payment_hist_page_access') int paymentHistPageAccess,@JsonKey(name: 'access_for_complaints') int accessForComplaints,@JsonKey(name: 'int_stb_activation') int intStbActivation,@JsonKey(name: 'int_stb_deactivation') int intStbDeactivation,@JsonKey(name: 'int_stb_reactivation') int intStbReactivation,@JsonKey(name: 'int_payment_transaction_report_access') int pgTransactionReportAccess,@JsonKey(name: 'pgtransaction') int pgtransaction
});




}
/// @nodoc
class _$AccessControlResponseCopyWithImpl<$Res>
    implements $AccessControlResponseCopyWith<$Res> {
  _$AccessControlResponseCopyWithImpl(this._self, this._then);

  final AccessControlResponse _self;
  final $Res Function(AccessControlResponse) _then;

/// Create a copy of AccessControlResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? statusCode = null,Object? statusMsg = null,Object? intBulkPayment = null,Object? invoicePageAccess = null,Object? paymentHistPageAccess = null,Object? accessForComplaints = null,Object? intStbActivation = null,Object? intStbDeactivation = null,Object? intStbReactivation = null,Object? pgTransactionReportAccess = null,Object? pgtransaction = null,}) {
  return _then(_self.copyWith(
statusCode: null == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int,statusMsg: null == statusMsg ? _self.statusMsg : statusMsg // ignore: cast_nullable_to_non_nullable
as String,intBulkPayment: null == intBulkPayment ? _self.intBulkPayment : intBulkPayment // ignore: cast_nullable_to_non_nullable
as int,invoicePageAccess: null == invoicePageAccess ? _self.invoicePageAccess : invoicePageAccess // ignore: cast_nullable_to_non_nullable
as int,paymentHistPageAccess: null == paymentHistPageAccess ? _self.paymentHistPageAccess : paymentHistPageAccess // ignore: cast_nullable_to_non_nullable
as int,accessForComplaints: null == accessForComplaints ? _self.accessForComplaints : accessForComplaints // ignore: cast_nullable_to_non_nullable
as int,intStbActivation: null == intStbActivation ? _self.intStbActivation : intStbActivation // ignore: cast_nullable_to_non_nullable
as int,intStbDeactivation: null == intStbDeactivation ? _self.intStbDeactivation : intStbDeactivation // ignore: cast_nullable_to_non_nullable
as int,intStbReactivation: null == intStbReactivation ? _self.intStbReactivation : intStbReactivation // ignore: cast_nullable_to_non_nullable
as int,pgTransactionReportAccess: null == pgTransactionReportAccess ? _self.pgTransactionReportAccess : pgTransactionReportAccess // ignore: cast_nullable_to_non_nullable
as int,pgtransaction: null == pgtransaction ? _self.pgtransaction : pgtransaction // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AccessControlResponse].
extension AccessControlResponsePatterns on AccessControlResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccessControlResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccessControlResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccessControlResponse value)  $default,){
final _that = this;
switch (_that) {
case _AccessControlResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccessControlResponse value)?  $default,){
final _that = this;
switch (_that) {
case _AccessControlResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'status_code')  int statusCode, @JsonKey(name: 'status_msg')  String statusMsg, @JsonKey(name: 'int_bulk_payment')  int intBulkPayment, @JsonKey(name: 'invoice_page_access')  int invoicePageAccess, @JsonKey(name: 'payment_hist_page_access')  int paymentHistPageAccess, @JsonKey(name: 'access_for_complaints')  int accessForComplaints, @JsonKey(name: 'int_stb_activation')  int intStbActivation, @JsonKey(name: 'int_stb_deactivation')  int intStbDeactivation, @JsonKey(name: 'int_stb_reactivation')  int intStbReactivation, @JsonKey(name: 'int_payment_transaction_report_access')  int pgTransactionReportAccess, @JsonKey(name: 'pgtransaction')  int pgtransaction)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccessControlResponse() when $default != null:
return $default(_that.statusCode,_that.statusMsg,_that.intBulkPayment,_that.invoicePageAccess,_that.paymentHistPageAccess,_that.accessForComplaints,_that.intStbActivation,_that.intStbDeactivation,_that.intStbReactivation,_that.pgTransactionReportAccess,_that.pgtransaction);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'status_code')  int statusCode, @JsonKey(name: 'status_msg')  String statusMsg, @JsonKey(name: 'int_bulk_payment')  int intBulkPayment, @JsonKey(name: 'invoice_page_access')  int invoicePageAccess, @JsonKey(name: 'payment_hist_page_access')  int paymentHistPageAccess, @JsonKey(name: 'access_for_complaints')  int accessForComplaints, @JsonKey(name: 'int_stb_activation')  int intStbActivation, @JsonKey(name: 'int_stb_deactivation')  int intStbDeactivation, @JsonKey(name: 'int_stb_reactivation')  int intStbReactivation, @JsonKey(name: 'int_payment_transaction_report_access')  int pgTransactionReportAccess, @JsonKey(name: 'pgtransaction')  int pgtransaction)  $default,) {final _that = this;
switch (_that) {
case _AccessControlResponse():
return $default(_that.statusCode,_that.statusMsg,_that.intBulkPayment,_that.invoicePageAccess,_that.paymentHistPageAccess,_that.accessForComplaints,_that.intStbActivation,_that.intStbDeactivation,_that.intStbReactivation,_that.pgTransactionReportAccess,_that.pgtransaction);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'status_code')  int statusCode, @JsonKey(name: 'status_msg')  String statusMsg, @JsonKey(name: 'int_bulk_payment')  int intBulkPayment, @JsonKey(name: 'invoice_page_access')  int invoicePageAccess, @JsonKey(name: 'payment_hist_page_access')  int paymentHistPageAccess, @JsonKey(name: 'access_for_complaints')  int accessForComplaints, @JsonKey(name: 'int_stb_activation')  int intStbActivation, @JsonKey(name: 'int_stb_deactivation')  int intStbDeactivation, @JsonKey(name: 'int_stb_reactivation')  int intStbReactivation, @JsonKey(name: 'int_payment_transaction_report_access')  int pgTransactionReportAccess, @JsonKey(name: 'pgtransaction')  int pgtransaction)?  $default,) {final _that = this;
switch (_that) {
case _AccessControlResponse() when $default != null:
return $default(_that.statusCode,_that.statusMsg,_that.intBulkPayment,_that.invoicePageAccess,_that.paymentHistPageAccess,_that.accessForComplaints,_that.intStbActivation,_that.intStbDeactivation,_that.intStbReactivation,_that.pgTransactionReportAccess,_that.pgtransaction);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AccessControlResponse implements AccessControlResponse {
  const _AccessControlResponse({@JsonKey(name: 'status_code') this.statusCode = 1, @JsonKey(name: 'status_msg') this.statusMsg = '', @JsonKey(name: 'int_bulk_payment') this.intBulkPayment = 1, @JsonKey(name: 'invoice_page_access') this.invoicePageAccess = 1, @JsonKey(name: 'payment_hist_page_access') this.paymentHistPageAccess = 1, @JsonKey(name: 'access_for_complaints') this.accessForComplaints = 1, @JsonKey(name: 'int_stb_activation') this.intStbActivation = 1, @JsonKey(name: 'int_stb_deactivation') this.intStbDeactivation = 1, @JsonKey(name: 'int_stb_reactivation') this.intStbReactivation = 1, @JsonKey(name: 'int_payment_transaction_report_access') this.pgTransactionReportAccess = 0, @JsonKey(name: 'pgtransaction') this.pgtransaction = 0});
  factory _AccessControlResponse.fromJson(Map<String, dynamic> json) => _$AccessControlResponseFromJson(json);

// status_code 0 = success (inverted convention!)
@override@JsonKey(name: 'status_code') final  int statusCode;
@override@JsonKey(name: 'status_msg') final  String statusMsg;
@override@JsonKey(name: 'int_bulk_payment') final  int intBulkPayment;
@override@JsonKey(name: 'invoice_page_access') final  int invoicePageAccess;
@override@JsonKey(name: 'payment_hist_page_access') final  int paymentHistPageAccess;
@override@JsonKey(name: 'access_for_complaints') final  int accessForComplaints;
@override@JsonKey(name: 'int_stb_activation') final  int intStbActivation;
@override@JsonKey(name: 'int_stb_deactivation') final  int intStbDeactivation;
@override@JsonKey(name: 'int_stb_reactivation') final  int intStbReactivation;
@override@JsonKey(name: 'int_payment_transaction_report_access') final  int pgTransactionReportAccess;
@override@JsonKey(name: 'pgtransaction') final  int pgtransaction;

/// Create a copy of AccessControlResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccessControlResponseCopyWith<_AccessControlResponse> get copyWith => __$AccessControlResponseCopyWithImpl<_AccessControlResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccessControlResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccessControlResponse&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.statusMsg, statusMsg) || other.statusMsg == statusMsg)&&(identical(other.intBulkPayment, intBulkPayment) || other.intBulkPayment == intBulkPayment)&&(identical(other.invoicePageAccess, invoicePageAccess) || other.invoicePageAccess == invoicePageAccess)&&(identical(other.paymentHistPageAccess, paymentHistPageAccess) || other.paymentHistPageAccess == paymentHistPageAccess)&&(identical(other.accessForComplaints, accessForComplaints) || other.accessForComplaints == accessForComplaints)&&(identical(other.intStbActivation, intStbActivation) || other.intStbActivation == intStbActivation)&&(identical(other.intStbDeactivation, intStbDeactivation) || other.intStbDeactivation == intStbDeactivation)&&(identical(other.intStbReactivation, intStbReactivation) || other.intStbReactivation == intStbReactivation)&&(identical(other.pgTransactionReportAccess, pgTransactionReportAccess) || other.pgTransactionReportAccess == pgTransactionReportAccess)&&(identical(other.pgtransaction, pgtransaction) || other.pgtransaction == pgtransaction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,statusCode,statusMsg,intBulkPayment,invoicePageAccess,paymentHistPageAccess,accessForComplaints,intStbActivation,intStbDeactivation,intStbReactivation,pgTransactionReportAccess,pgtransaction);

@override
String toString() {
  return 'AccessControlResponse(statusCode: $statusCode, statusMsg: $statusMsg, intBulkPayment: $intBulkPayment, invoicePageAccess: $invoicePageAccess, paymentHistPageAccess: $paymentHistPageAccess, accessForComplaints: $accessForComplaints, intStbActivation: $intStbActivation, intStbDeactivation: $intStbDeactivation, intStbReactivation: $intStbReactivation, pgTransactionReportAccess: $pgTransactionReportAccess, pgtransaction: $pgtransaction)';
}


}

/// @nodoc
abstract mixin class _$AccessControlResponseCopyWith<$Res> implements $AccessControlResponseCopyWith<$Res> {
  factory _$AccessControlResponseCopyWith(_AccessControlResponse value, $Res Function(_AccessControlResponse) _then) = __$AccessControlResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'status_code') int statusCode,@JsonKey(name: 'status_msg') String statusMsg,@JsonKey(name: 'int_bulk_payment') int intBulkPayment,@JsonKey(name: 'invoice_page_access') int invoicePageAccess,@JsonKey(name: 'payment_hist_page_access') int paymentHistPageAccess,@JsonKey(name: 'access_for_complaints') int accessForComplaints,@JsonKey(name: 'int_stb_activation') int intStbActivation,@JsonKey(name: 'int_stb_deactivation') int intStbDeactivation,@JsonKey(name: 'int_stb_reactivation') int intStbReactivation,@JsonKey(name: 'int_payment_transaction_report_access') int pgTransactionReportAccess,@JsonKey(name: 'pgtransaction') int pgtransaction
});




}
/// @nodoc
class __$AccessControlResponseCopyWithImpl<$Res>
    implements _$AccessControlResponseCopyWith<$Res> {
  __$AccessControlResponseCopyWithImpl(this._self, this._then);

  final _AccessControlResponse _self;
  final $Res Function(_AccessControlResponse) _then;

/// Create a copy of AccessControlResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? statusCode = null,Object? statusMsg = null,Object? intBulkPayment = null,Object? invoicePageAccess = null,Object? paymentHistPageAccess = null,Object? accessForComplaints = null,Object? intStbActivation = null,Object? intStbDeactivation = null,Object? intStbReactivation = null,Object? pgTransactionReportAccess = null,Object? pgtransaction = null,}) {
  return _then(_AccessControlResponse(
statusCode: null == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int,statusMsg: null == statusMsg ? _self.statusMsg : statusMsg // ignore: cast_nullable_to_non_nullable
as String,intBulkPayment: null == intBulkPayment ? _self.intBulkPayment : intBulkPayment // ignore: cast_nullable_to_non_nullable
as int,invoicePageAccess: null == invoicePageAccess ? _self.invoicePageAccess : invoicePageAccess // ignore: cast_nullable_to_non_nullable
as int,paymentHistPageAccess: null == paymentHistPageAccess ? _self.paymentHistPageAccess : paymentHistPageAccess // ignore: cast_nullable_to_non_nullable
as int,accessForComplaints: null == accessForComplaints ? _self.accessForComplaints : accessForComplaints // ignore: cast_nullable_to_non_nullable
as int,intStbActivation: null == intStbActivation ? _self.intStbActivation : intStbActivation // ignore: cast_nullable_to_non_nullable
as int,intStbDeactivation: null == intStbDeactivation ? _self.intStbDeactivation : intStbDeactivation // ignore: cast_nullable_to_non_nullable
as int,intStbReactivation: null == intStbReactivation ? _self.intStbReactivation : intStbReactivation // ignore: cast_nullable_to_non_nullable
as int,pgTransactionReportAccess: null == pgTransactionReportAccess ? _self.pgTransactionReportAccess : pgTransactionReportAccess // ignore: cast_nullable_to_non_nullable
as int,pgtransaction: null == pgtransaction ? _self.pgtransaction : pgtransaction // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
