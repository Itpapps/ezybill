// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invoice_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InvoiceItem {

@JsonKey(name: 'billingId') String get billingId;@JsonKey(name: 'billDate') String get billDate;@JsonKey(name: 'dueDate') String get dueDate;@JsonKey(name: 'totalAmount') double get totalAmount;@JsonKey(name: 'quantity') int get quantity;@JsonKey(name: 'basePrice') double get basePrice;@JsonKey(name: 'serialNumber') String get serialNumber;@JsonKey(name: 'macVcNumber') String get macVcNumber;@JsonKey(name: 'pname') String get pname;@JsonKey(name: 'setupPrice') double get setupPrice;@JsonKey(name: 'taxAmount') double get taxAmount;@JsonKey(name: 'pendingAmount') double get pendingAmount;@JsonKey(name: 'discountAmount') double get discountAmount;@JsonKey(name: 'isAdhoc') int get isAdhoc;
/// Create a copy of InvoiceItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvoiceItemCopyWith<InvoiceItem> get copyWith => _$InvoiceItemCopyWithImpl<InvoiceItem>(this as InvoiceItem, _$identity);

  /// Serializes this InvoiceItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvoiceItem&&(identical(other.billingId, billingId) || other.billingId == billingId)&&(identical(other.billDate, billDate) || other.billDate == billDate)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.basePrice, basePrice) || other.basePrice == basePrice)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.macVcNumber, macVcNumber) || other.macVcNumber == macVcNumber)&&(identical(other.pname, pname) || other.pname == pname)&&(identical(other.setupPrice, setupPrice) || other.setupPrice == setupPrice)&&(identical(other.taxAmount, taxAmount) || other.taxAmount == taxAmount)&&(identical(other.pendingAmount, pendingAmount) || other.pendingAmount == pendingAmount)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.isAdhoc, isAdhoc) || other.isAdhoc == isAdhoc));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,billingId,billDate,dueDate,totalAmount,quantity,basePrice,serialNumber,macVcNumber,pname,setupPrice,taxAmount,pendingAmount,discountAmount,isAdhoc);

@override
String toString() {
  return 'InvoiceItem(billingId: $billingId, billDate: $billDate, dueDate: $dueDate, totalAmount: $totalAmount, quantity: $quantity, basePrice: $basePrice, serialNumber: $serialNumber, macVcNumber: $macVcNumber, pname: $pname, setupPrice: $setupPrice, taxAmount: $taxAmount, pendingAmount: $pendingAmount, discountAmount: $discountAmount, isAdhoc: $isAdhoc)';
}


}

