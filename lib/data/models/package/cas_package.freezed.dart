// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cas_package.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CasPackage {

@JsonKey(name: 'product_id') String get productId;@JsonKey(name: 'pname') String get productName;@JsonKey(name: 'pricing_structure_type') String get pricingStructureType;@JsonKey(name: 'price') double get price;
/// Create a copy of CasPackage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CasPackageCopyWith<CasPackage> get copyWith => _$CasPackageCopyWithImpl<CasPackage>(this as CasPackage, _$identity);

  /// Serializes this CasPackage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CasPackage&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.pricingStructureType, pricingStructureType) || other.pricingStructureType == pricingStructureType)&&(identical(other.price, price) || other.price == price));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,productName,pricingStructureType,price);

@override
String toString() {
  return 'CasPackage(productId: $productId, productName: $productName, pricingStructureType: $pricingStructureType, price: $price)';
}


}

/// @nodoc
abstract mixin class $CasPackageCopyWith<$Res>  {
  factory $CasPackageCopyWith(CasPackage value, $Res Function(CasPackage) _then) = _$CasPackageCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'product_id') String productId,@JsonKey(name: 'pname') String productName,@JsonKey(name: 'pricing_structure_type') String pricingStructureType,@JsonKey(name: 'price') double price
});




}
/// @nodoc
class _$CasPackageCopyWithImpl<$Res>
    implements $CasPackageCopyWith<$Res> {
  _$CasPackageCopyWithImpl(this._self, this._then);

  final CasPackage _self;
  final $Res Function(CasPackage) _then;

/// Create a copy of CasPackage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? productName = null,Object? pricingStructureType = null,Object? price = null,}) {
  return _then(_self.copyWith(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,pricingStructureType: null == pricingStructureType ? _self.pricingStructureType : pricingStructureType // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [CasPackage].
extension CasPackagePatterns on CasPackage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CasPackage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CasPackage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CasPackage value)  $default,){
final _that = this;
switch (_that) {
case _CasPackage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CasPackage value)?  $default,){
final _that = this;
switch (_that) {
case _CasPackage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'pname')  String productName, @JsonKey(name: 'pricing_structure_type')  String pricingStructureType, @JsonKey(name: 'price')  double price)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CasPackage() when $default != null:
return $default(_that.productId,_that.productName,_that.pricingStructureType,_that.price);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'pname')  String productName, @JsonKey(name: 'pricing_structure_type')  String pricingStructureType, @JsonKey(name: 'price')  double price)  $default,) {final _that = this;
switch (_that) {
case _CasPackage():
return $default(_that.productId,_that.productName,_that.pricingStructureType,_that.price);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'pname')  String productName, @JsonKey(name: 'pricing_structure_type')  String pricingStructureType, @JsonKey(name: 'price')  double price)?  $default,) {final _that = this;
switch (_that) {
case _CasPackage() when $default != null:
return $default(_that.productId,_that.productName,_that.pricingStructureType,_that.price);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CasPackage implements CasPackage {
  const _CasPackage({@JsonKey(name: 'product_id') this.productId = '', @JsonKey(name: 'pname') this.productName = '', @JsonKey(name: 'pricing_structure_type') this.pricingStructureType = '', @JsonKey(name: 'price') this.price = 0.0});
  factory _CasPackage.fromJson(Map<String, dynamic> json) => _$CasPackageFromJson(json);

@override@JsonKey(name: 'product_id') final  String productId;
@override@JsonKey(name: 'pname') final  String productName;
@override@JsonKey(name: 'pricing_structure_type') final  String pricingStructureType;
@override@JsonKey(name: 'price') final  double price;

/// Create a copy of CasPackage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CasPackageCopyWith<_CasPackage> get copyWith => __$CasPackageCopyWithImpl<_CasPackage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CasPackageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CasPackage&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.pricingStructureType, pricingStructureType) || other.pricingStructureType == pricingStructureType)&&(identical(other.price, price) || other.price == price));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,productName,pricingStructureType,price);

@override
String toString() {
  return 'CasPackage(productId: $productId, productName: $productName, pricingStructureType: $pricingStructureType, price: $price)';
}


}

/// @nodoc
abstract mixin class _$CasPackageCopyWith<$Res> implements $CasPackageCopyWith<$Res> {
  factory _$CasPackageCopyWith(_CasPackage value, $Res Function(_CasPackage) _then) = __$CasPackageCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'product_id') String productId,@JsonKey(name: 'pname') String productName,@JsonKey(name: 'pricing_structure_type') String pricingStructureType,@JsonKey(name: 'price') double price
});




}
/// @nodoc
class __$CasPackageCopyWithImpl<$Res>
    implements _$CasPackageCopyWith<$Res> {
  __$CasPackageCopyWithImpl(this._self, this._then);

  final _CasPackage _self;
  final $Res Function(_CasPackage) _then;

/// Create a copy of CasPackage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? productName = null,Object? pricingStructureType = null,Object? price = null,}) {
  return _then(_CasPackage(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,pricingStructureType: null == pricingStructureType ? _self.pricingStructureType : pricingStructureType // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
