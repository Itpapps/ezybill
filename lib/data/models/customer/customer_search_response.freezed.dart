// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer_search_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CustomerSearchResponse {

@JsonKey(name: 'statusCode') int get statusCode;@JsonKey(name: 'statusMessage') String? get statusMsg;@JsonKey(name: 'customerCount') int get customerCount;@JsonKey(name: 'lco_share') double get lcoShare;@JsonKey(name: 'total_amount') double get totalAmount;@JsonKey(name: 'mso_share') double get msoShare;@JsonKey(name: 'baid_label') String? get baidLabel;@JsonKey(name: 'customerDetailsList') List<CustomerModel> get existCustomerDetails;
/// Create a copy of CustomerSearchResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerSearchResponseCopyWith<CustomerSearchResponse> get copyWith => _$CustomerSearchResponseCopyWithImpl<CustomerSearchResponse>(this as CustomerSearchResponse, _$identity);

  /// Serializes this CustomerSearchResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerSearchResponse&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.statusMsg, statusMsg) || other.statusMsg == statusMsg)&&(identical(other.customerCount, customerCount) || other.customerCount == customerCount)&&(identical(other.lcoShare, lcoShare) || other.lcoShare == lcoShare)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.msoShare, msoShare) || other.msoShare == msoShare)&&(identical(other.baidLabel, baidLabel) || other.baidLabel == baidLabel)&&const DeepCollectionEquality().equals(other.existCustomerDetails, existCustomerDetails));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,statusCode,statusMsg,customerCount,lcoShare,totalAmount,msoShare,baidLabel,const DeepCollectionEquality().hash(existCustomerDetails));

@override
String toString() {
  return 'CustomerSearchResponse(statusCode: $statusCode, statusMsg: $statusMsg, customerCount: $customerCount, lcoShare: $lcoShare, totalAmount: $totalAmount, msoShare: $msoShare, baidLabel: $baidLabel, existCustomerDetails: $existCustomerDetails)';
}


}

