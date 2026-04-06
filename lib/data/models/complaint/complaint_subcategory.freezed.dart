// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'complaint_subcategory.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ComplaintSubcategory {

@JsonKey(name: 'subCategoryId') int get subCategoryId;@JsonKey(name: 'subCategoryName') String get subCategoryName;@JsonKey(name: 'categoryId') int get categoryId;
/// Create a copy of ComplaintSubcategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComplaintSubcategoryCopyWith<ComplaintSubcategory> get copyWith => _$ComplaintSubcategoryCopyWithImpl<ComplaintSubcategory>(this as ComplaintSubcategory, _$identity);

  /// Serializes this ComplaintSubcategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComplaintSubcategory&&(identical(other.subCategoryId, subCategoryId) || other.subCategoryId == subCategoryId)&&(identical(other.subCategoryName, subCategoryName) || other.subCategoryName == subCategoryName)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,subCategoryId,subCategoryName,categoryId);

@override
String toString() {
  return 'ComplaintSubcategory(subCategoryId: $subCategoryId, subCategoryName: $subCategoryName, categoryId: $categoryId)';
}


}

/// @nodoc
abstract mixin class $ComplaintSubcategoryCopyWith<$Res>  {
  factory $ComplaintSubcategoryCopyWith(ComplaintSubcategory value, $Res Function(ComplaintSubcategory) _then) = _$ComplaintSubcategoryCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'subCategoryId') int subCategoryId,@JsonKey(name: 'subCategoryName') String subCategoryName,@JsonKey(name: 'categoryId') int categoryId
});




}
/// @nodoc
class _$ComplaintSubcategoryCopyWithImpl<$Res>
    implements $ComplaintSubcategoryCopyWith<$Res> {
  _$ComplaintSubcategoryCopyWithImpl(this._self, this._then);

  final ComplaintSubcategory _self;
  final $Res Function(ComplaintSubcategory) _then;

/// Create a copy of ComplaintSubcategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? subCategoryId = null,Object? subCategoryName = null,Object? categoryId = null,}) {
  return _then(_self.copyWith(
subCategoryId: null == subCategoryId ? _self.subCategoryId : subCategoryId // ignore: cast_nullable_to_non_nullable
as int,subCategoryName: null == subCategoryName ? _self.subCategoryName : subCategoryName // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ComplaintSubcategory].
extension ComplaintSubcategoryPatterns on ComplaintSubcategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ComplaintSubcategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ComplaintSubcategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ComplaintSubcategory value)  $default,){
final _that = this;
switch (_that) {
case _ComplaintSubcategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ComplaintSubcategory value)?  $default,){
final _that = this;
switch (_that) {
case _ComplaintSubcategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'subCategoryId')  int subCategoryId, @JsonKey(name: 'subCategoryName')  String subCategoryName, @JsonKey(name: 'categoryId')  int categoryId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComplaintSubcategory() when $default != null:
return $default(_that.subCategoryId,_that.subCategoryName,_that.categoryId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'subCategoryId')  int subCategoryId, @JsonKey(name: 'subCategoryName')  String subCategoryName, @JsonKey(name: 'categoryId')  int categoryId)  $default,) {final _that = this;
switch (_that) {
case _ComplaintSubcategory():
return $default(_that.subCategoryId,_that.subCategoryName,_that.categoryId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'subCategoryId')  int subCategoryId, @JsonKey(name: 'subCategoryName')  String subCategoryName, @JsonKey(name: 'categoryId')  int categoryId)?  $default,) {final _that = this;
switch (_that) {
case _ComplaintSubcategory() when $default != null:
return $default(_that.subCategoryId,_that.subCategoryName,_that.categoryId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ComplaintSubcategory implements ComplaintSubcategory {
  const _ComplaintSubcategory({@JsonKey(name: 'subCategoryId') this.subCategoryId = 0, @JsonKey(name: 'subCategoryName') this.subCategoryName = '', @JsonKey(name: 'categoryId') this.categoryId = 0});
  factory _ComplaintSubcategory.fromJson(Map<String, dynamic> json) => _$ComplaintSubcategoryFromJson(json);

@override@JsonKey(name: 'subCategoryId') final  int subCategoryId;
@override@JsonKey(name: 'subCategoryName') final  String subCategoryName;
@override@JsonKey(name: 'categoryId') final  int categoryId;

/// Create a copy of ComplaintSubcategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComplaintSubcategoryCopyWith<_ComplaintSubcategory> get copyWith => __$ComplaintSubcategoryCopyWithImpl<_ComplaintSubcategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ComplaintSubcategoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComplaintSubcategory&&(identical(other.subCategoryId, subCategoryId) || other.subCategoryId == subCategoryId)&&(identical(other.subCategoryName, subCategoryName) || other.subCategoryName == subCategoryName)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,subCategoryId,subCategoryName,categoryId);

@override
String toString() {
  return 'ComplaintSubcategory(subCategoryId: $subCategoryId, subCategoryName: $subCategoryName, categoryId: $categoryId)';
}


}

/// @nodoc
abstract mixin class _$ComplaintSubcategoryCopyWith<$Res> implements $ComplaintSubcategoryCopyWith<$Res> {
  factory _$ComplaintSubcategoryCopyWith(_ComplaintSubcategory value, $Res Function(_ComplaintSubcategory) _then) = __$ComplaintSubcategoryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'subCategoryId') int subCategoryId,@JsonKey(name: 'subCategoryName') String subCategoryName,@JsonKey(name: 'categoryId') int categoryId
});




}
/// @nodoc
class __$ComplaintSubcategoryCopyWithImpl<$Res>
    implements _$ComplaintSubcategoryCopyWith<$Res> {
  __$ComplaintSubcategoryCopyWithImpl(this._self, this._then);

  final _ComplaintSubcategory _self;
  final $Res Function(_ComplaintSubcategory) _then;

/// Create a copy of ComplaintSubcategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? subCategoryId = null,Object? subCategoryName = null,Object? categoryId = null,}) {
  return _then(_ComplaintSubcategory(
subCategoryId: null == subCategoryId ? _self.subCategoryId : subCategoryId // ignore: cast_nullable_to_non_nullable
as int,subCategoryName: null == subCategoryName ? _self.subCategoryName : subCategoryName // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
