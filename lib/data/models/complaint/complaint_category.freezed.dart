// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'complaint_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ComplaintCategory {

@JsonKey(name: 'categoryId') int get categoryId;@JsonKey(name: 'categoryName') String get categoryName;@JsonKey(name: 'parent_category_id') int get parentCategoryId;
/// Create a copy of ComplaintCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComplaintCategoryCopyWith<ComplaintCategory> get copyWith => _$ComplaintCategoryCopyWithImpl<ComplaintCategory>(this as ComplaintCategory, _$identity);

  /// Serializes this ComplaintCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComplaintCategory&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.parentCategoryId, parentCategoryId) || other.parentCategoryId == parentCategoryId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,categoryId,categoryName,parentCategoryId);

@override
String toString() {
  return 'ComplaintCategory(categoryId: $categoryId, categoryName: $categoryName, parentCategoryId: $parentCategoryId)';
}


}

/// @nodoc
abstract mixin class $ComplaintCategoryCopyWith<$Res>  {
  factory $ComplaintCategoryCopyWith(ComplaintCategory value, $Res Function(ComplaintCategory) _then) = _$ComplaintCategoryCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'categoryId') int categoryId,@JsonKey(name: 'categoryName') String categoryName,@JsonKey(name: 'parent_category_id') int parentCategoryId
});




}
/// @nodoc
class _$ComplaintCategoryCopyWithImpl<$Res>
    implements $ComplaintCategoryCopyWith<$Res> {
  _$ComplaintCategoryCopyWithImpl(this._self, this._then);

  final ComplaintCategory _self;
  final $Res Function(ComplaintCategory) _then;

/// Create a copy of ComplaintCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categoryId = null,Object? categoryName = null,Object? parentCategoryId = null,}) {
  return _then(_self.copyWith(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,parentCategoryId: null == parentCategoryId ? _self.parentCategoryId : parentCategoryId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ComplaintCategory].
extension ComplaintCategoryPatterns on ComplaintCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ComplaintCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ComplaintCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ComplaintCategory value)  $default,){
final _that = this;
switch (_that) {
case _ComplaintCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ComplaintCategory value)?  $default,){
final _that = this;
switch (_that) {
case _ComplaintCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'categoryId')  int categoryId, @JsonKey(name: 'categoryName')  String categoryName, @JsonKey(name: 'parent_category_id')  int parentCategoryId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComplaintCategory() when $default != null:
return $default(_that.categoryId,_that.categoryName,_that.parentCategoryId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'categoryId')  int categoryId, @JsonKey(name: 'categoryName')  String categoryName, @JsonKey(name: 'parent_category_id')  int parentCategoryId)  $default,) {final _that = this;
switch (_that) {
case _ComplaintCategory():
return $default(_that.categoryId,_that.categoryName,_that.parentCategoryId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'categoryId')  int categoryId, @JsonKey(name: 'categoryName')  String categoryName, @JsonKey(name: 'parent_category_id')  int parentCategoryId)?  $default,) {final _that = this;
switch (_that) {
case _ComplaintCategory() when $default != null:
return $default(_that.categoryId,_that.categoryName,_that.parentCategoryId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ComplaintCategory implements ComplaintCategory {
  const _ComplaintCategory({@JsonKey(name: 'categoryId') this.categoryId = 0, @JsonKey(name: 'categoryName') this.categoryName = '', @JsonKey(name: 'parent_category_id') this.parentCategoryId = 0});
  factory _ComplaintCategory.fromJson(Map<String, dynamic> json) => _$ComplaintCategoryFromJson(json);

@override@JsonKey(name: 'categoryId') final  int categoryId;
@override@JsonKey(name: 'categoryName') final  String categoryName;
@override@JsonKey(name: 'parent_category_id') final  int parentCategoryId;

/// Create a copy of ComplaintCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComplaintCategoryCopyWith<_ComplaintCategory> get copyWith => __$ComplaintCategoryCopyWithImpl<_ComplaintCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ComplaintCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComplaintCategory&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.parentCategoryId, parentCategoryId) || other.parentCategoryId == parentCategoryId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,categoryId,categoryName,parentCategoryId);

@override
String toString() {
  return 'ComplaintCategory(categoryId: $categoryId, categoryName: $categoryName, parentCategoryId: $parentCategoryId)';
}


}

/// @nodoc
abstract mixin class _$ComplaintCategoryCopyWith<$Res> implements $ComplaintCategoryCopyWith<$Res> {
  factory _$ComplaintCategoryCopyWith(_ComplaintCategory value, $Res Function(_ComplaintCategory) _then) = __$ComplaintCategoryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'categoryId') int categoryId,@JsonKey(name: 'categoryName') String categoryName,@JsonKey(name: 'parent_category_id') int parentCategoryId
});




}
/// @nodoc
class __$ComplaintCategoryCopyWithImpl<$Res>
    implements _$ComplaintCategoryCopyWith<$Res> {
  __$ComplaintCategoryCopyWithImpl(this._self, this._then);

  final _ComplaintCategory _self;
  final $Res Function(_ComplaintCategory) _then;

/// Create a copy of ComplaintCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categoryId = null,Object? categoryName = null,Object? parentCategoryId = null,}) {
  return _then(_ComplaintCategory(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,parentCategoryId: null == parentCategoryId ? _self.parentCategoryId : parentCategoryId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