/// @nodoc
abstract mixin class $CustomerSearchResponseCopyWith<$Res>  {
  factory $CustomerSearchResponseCopyWith(CustomerSearchResponse value, $Res Function(CustomerSearchResponse) _then) = _$CustomerSearchResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'statusCode') int statusCode,@JsonKey(name: 'statusMessage') String? statusMsg,@JsonKey(name: 'customerCount') int customerCount,@JsonKey(name: 'lco_share') double lcoShare,@JsonKey(name: 'total_amount') double totalAmount,@JsonKey(name: 'mso_share') double msoShare,@JsonKey(name: 'baid_label') String? baidLabel,@JsonKey(name: 'customerDetailsList') List<CustomerModel> existCustomerDetails
});




}
/// @nodoc
class _$CustomerSearchResponseCopyWithImpl<$Res>
    implements $CustomerSearchResponseCopyWith<$Res> {
  _$CustomerSearchResponseCopyWithImpl(this._self, this._then);

  final CustomerSearchResponse _self;
  final $Res Function(CustomerSearchResponse) _then;

/// Create a copy of CustomerSearchResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? statusCode = null,Object? statusMsg = freezed,Object? customerCount = null,Object? lcoShare = null,Object? totalAmount = null,Object? msoShare = null,Object? baidLabel = freezed,Object? existCustomerDetails = null,}) {
  return _then(_self.copyWith(
statusCode: null == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int,statusMsg: freezed == statusMsg ? _self.statusMsg : statusMsg // ignore: cast_nullable_to_non_nullable
as String?,customerCount: null == customerCount ? _self.customerCount : customerCount // ignore: cast_nullable_to_non_nullable
as int,lcoShare: null == lcoShare ? _self.lcoShare : lcoShare // ignore: cast_nullable_to_non_nullable
as double,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,msoShare: null == msoShare ? _self.msoShare : msoShare // ignore: cast_nullable_to_non_nullable
as double,baidLabel: freezed == baidLabel ? _self.baidLabel : baidLabel // ignore: cast_nullable_to_non_nullable
as String?,existCustomerDetails: null == existCustomerDetails ? _self.existCustomerDetails : existCustomerDetails // ignore: cast_nullable_to_non_nullable
as List<CustomerModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomerSearchResponse].
extension CustomerSearchResponsePatterns on CustomerSearchResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomerSearchResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomerSearchResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomerSearchResponse value)  $default,){
final _that = this;
switch (_that) {
case _CustomerSearchResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomerSearchResponse value)?  $default,){
final _that = this;
switch (_that) {
case _CustomerSearchResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'statusCode')  int statusCode, @JsonKey(name: 'statusMessage')  String? statusMsg, @JsonKey(name: 'customerCount')  int customerCount, @JsonKey(name: 'lco_share')  double lcoShare, @JsonKey(name: 'total_amount')  double totalAmount, @JsonKey(name: 'mso_share')  double msoShare, @JsonKey(name: 'baid_label')  String? baidLabel, @JsonKey(name: 'customerDetailsList')  List<CustomerModel> existCustomerDetails)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomerSearchResponse() when $default != null:
return $default(_that.statusCode,_that.statusMsg,_that.customerCount,_that.lcoShare,_that.totalAmount,_that.msoShare,_that.baidLabel,_that.existCustomerDetails);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'statusCode')  int statusCode, @JsonKey(name: 'statusMessage')  String? statusMsg, @JsonKey(name: 'customerCount')  int customerCount, @JsonKey(name: 'lco_share')  double lcoShare, @JsonKey(name: 'total_amount')  double totalAmount, @JsonKey(name: 'mso_share')  double msoShare, @JsonKey(name: 'baid_label')  String? baidLabel, @JsonKey(name: 'customerDetailsList')  List<CustomerModel> existCustomerDetails)  $default,) {final _that = this;
switch (_that) {
case _CustomerSearchResponse():
return $default(_that.statusCode,_that.statusMsg,_that.customerCount,_that.lcoShare,_that.totalAmount,_that.msoShare,_that.baidLabel,_that.existCustomerDetails);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'statusCode')  int statusCode, @JsonKey(name: 'statusMessage')  String? statusMsg, @JsonKey(name: 'customerCount')  int customerCount, @JsonKey(name: 'lco_share')  double lcoShare, @JsonKey(name: 'total_amount')  double totalAmount, @JsonKey(name: 'mso_share')  double msoShare, @JsonKey(name: 'baid_label')  String? baidLabel, @JsonKey(name: 'customerDetailsList')  List<CustomerModel> existCustomerDetails)?  $default,) {final _that = this;
switch (_that) {
case _CustomerSearchResponse() when $default != null:
return $default(_that.statusCode,_that.statusMsg,_that.customerCount,_that.lcoShare,_that.totalAmount,_that.msoShare,_that.baidLabel,_that.existCustomerDetails);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CustomerSearchResponse implements CustomerSearchResponse {
  const _CustomerSearchResponse({@JsonKey(name: 'statusCode') this.statusCode = 0, @JsonKey(name: 'statusMessage') this.statusMsg, @JsonKey(name: 'customerCount') this.customerCount = 0, @JsonKey(name: 'lco_share') this.lcoShare = 0.0, @JsonKey(name: 'total_amount') this.totalAmount = 0.0, @JsonKey(name: 'mso_share') this.msoShare = 0.0, @JsonKey(name: 'baid_label') this.baidLabel, @JsonKey(name: 'customerDetailsList') final  List<CustomerModel> existCustomerDetails = const []}): _existCustomerDetails = existCustomerDetails;
  factory _CustomerSearchResponse.fromJson(Map<String, dynamic> json) => _$CustomerSearchResponseFromJson(json);

@override@JsonKey(name: 'statusCode') final  int statusCode;
@override@JsonKey(name: 'statusMessage') final  String? statusMsg;
@override@JsonKey(name: 'customerCount') final  int customerCount;
@override@JsonKey(name: 'lco_share') final  double lcoShare;
@override@JsonKey(name: 'total_amount') final  double totalAmount;
@override@JsonKey(name: 'mso_share') final  double msoShare;
@override@JsonKey(name: 'baid_label') final  String? baidLabel;
 final  List<CustomerModel> _existCustomerDetails;
@override@JsonKey(name: 'customerDetailsList') List<CustomerModel> get existCustomerDetails {
  if (_existCustomerDetails is EqualUnmodifiableListView) return _existCustomerDetails;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_existCustomerDetails);
}


/// Create a copy of CustomerSearchResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerSearchResponseCopyWith<_CustomerSearchResponse> get copyWith => __$CustomerSearchResponseCopyWithImpl<_CustomerSearchResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomerSearchResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomerSearchResponse&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.statusMsg, statusMsg) || other.statusMsg == statusMsg)&&(identical(other.customerCount, customerCount) || other.customerCount == customerCount)&&(identical(other.lcoShare, lcoShare) || other.lcoShare == lcoShare)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.msoShare, msoShare) || other.msoShare == msoShare)&&(identical(other.baidLabel, baidLabel) || other.baidLabel == baidLabel)&&const DeepCollectionEquality().equals(other._existCustomerDetails, _existCustomerDetails));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,statusCode,statusMsg,customerCount,lcoShare,totalAmount,msoShare,baidLabel,const DeepCollectionEquality().hash(_existCustomerDetails));

@override
String toString() {
  return 'CustomerSearchResponse(statusCode: $statusCode, statusMsg: $statusMsg, customerCount: $customerCount, lcoShare: $lcoShare, totalAmount: $totalAmount, msoShare: $msoShare, baidLabel: $baidLabel, existCustomerDetails: $existCustomerDetails)';
}


}

/// @nodoc
abstract mixin class _$CustomerSearchResponseCopyWith<$Res> implements $CustomerSearchResponseCopyWith<$Res> {
  factory _$CustomerSearchResponseCopyWith(_CustomerSearchResponse value, $Res Function(_CustomerSearchResponse) _then) = __$CustomerSearchResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'statusCode') int statusCode,@JsonKey(name: 'statusMessage') String? statusMsg,@JsonKey(name: 'customerCount') int customerCount,@JsonKey(name: 'lco_share') double lcoShare,@JsonKey(name: 'total_amount') double totalAmount,@JsonKey(name: 'mso_share') double msoShare,@JsonKey(name: 'baid_label') String? baidLabel,@JsonKey(name: 'customerDetailsList') List<CustomerModel> existCustomerDetails
});




}
/// @nodoc
class __$CustomerSearchResponseCopyWithImpl<$Res>
    implements _$CustomerSearchResponseCopyWith<$Res> {
  __$CustomerSearchResponseCopyWithImpl(this._self, this._then);

  final _CustomerSearchResponse _self;
  final $Res Function(_CustomerSearchResponse) _then;

/// Create a copy of CustomerSearchResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? statusCode = null,Object? statusMsg = freezed,Object? customerCount = null,Object? lcoShare = null,Object? totalAmount = null,Object? msoShare = null,Object? baidLabel = freezed,Object? existCustomerDetails = null,}) {
  return _then(_CustomerSearchResponse(
statusCode: null == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int,statusMsg: freezed == statusMsg ? _self.statusMsg : statusMsg // ignore: cast_nullable_to_non_nullable
as String?,customerCount: null == customerCount ? _self.customerCount : customerCount // ignore: cast_nullable_to_non_nullable
as int,lcoShare: null == lcoShare ? _self.lcoShare : lcoShare // ignore: cast_nullable_to_non_nullable
as double,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,msoShare: null == msoShare ? _self.msoShare : msoShare // ignore: cast_nullable_to_non_nullable
as double,baidLabel: freezed == baidLabel ? _self.baidLabel : baidLabel // ignore: cast_nullable_to_non_nullable
as String?,existCustomerDetails: null == existCustomerDetails ? _self._existCustomerDetails : existCustomerDetails // ignore: cast_nullable_to_non_nullable
as List<CustomerModel>,
  ));
}


}

// dart format on
