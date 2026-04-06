// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bill_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BillDetail {

@JsonKey(name: 'lcoShare') double get lcoShare;@JsonKey(name: 'msoShare') double get msoShare;@JsonKey(name: 'totalAmount') double get totalAmount;@JsonKey(name: 'ncfDisplayName') String? get ncfDisplayName;@JsonKey(name: 'ncfTotalAmount') double get ncfTotalAmount;@JsonKey(name: 'encfDisplayName') String? get encfDisplayName;@JsonKey(name: 'encfTotalAmount') double get encfTotalAmount;@JsonKey(name: 'enumAddOnAfterBase') int get enumAddOnAfterBase;@JsonKey(name: 'enableProrataDiscount') int get enableProrataDiscount;
/// Create a copy of BillDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillDetailCopyWith<BillDetail> get copyWith => _$BillDetailCopyWithImpl<BillDetail>(this as BillDetail, _$identity);

  /// Serializes this BillDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillDetail&&(identical(other.lcoShare, lcoShare) || other.lcoShare == lcoShare)&&(identical(other.msoShare, msoShare) || other.msoShare == msoShare)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.ncfDisplayName, ncfDisplayName) || other.ncfDisplayName == ncfDisplayName)&&(identical(other.ncfTotalAmount, ncfTotalAmount) || other.ncfTotalAmount == ncfTotalAmount)&&(identical(other.encfDisplayName, encfDisplayName) || other.encfDisplayName == encfDisplayName)&&(identical(other.encfTotalAmount, encfTotalAmount) || other.encfTotalAmount == encfTotalAmount)&&(identical(other.enumAddOnAfterBase, enumAddOnAfterBase) || other.enumAddOnAfterBase == enumAddOnAfterBase)&&(identical(other.enableProrataDiscount, enableProrataDiscount) || other.enableProrataDiscount == enableProrataDiscount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,lcoShare,msoShare,totalAmount,ncfDisplayName,ncfTotalAmount,encfDisplayName,encfTotalAmount,enumAddOnAfterBase,enableProrataDiscount);

@override
String toString() {
  return 'BillDetail(lcoShare: $lcoShare, msoShare: $msoShare, totalAmount: $totalAmount, ncfDisplayName: $ncfDisplayName, ncfTotalAmount: $ncfTotalAmount, encfDisplayName: $encfDisplayName, encfTotalAmount: $encfTotalAmount, enumAddOnAfterBase: $enumAddOnAfterBase, enableProrataDiscount: $enableProrataDiscount)';
}


}