/// @nodoc
abstract mixin class $InvoiceItemCopyWith<$Res>  {
  factory $InvoiceItemCopyWith(InvoiceItem value, $Res Function(InvoiceItem) _then) = _$InvoiceItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'billingId') String billingId,@JsonKey(name: 'billDate') String billDate,@JsonKey(name: 'dueDate') String dueDate,@JsonKey(name: 'totalAmount') double totalAmount,@JsonKey(name: 'quantity') int quantity,@JsonKey(name: 'basePrice') double basePrice,@JsonKey(name: 'serialNumber') String serialNumber,@JsonKey(name: 'macVcNumber') String macVcNumber,@JsonKey(name: 'pname') String pname,@JsonKey(name: 'setupPrice') double setupPrice,@JsonKey(name: 'taxAmount') double taxAmount,@JsonKey(name: 'pendingAmount') double pendingAmount,@JsonKey(name: 'discountAmount') double discountAmount,@JsonKey(name: 'isAdhoc') int isAdhoc
});




}
/// @nodoc
class _$InvoiceItemCopyWithImpl<$Res>
    implements $InvoiceItemCopyWith<$Res> {
  _$InvoiceItemCopyWithImpl(this._self, this._then);

  final InvoiceItem _self;
  final $Res Function(InvoiceItem) _then;

/// Create a copy of InvoiceItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? billingId = null,Object? billDate = null,Object? dueDate = null,Object? totalAmount = null,Object? quantity = null,Object? basePrice = null,Object? serialNumber = null,Object? macVcNumber = null,Object? pname = null,Object? setupPrice = null,Object? taxAmount = null,Object? pendingAmount = null,Object? discountAmount = null,Object? isAdhoc = null,}) {
  return _then(_self.copyWith(
billingId: null == billingId ? _self.billingId : billingId // ignore: cast_nullable_to_non_nullable
as String,billDate: null == billDate ? _self.billDate : billDate // ignore: cast_nullable_to_non_nullable
as String,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,basePrice: null == basePrice ? _self.basePrice : basePrice // ignore: cast_nullable_to_non_nullable
as double,serialNumber: null == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String,macVcNumber: null == macVcNumber ? _self.macVcNumber : macVcNumber // ignore: cast_nullable_to_non_nullable
as String,pname: null == pname ? _self.pname : pname // ignore: cast_nullable_to_non_nullable
as String,setupPrice: null == setupPrice ? _self.setupPrice : setupPrice // ignore: cast_nullable_to_non_nullable
as double,taxAmount: null == taxAmount ? _self.taxAmount : taxAmount // ignore: cast_nullable_to_non_nullable
as double,pendingAmount: null == pendingAmount ? _self.pendingAmount : pendingAmount // ignore: cast_nullable_to_non_nullable
as double,discountAmount: null == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as double,isAdhoc: null == isAdhoc ? _self.isAdhoc : isAdhoc // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [InvoiceItem].
extension InvoiceItemPatterns on InvoiceItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvoiceItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvoiceItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvoiceItem value)  $default,){
final _that = this;
switch (_that) {
case _InvoiceItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvoiceItem value)?  $default,){
final _that = this;
switch (_that) {
case _InvoiceItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'billingId')  String billingId, @JsonKey(name: 'billDate')  String billDate, @JsonKey(name: 'dueDate')  String dueDate, @JsonKey(name: 'totalAmount')  double totalAmount, @JsonKey(name: 'quantity')  int quantity, @JsonKey(name: 'basePrice')  double basePrice, @JsonKey(name: 'serialNumber')  String serialNumber, @JsonKey(name: 'macVcNumber')  String macVcNumber, @JsonKey(name: 'pname')  String pname, @JsonKey(name: 'setupPrice')  double setupPrice, @JsonKey(name: 'taxAmount')  double taxAmount, @JsonKey(name: 'pendingAmount')  double pendingAmount, @JsonKey(name: 'discountAmount')  double discountAmount, @JsonKey(name: 'isAdhoc')  int isAdhoc)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvoiceItem() when $default != null:
return $default(_that.billingId,_that.billDate,_that.dueDate,_that.totalAmount,_that.quantity,_that.basePrice,_that.serialNumber,_that.macVcNumber,_that.pname,_that.setupPrice,_that.taxAmount,_that.pendingAmount,_that.discountAmount,_that.isAdhoc);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'billingId')  String billingId, @JsonKey(name: 'billDate')  String billDate, @JsonKey(name: 'dueDate')  String dueDate, @JsonKey(name: 'totalAmount')  double totalAmount, @JsonKey(name: 'quantity')  int quantity, @JsonKey(name: 'basePrice')  double basePrice, @JsonKey(name: 'serialNumber')  String serialNumber, @JsonKey(name: 'macVcNumber')  String macVcNumber, @JsonKey(name: 'pname')  String pname, @JsonKey(name: 'setupPrice')  double setupPrice, @JsonKey(name: 'taxAmount')  double taxAmount, @JsonKey(name: 'pendingAmount')  double pendingAmount, @JsonKey(name: 'discountAmount')  double discountAmount, @JsonKey(name: 'isAdhoc')  int isAdhoc)  $default,) {final _that = this;
switch (_that) {
case _InvoiceItem():
return $default(_that.billingId,_that.billDate,_that.dueDate,_that.totalAmount,_that.quantity,_that.basePrice,_that.serialNumber,_that.macVcNumber,_that.pname,_that.setupPrice,_that.taxAmount,_that.pendingAmount,_that.discountAmount,_that.isAdhoc);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'billingId')  String billingId, @JsonKey(name: 'billDate')  String billDate, @JsonKey(name: 'dueDate')  String dueDate, @JsonKey(name: 'totalAmount')  double totalAmount, @JsonKey(name: 'quantity')  int quantity, @JsonKey(name: 'basePrice')  double basePrice, @JsonKey(name: 'serialNumber')  String serialNumber, @JsonKey(name: 'macVcNumber')  String macVcNumber, @JsonKey(name: 'pname')  String pname, @JsonKey(name: 'setupPrice')  double setupPrice, @JsonKey(name: 'taxAmount')  double taxAmount, @JsonKey(name: 'pendingAmount')  double pendingAmount, @JsonKey(name: 'discountAmount')  double discountAmount, @JsonKey(name: 'isAdhoc')  int isAdhoc)?  $default,) {final _that = this;
switch (_that) {
case _InvoiceItem() when $default != null:
return $default(_that.billingId,_that.billDate,_that.dueDate,_that.totalAmount,_that.quantity,_that.basePrice,_that.serialNumber,_that.macVcNumber,_that.pname,_that.setupPrice,_that.taxAmount,_that.pendingAmount,_that.discountAmount,_that.isAdhoc);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InvoiceItem implements InvoiceItem {
  const _InvoiceItem({@JsonKey(name: 'billingId') this.billingId = '', @JsonKey(name: 'billDate') this.billDate = '', @JsonKey(name: 'dueDate') this.dueDate = '', @JsonKey(name: 'totalAmount') this.totalAmount = 0.0, @JsonKey(name: 'quantity') this.quantity = 0, @JsonKey(name: 'basePrice') this.basePrice = 0.0, @JsonKey(name: 'serialNumber') this.serialNumber = '', @JsonKey(name: 'macVcNumber') this.macVcNumber = '', @JsonKey(name: 'pname') this.pname = '', @JsonKey(name: 'setupPrice') this.setupPrice = 0.0, @JsonKey(name: 'taxAmount') this.taxAmount = 0.0, @JsonKey(name: 'pendingAmount') this.pendingAmount = 0.0, @JsonKey(name: 'discountAmount') this.discountAmount = 0.0, @JsonKey(name: 'isAdhoc') this.isAdhoc = 0});
  factory _InvoiceItem.fromJson(Map<String, dynamic> json) => _$InvoiceItemFromJson(json);

@override@JsonKey(name: 'billingId') final  String billingId;
@override@JsonKey(name: 'billDate') final  String billDate;
@override@JsonKey(name: 'dueDate') final  String dueDate;
@override@JsonKey(name: 'totalAmount') final  double totalAmount;
@override@JsonKey(name: 'quantity') final  int quantity;
@override@JsonKey(name: 'basePrice') final  double basePrice;
@override@JsonKey(name: 'serialNumber') final  String serialNumber;
@override@JsonKey(name: 'macVcNumber') final  String macVcNumber;
@override@JsonKey(name: 'pname') final  String pname;
@override@JsonKey(name: 'setupPrice') final  double setupPrice;
@override@JsonKey(name: 'taxAmount') final  double taxAmount;
@override@JsonKey(name: 'pendingAmount') final  double pendingAmount;
@override@JsonKey(name: 'discountAmount') final  double discountAmount;
@override@JsonKey(name: 'isAdhoc') final  int isAdhoc;

/// Create a copy of InvoiceItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvoiceItemCopyWith<_InvoiceItem> get copyWith => __$InvoiceItemCopyWithImpl<_InvoiceItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvoiceItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvoiceItem&&(identical(other.billingId, billingId) || other.billingId == billingId)&&(identical(other.billDate, billDate) || other.billDate == billDate)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.basePrice, basePrice) || other.basePrice == basePrice)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.macVcNumber, macVcNumber) || other.macVcNumber == macVcNumber)&&(identical(other.pname, pname) || other.pname == pname)&&(identical(other.setupPrice, setupPrice) || other.setupPrice == setupPrice)&&(identical(other.taxAmount, taxAmount) || other.taxAmount == taxAmount)&&(identical(other.pendingAmount, pendingAmount) || other.pendingAmount == pendingAmount)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.isAdhoc, isAdhoc) || other.isAdhoc == isAdhoc));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,billingId,billDate,dueDate,totalAmount,quantity,basePrice,serialNumber,macVcNumber,pname,setupPrice,taxAmount,pendingAmount,discountAmount,isAdhoc);

@override
String toString() {
  return 'InvoiceItem(billingId: $billingId, billDate: $billDate, dueDate: $dueDate, totalAmount: $totalAmount, quantity: $quantity, basePrice: $basePrice, serialNumber: $serialNumber, macVcNumber: $macVcNumber, pname: $pname, setupPrice: $setupPrice, taxAmount: $taxAmount, pendingAmount: $pendingAmount, discountAmount: $discountAmount, isAdhoc: $isAdhoc)';
}


}

/// @nodoc
abstract mixin class _$InvoiceItemCopyWith<$Res> implements $InvoiceItemCopyWith<$Res> {
  factory _$InvoiceItemCopyWith(_InvoiceItem value, $Res Function(_InvoiceItem) _then) = __$InvoiceItemCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'billingId') String billingId,@JsonKey(name: 'billDate') String billDate,@JsonKey(name: 'dueDate') String dueDate,@JsonKey(name: 'totalAmount') double totalAmount,@JsonKey(name: 'quantity') int quantity,@JsonKey(name: 'basePrice') double basePrice,@JsonKey(name: 'serialNumber') String serialNumber,@JsonKey(name: 'macVcNumber') String macVcNumber,@JsonKey(name: 'pname') String pname,@JsonKey(name: 'setupPrice') double setupPrice,@JsonKey(name: 'taxAmount') double taxAmount,@JsonKey(name: 'pendingAmount') double pendingAmount,@JsonKey(name: 'discountAmount') double discountAmount,@JsonKey(name: 'isAdhoc') int isAdhoc
});




}
/// @nodoc
class __$InvoiceItemCopyWithImpl<$Res>
    implements _$InvoiceItemCopyWith<$Res> {
  __$InvoiceItemCopyWithImpl(this._self, this._then);

  final _InvoiceItem _self;
  final $Res Function(_InvoiceItem) _then;

/// Create a copy of InvoiceItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? billingId = null,Object? billDate = null,Object? dueDate = null,Object? totalAmount = null,Object? quantity = null,Object? basePrice = null,Object? serialNumber = null,Object? macVcNumber = null,Object? pname = null,Object? setupPrice = null,Object? taxAmount = null,Object? pendingAmount = null,Object? discountAmount = null,Object? isAdhoc = null,}) {
  return _then(_InvoiceItem(
billingId: null == billingId ? _self.billingId : billingId // ignore: cast_nullable_to_non_nullable
as String,billDate: null == billDate ? _self.billDate : billDate // ignore: cast_nullable_to_non_nullable
as String,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,basePrice: null == basePrice ? _self.basePrice : basePrice // ignore: cast_nullable_to_non_nullable
as double,serialNumber: null == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String,macVcNumber: null == macVcNumber ? _self.macVcNumber : macVcNumber // ignore: cast_nullable_to_non_nullable
as String,pname: null == pname ? _self.pname : pname // ignore: cast_nullable_to_non_nullable
as String,setupPrice: null == setupPrice ? _self.setupPrice : setupPrice // ignore: cast_nullable_to_non_nullable
as double,taxAmount: null == taxAmount ? _self.taxAmount : taxAmount // ignore: cast_nullable_to_non_nullable
as double,pendingAmount: null == pendingAmount ? _self.pendingAmount : pendingAmount // ignore: cast_nullable_to_non_nullable
as double,discountAmount: null == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as double,isAdhoc: null == isAdhoc ? _self.isAdhoc : isAdhoc // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