/// @nodoc
abstract mixin class $BillDetailCopyWith<$Res>  {
  factory $BillDetailCopyWith(BillDetail value, $Res Function(BillDetail) _then) = _$BillDetailCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'lcoShare') double lcoShare,@JsonKey(name: 'msoShare') double msoShare,@JsonKey(name: 'totalAmount') double totalAmount,@JsonKey(name: 'ncfDisplayName') String? ncfDisplayName,@JsonKey(name: 'ncfTotalAmount') double ncfTotalAmount,@JsonKey(name: 'encfDisplayName') String? encfDisplayName,@JsonKey(name: 'encfTotalAmount') double encfTotalAmount,@JsonKey(name: 'enumAddOnAfterBase') int enumAddOnAfterBase,@JsonKey(name: 'enableProrataDiscount') int enableProrataDiscount
});




}
/// @nodoc
class _$BillDetailCopyWithImpl<$Res>
    implements $BillDetailCopyWith<$Res> {
  _$BillDetailCopyWithImpl(this._self, this._then);

  final BillDetail _self;
  final $Res Function(BillDetail) _then;

/// Create a copy of BillDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lcoShare = null,Object? msoShare = null,Object? totalAmount = null,Object? ncfDisplayName = freezed,Object? ncfTotalAmount = null,Object? encfDisplayName = freezed,Object? encfTotalAmount = null,Object? enumAddOnAfterBase = null,Object? enableProrataDiscount = null,}) {
  return _then(_self.copyWith(
lcoShare: null == lcoShare ? _self.lcoShare : lcoShare // ignore: cast_nullable_to_non_nullable
as double,msoShare: null == msoShare ? _self.msoShare : msoShare // ignore: cast_nullable_to_non_nullable
as double,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,ncfDisplayName: freezed == ncfDisplayName ? _self.ncfDisplayName : ncfDisplayName // ignore: cast_nullable_to_non_nullable
as String?,ncfTotalAmount: null == ncfTotalAmount ? _self.ncfTotalAmount : ncfTotalAmount // ignore: cast_nullable_to_non_nullable
as double,encfDisplayName: freezed == encfDisplayName ? _self.encfDisplayName : encfDisplayName // ignore: cast_nullable_to_non_nullable
as String?,encfTotalAmount: null == encfTotalAmount ? _self.encfTotalAmount : encfTotalAmount // ignore: cast_nullable_to_non_nullable
as double,enumAddOnAfterBase: null == enumAddOnAfterBase ? _self.enumAddOnAfterBase : enumAddOnAfterBase // ignore: cast_nullable_to_non_nullable
as int,enableProrataDiscount: null == enableProrataDiscount ? _self.enableProrataDiscount : enableProrataDiscount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BillDetail].
extension BillDetailPatterns on BillDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BillDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BillDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BillDetail value)  $default,){
final _that = this;
switch (_that) {
case _BillDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BillDetail value)?  $default,){
final _that = this;
switch (_that) {
case _BillDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'lcoShare')  double lcoShare, @JsonKey(name: 'msoShare')  double msoShare, @JsonKey(name: 'totalAmount')  double totalAmount, @JsonKey(name: 'ncfDisplayName')  String? ncfDisplayName, @JsonKey(name: 'ncfTotalAmount')  double ncfTotalAmount, @JsonKey(name: 'encfDisplayName')  String? encfDisplayName, @JsonKey(name: 'encfTotalAmount')  double encfTotalAmount, @JsonKey(name: 'enumAddOnAfterBase')  int enumAddOnAfterBase, @JsonKey(name: 'enableProrataDiscount')  int enableProrataDiscount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BillDetail() when $default != null:
return $default(_that.lcoShare,_that.msoShare,_that.totalAmount,_that.ncfDisplayName,_that.ncfTotalAmount,_that.encfDisplayName,_that.encfTotalAmount,_that.enumAddOnAfterBase,_that.enableProrataDiscount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'lcoShare')  double lcoShare, @JsonKey(name: 'msoShare')  double msoShare, @JsonKey(name: 'totalAmount')  double totalAmount, @JsonKey(name: 'ncfDisplayName')  String? ncfDisplayName, @JsonKey(name: 'ncfTotalAmount')  double ncfTotalAmount, @JsonKey(name: 'encfDisplayName')  String? encfDisplayName, @JsonKey(name: 'encfTotalAmount')  double encfTotalAmount, @JsonKey(name: 'enumAddOnAfterBase')  int enumAddOnAfterBase, @JsonKey(name: 'enableProrataDiscount')  int enableProrataDiscount)  $default,) {final _that = this;
switch (_that) {
case _BillDetail():
return $default(_that.lcoShare,_that.msoShare,_that.totalAmount,_that.ncfDisplayName,_that.ncfTotalAmount,_that.encfDisplayName,_that.encfTotalAmount,_that.enumAddOnAfterBase,_that.enableProrataDiscount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'lcoShare')  double lcoShare, @JsonKey(name: 'msoShare')  double msoShare, @JsonKey(name: 'totalAmount')  double totalAmount, @JsonKey(name: 'ncfDisplayName')  String? ncfDisplayName, @JsonKey(name: 'ncfTotalAmount')  double ncfTotalAmount, @JsonKey(name: 'encfDisplayName')  String? encfDisplayName, @JsonKey(name: 'encfTotalAmount')  double encfTotalAmount, @JsonKey(name: 'enumAddOnAfterBase')  int enumAddOnAfterBase, @JsonKey(name: 'enableProrataDiscount')  int enableProrataDiscount)?  $default,) {final _that = this;
switch (_that) {
case _BillDetail() when $default != null:
return $default(_that.lcoShare,_that.msoShare,_that.totalAmount,_that.ncfDisplayName,_that.ncfTotalAmount,_that.encfDisplayName,_that.encfTotalAmount,_that.enumAddOnAfterBase,_that.enableProrataDiscount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BillDetail implements BillDetail {
  const _BillDetail({@JsonKey(name: 'lcoShare') this.lcoShare = 0.0, @JsonKey(name: 'msoShare') this.msoShare = 0.0, @JsonKey(name: 'totalAmount') this.totalAmount = 0.0, @JsonKey(name: 'ncfDisplayName') this.ncfDisplayName, @JsonKey(name: 'ncfTotalAmount') this.ncfTotalAmount = 0.0, @JsonKey(name: 'encfDisplayName') this.encfDisplayName, @JsonKey(name: 'encfTotalAmount') this.encfTotalAmount = 0.0, @JsonKey(name: 'enumAddOnAfterBase') this.enumAddOnAfterBase = 0, @JsonKey(name: 'enableProrataDiscount') this.enableProrataDiscount = 0});
  factory _BillDetail.fromJson(Map<String, dynamic> json) => _$BillDetailFromJson(json);

@override@JsonKey(name: 'lcoShare') final  double lcoShare;
@override@JsonKey(name: 'msoShare') final  double msoShare;
@override@JsonKey(name: 'totalAmount') final  double totalAmount;
@override@JsonKey(name: 'ncfDisplayName') final  String? ncfDisplayName;
@override@JsonKey(name: 'ncfTotalAmount') final  double ncfTotalAmount;
@override@JsonKey(name: 'encfDisplayName') final  String? encfDisplayName;
@override@JsonKey(name: 'encfTotalAmount') final  double encfTotalAmount;
@override@JsonKey(name: 'enumAddOnAfterBase') final  int enumAddOnAfterBase;
@override@JsonKey(name: 'enableProrataDiscount') final  int enableProrataDiscount;

/// Create a copy of BillDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BillDetailCopyWith<_BillDetail> get copyWith => __$BillDetailCopyWithImpl<_BillDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BillDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BillDetail&&(identical(other.lcoShare, lcoShare) || other.lcoShare == lcoShare)&&(identical(other.msoShare, msoShare) || other.msoShare == msoShare)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.ncfDisplayName, ncfDisplayName) || other.ncfDisplayName == ncfDisplayName)&&(identical(other.ncfTotalAmount, ncfTotalAmount) || other.ncfTotalAmount == ncfTotalAmount)&&(identical(other.encfDisplayName, encfDisplayName) || other.encfDisplayName == encfDisplayName)&&(identical(other.encfTotalAmount, encfTotalAmount) || other.encfTotalAmount == encfTotalAmount)&&(identical(other.enumAddOnAfterBase, enumAddOnAfterBase) || other.enumAddOnAfterBase == enumAddOnAfterBase)&&(identical(other.enableProrataDiscount, enableProrataDiscount) || other.enableProrataDiscount == enableProrataDiscount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,lcoShare,msoShare,totalAmount,ncfDisplayName,ncfTotalAmount,encfDisplayName,encfTotalAmount,enumAddOnAfterBase,enableProrataDiscount);

@override
String toString() {
  return 'BillDetail(lcoShare: $lcoShare, msoShare: $msoShare, totalAmount: $totalAmount, ncfDisplayName: $ncfDisplayName, ncfTotalAmount: $ncfTotalAmount, encfDisplayName: $encfDisplayName, encfTotalAmount: $encfTotalAmount, enumAddOnAfterBase: $enumAddOnAfterBase, enableProrataDiscount: $enableProrataDiscount)';
}


}

/// @nodoc
abstract mixin class _$BillDetailCopyWith<$Res> implements $BillDetailCopyWith<$Res> {
  factory _$BillDetailCopyWith(_BillDetail value, $Res Function(_BillDetail) _then) = __$BillDetailCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'lcoShare') double lcoShare,@JsonKey(name: 'msoShare') double msoShare,@JsonKey(name: 'totalAmount') double totalAmount,@JsonKey(name: 'ncfDisplayName') String? ncfDisplayName,@JsonKey(name: 'ncfTotalAmount') double ncfTotalAmount,@JsonKey(name: 'encfDisplayName') String? encfDisplayName,@JsonKey(name: 'encfTotalAmount') double encfTotalAmount,@JsonKey(name: 'enumAddOnAfterBase') int enumAddOnAfterBase,@JsonKey(name: 'enableProrataDiscount') int enableProrataDiscount
});




}
/// @nodoc
class __$BillDetailCopyWithImpl<$Res>
    implements _$BillDetailCopyWith<$Res> {
  __$BillDetailCopyWithImpl(this._self, this._then);

  final _BillDetail _self;
  final $Res Function(_BillDetail) _then;

/// Create a copy of BillDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lcoShare = null,Object? msoShare = null,Object? totalAmount = null,Object? ncfDisplayName = freezed,Object? ncfTotalAmount = null,Object? encfDisplayName = freezed,Object? encfTotalAmount = null,Object? enumAddOnAfterBase = null,Object? enableProrataDiscount = null,}) {
  return _then(_BillDetail(
lcoShare: null == lcoShare ? _self.lcoShare : lcoShare // ignore: cast_nullable_to_non_nullable
as double,msoShare: null == msoShare ? _self.msoShare : msoShare // ignore: cast_nullable_to_non_nullable
as double,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,ncfDisplayName: freezed == ncfDisplayName ? _self.ncfDisplayName : ncfDisplayName // ignore: cast_nullable_to_non_nullable
as String?,ncfTotalAmount: null == ncfTotalAmount ? _self.ncfTotalAmount : ncfTotalAmount // ignore: cast_nullable_to_non_nullable
as double,encfDisplayName: freezed == encfDisplayName ? _self.encfDisplayName : encfDisplayName // ignore: cast_nullable_to_non_nullable
as String?,encfTotalAmount: null == encfTotalAmount ? _self.encfTotalAmount : encfTotalAmount // ignore: cast_nullable_to_non_nullable
as double,enumAddOnAfterBase: null == enumAddOnAfterBase ? _self.enumAddOnAfterBase : enumAddOnAfterBase // ignore: cast_nullable_to_non_nullable
as int,enableProrataDiscount: null == enableProrataDiscount ? _self.enableProrataDiscount : enableProrataDiscount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
