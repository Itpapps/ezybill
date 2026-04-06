// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'complaint_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ComplaintModel {

@JsonKey(name: 'simple_complaint_id') String get complaintId;@JsonKey(name: 'tkt_number') String get ticketNumber;@JsonKey(name: 'customer_id') String get customerId;@JsonKey(name: 'customer_name') String get customerName;@JsonKey(name: 'customer_account_id') String? get customerAccountId;@JsonKey(name: 'CAF') String? get cafNumber;@JsonKey(name: 'complaint') String get category;@JsonKey(name: 'categoryName') String? get categoryName;@JsonKey(name: 'subCategory') String? get subCategory;@JsonKey(name: 'description') String get complaint;@JsonKey(name: 'status') String get status;@JsonKey(name: 'assigned_employee_id') String? get assignedTo;@JsonKey(name: 'assigned_name') String? get assignedToName;@JsonKey(name: 'date') String get createdDate;@JsonKey(name: 'closedDate') String? get closedDate;@JsonKey(name: 'remarks') String? get remarks;
/// Create a copy of ComplaintModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComplaintModelCopyWith<ComplaintModel> get copyWith => _$ComplaintModelCopyWithImpl<ComplaintModel>(this as ComplaintModel, _$identity);

  /// Serializes this ComplaintModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComplaintModel&&(identical(other.complaintId, complaintId) || other.complaintId == complaintId)&&(identical(other.ticketNumber, ticketNumber) || other.ticketNumber == ticketNumber)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerAccountId, customerAccountId) || other.customerAccountId == customerAccountId)&&(identical(other.cafNumber, cafNumber) || other.cafNumber == cafNumber)&&(identical(other.category, category) || other.category == category)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.subCategory, subCategory) || other.subCategory == subCategory)&&(identical(other.complaint, complaint) || other.complaint == complaint)&&(identical(other.status, status) || other.status == status)&&(identical(other.assignedTo, assignedTo) || other.assignedTo == assignedTo)&&(identical(other.assignedToName, assignedToName) || other.assignedToName == assignedToName)&&(identical(other.createdDate, createdDate) || other.createdDate == createdDate)&&(identical(other.closedDate, closedDate) || other.closedDate == closedDate)&&(identical(other.remarks, remarks) || other.remarks == remarks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,complaintId,ticketNumber,customerId,customerName,customerAccountId,cafNumber,category,categoryName,subCategory,complaint,status,assignedTo,assignedToName,createdDate,closedDate,remarks);

@override
String toString() {
  return 'ComplaintModel(complaintId: $complaintId, ticketNumber: $ticketNumber, customerId: $customerId, customerName: $customerName, customerAccountId: $customerAccountId, cafNumber: $cafNumber, category: $category, categoryName: $categoryName, subCategory: $subCategory, complaint: $complaint, status: $status, assignedTo: $assignedTo, assignedToName: $assignedToName, createdDate: $createdDate, closedDate: $closedDate, remarks: $remarks)';
}


}

/// @nodoc
abstract mixin class $ComplaintModelCopyWith<$Res>  {
  factory $ComplaintModelCopyWith(ComplaintModel value, $Res Function(ComplaintModel) _then) = _$ComplaintModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'simple_complaint_id') String complaintId,@JsonKey(name: 'tkt_number') String ticketNumber,@JsonKey(name: 'customer_id') String customerId,@JsonKey(name: 'customer_name') String customerName,@JsonKey(name: 'customer_account_id') String? customerAccountId,@JsonKey(name: 'CAF') String? cafNumber,@JsonKey(name: 'complaint') String category,@JsonKey(name: 'categoryName') String? categoryName,@JsonKey(name: 'subCategory') String? subCategory,@JsonKey(name: 'description') String complaint,@JsonKey(name: 'status') String status,@JsonKey(name: 'assigned_employee_id') String? assignedTo,@JsonKey(name: 'assigned_name') String? assignedToName,@JsonKey(name: 'date') String createdDate,@JsonKey(name: 'closedDate') String? closedDate,@JsonKey(name: 'remarks') String? remarks
});




}
/// @nodoc
class _$ComplaintModelCopyWithImpl<$Res>
    implements $ComplaintModelCopyWith<$Res> {
  _$ComplaintModelCopyWithImpl(this._self, this._then);

  final ComplaintModel _self;
  final $Res Function(ComplaintModel) _then;

/// Create a copy of ComplaintModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? complaintId = null,Object? ticketNumber = null,Object? customerId = null,Object? customerName = null,Object? customerAccountId = freezed,Object? cafNumber = freezed,Object? category = null,Object? categoryName = freezed,Object? subCategory = freezed,Object? complaint = null,Object? status = null,Object? assignedTo = freezed,Object? assignedToName = freezed,Object? createdDate = null,Object? closedDate = freezed,Object? remarks = freezed,}) {
  return _then(_self.copyWith(
complaintId: null == complaintId ? _self.complaintId : complaintId // ignore: cast_nullable_to_non_nullable
as String,ticketNumber: null == ticketNumber ? _self.ticketNumber : ticketNumber // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,customerAccountId: freezed == customerAccountId ? _self.customerAccountId : customerAccountId // ignore: cast_nullable_to_non_nullable
as String?,cafNumber: freezed == cafNumber ? _self.cafNumber : cafNumber // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,subCategory: freezed == subCategory ? _self.subCategory : subCategory // ignore: cast_nullable_to_non_nullable
as String?,complaint: null == complaint ? _self.complaint : complaint // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,assignedTo: freezed == assignedTo ? _self.assignedTo : assignedTo // ignore: cast_nullable_to_non_nullable
as String?,assignedToName: freezed == assignedToName ? _self.assignedToName : assignedToName // ignore: cast_nullable_to_non_nullable
as String?,createdDate: null == createdDate ? _self.createdDate : createdDate // ignore: cast_nullable_to_non_nullable
as String,closedDate: freezed == closedDate ? _self.closedDate : closedDate // ignore: cast_nullable_to_non_nullable
as String?,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ComplaintModel].
extension ComplaintModelPatterns on ComplaintModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ComplaintModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ComplaintModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ComplaintModel value)  $default,){
final _that = this;
switch (_that) {
case _ComplaintModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ComplaintModel value)?  $default,){
final _that = this;
switch (_that) {
case _ComplaintModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'simple_complaint_id')  String complaintId, @JsonKey(name: 'tkt_number')  String ticketNumber, @JsonKey(name: 'customer_id')  String customerId, @JsonKey(name: 'customer_name')  String customerName, @JsonKey(name: 'customer_account_id')  String? customerAccountId, @JsonKey(name: 'CAF')  String? cafNumber, @JsonKey(name: 'complaint')  String category, @JsonKey(name: 'categoryName')  String? categoryName, @JsonKey(name: 'subCategory')  String? subCategory, @JsonKey(name: 'description')  String complaint, @JsonKey(name: 'status')  String status, @JsonKey(name: 'assigned_employee_id')  String? assignedTo, @JsonKey(name: 'assigned_name')  String? assignedToName, @JsonKey(name: 'date')  String createdDate, @JsonKey(name: 'closedDate')  String? closedDate, @JsonKey(name: 'remarks')  String? remarks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComplaintModel() when $default != null:
return $default(_that.complaintId,_that.ticketNumber,_that.customerId,_that.customerName,_that.customerAccountId,_that.cafNumber,_that.category,_that.categoryName,_that.subCategory,_that.complaint,_that.status,_that.assignedTo,_that.assignedToName,_that.createdDate,_that.closedDate,_that.remarks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'simple_complaint_id')  String complaintId, @JsonKey(name: 'tkt_number')  String ticketNumber, @JsonKey(name: 'customer_id')  String customerId, @JsonKey(name: 'customer_name')  String customerName, @JsonKey(name: 'customer_account_id')  String? customerAccountId, @JsonKey(name: 'CAF')  String? cafNumber, @JsonKey(name: 'complaint')  String category, @JsonKey(name: 'categoryName')  String? categoryName, @JsonKey(name: 'subCategory')  String? subCategory, @JsonKey(name: 'description')  String complaint, @JsonKey(name: 'status')  String status, @JsonKey(name: 'assigned_employee_id')  String? assignedTo, @JsonKey(name: 'assigned_name')  String? assignedToName, @JsonKey(name: 'date')  String createdDate, @JsonKey(name: 'closedDate')  String? closedDate, @JsonKey(name: 'remarks')  String? remarks)  $default,) {final _that = this;
switch (_that) {
case _ComplaintModel():
return $default(_that.complaintId,_that.ticketNumber,_that.customerId,_that.customerName,_that.customerAccountId,_that.cafNumber,_that.category,_that.categoryName,_that.subCategory,_that.complaint,_that.status,_that.assignedTo,_that.assignedToName,_that.createdDate,_that.closedDate,_that.remarks);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'simple_complaint_id')  String complaintId, @JsonKey(name: 'tkt_number')  String ticketNumber, @JsonKey(name: 'customer_id')  String customerId, @JsonKey(name: 'customer_name')  String customerName, @JsonKey(name: 'customer_account_id')  String? customerAccountId, @JsonKey(name: 'CAF')  String? cafNumber, @JsonKey(name: 'complaint')  String category, @JsonKey(name: 'categoryName')  String? categoryName, @JsonKey(name: 'subCategory')  String? subCategory, @JsonKey(name: 'description')  String complaint, @JsonKey(name: 'status')  String status, @JsonKey(name: 'assigned_employee_id')  String? assignedTo, @JsonKey(name: 'assigned_name')  String? assignedToName, @JsonKey(name: 'date')  String createdDate, @JsonKey(name: 'closedDate')  String? closedDate, @JsonKey(name: 'remarks')  String? remarks)?  $default,) {final _that = this;
switch (_that) {
case _ComplaintModel() when $default != null:
return $default(_that.complaintId,_that.ticketNumber,_that.customerId,_that.customerName,_that.customerAccountId,_that.cafNumber,_that.category,_that.categoryName,_that.subCategory,_that.complaint,_that.status,_that.assignedTo,_that.assignedToName,_that.createdDate,_that.closedDate,_that.remarks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ComplaintModel implements ComplaintModel {
  const _ComplaintModel({@JsonKey(name: 'simple_complaint_id') required this.complaintId, @JsonKey(name: 'tkt_number') required this.ticketNumber, @JsonKey(name: 'customer_id') required this.customerId, @JsonKey(name: 'customer_name') required this.customerName, @JsonKey(name: 'customer_account_id') this.customerAccountId, @JsonKey(name: 'CAF') this.cafNumber, @JsonKey(name: 'complaint') required this.category, @JsonKey(name: 'categoryName') this.categoryName, @JsonKey(name: 'subCategory') this.subCategory, @JsonKey(name: 'description') required this.complaint, @JsonKey(name: 'status') required this.status, @JsonKey(name: 'assigned_employee_id') this.assignedTo, @JsonKey(name: 'assigned_name') this.assignedToName, @JsonKey(name: 'date') required this.createdDate, @JsonKey(name: 'closedDate') this.closedDate, @JsonKey(name: 'remarks') this.remarks});
  factory _ComplaintModel.fromJson(Map<String, dynamic> json) => _$ComplaintModelFromJson(json);

@override@JsonKey(name: 'simple_complaint_id') final  String complaintId;
@override@JsonKey(name: 'tkt_number') final  String ticketNumber;
@override@JsonKey(name: 'customer_id') final  String customerId;
@override@JsonKey(name: 'customer_name') final  String customerName;
@override@JsonKey(name: 'customer_account_id') final  String? customerAccountId;
@override@JsonKey(name: 'CAF') final  String? cafNumber;
@override@JsonKey(name: 'complaint') final  String category;
@override@JsonKey(name: 'categoryName') final  String? categoryName;
@override@JsonKey(name: 'subCategory') final  String? subCategory;
@override@JsonKey(name: 'description') final  String complaint;
@override@JsonKey(name: 'status') final  String status;
@override@JsonKey(name: 'assigned_employee_id') final  String? assignedTo;
@override@JsonKey(name: 'assigned_name') final  String? assignedToName;
@override@JsonKey(name: 'date') final  String createdDate;
@override@JsonKey(name: 'closedDate') final  String? closedDate;
@override@JsonKey(name: 'remarks') final  String? remarks;

/// Create a copy of ComplaintModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComplaintModelCopyWith<_ComplaintModel> get copyWith => __$ComplaintModelCopyWithImpl<_ComplaintModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ComplaintModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComplaintModel&&(identical(other.complaintId, complaintId) || other.complaintId == complaintId)&&(identical(other.ticketNumber, ticketNumber) || other.ticketNumber == ticketNumber)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerAccountId, customerAccountId) || other.customerAccountId == customerAccountId)&&(identical(other.cafNumber, cafNumber) || other.cafNumber == cafNumber)&&(identical(other.category, category) || other.category == category)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.subCategory, subCategory) || other.subCategory == subCategory)&&(identical(other.complaint, complaint) || other.complaint == complaint)&&(identical(other.status, status) || other.status == status)&&(identical(other.assignedTo, assignedTo) || other.assignedTo == assignedTo)&&(identical(other.assignedToName, assignedToName) || other.assignedToName == assignedToName)&&(identical(other.createdDate, createdDate) || other.createdDate == createdDate)&&(identical(other.closedDate, closedDate) || other.closedDate == closedDate)&&(identical(other.remarks, remarks) || other.remarks == remarks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,complaintId,ticketNumber,customerId,customerName,customerAccountId,cafNumber,category,categoryName,subCategory,complaint,status,assignedTo,assignedToName,createdDate,closedDate,remarks);

@override
String toString() {
  return 'ComplaintModel(complaintId: $complaintId, ticketNumber: $ticketNumber, customerId: $customerId, customerName: $customerName, customerAccountId: $customerAccountId, cafNumber: $cafNumber, category: $category, categoryName: $categoryName, subCategory: $subCategory, complaint: $complaint, status: $status, assignedTo: $assignedTo, assignedToName: $assignedToName, createdDate: $createdDate, closedDate: $closedDate, remarks: $remarks)';
}


}

/// @nodoc
abstract mixin class _$ComplaintModelCopyWith<$Res> implements $ComplaintModelCopyWith<$Res> {
  factory _$ComplaintModelCopyWith(_ComplaintModel value, $Res Function(_ComplaintModel) _then) = __$ComplaintModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'simple_complaint_id') String complaintId,@JsonKey(name: 'tkt_number') String ticketNumber,@JsonKey(name: 'customer_id') String customerId,@JsonKey(name: 'customer_name') String customerName,@JsonKey(name: 'customer_account_id') String? customerAccountId,@JsonKey(name: 'CAF') String? cafNumber,@JsonKey(name: 'complaint') String category,@JsonKey(name: 'categoryName') String? categoryName,@JsonKey(name: 'subCategory') String? subCategory,@JsonKey(name: 'description') String complaint,@JsonKey(name: 'status') String status,@JsonKey(name: 'assigned_employee_id') String? assignedTo,@JsonKey(name: 'assigned_name') String? assignedToName,@JsonKey(name: 'date') String createdDate,@JsonKey(name: 'closedDate') String? closedDate,@JsonKey(name: 'remarks') String? remarks
});




}
/// @nodoc
class __$ComplaintModelCopyWithImpl<$Res>
    implements _$ComplaintModelCopyWith<$Res> {
  __$ComplaintModelCopyWithImpl(this._self, this._then);

  final _ComplaintModel _self;
  final $Res Function(_ComplaintModel) _then;

/// Create a copy of ComplaintModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? complaintId = null,Object? ticketNumber = null,Object? customerId = null,Object? customerName = null,Object? customerAccountId = freezed,Object? cafNumber = freezed,Object? category = null,Object? categoryName = freezed,Object? subCategory = freezed,Object? complaint = null,Object? status = null,Object? assignedTo = freezed,Object? assignedToName = freezed,Object? createdDate = null,Object? closedDate = freezed,Object? remarks = freezed,}) {
  return _then(_ComplaintModel(
complaintId: null == complaintId ? _self.complaintId : complaintId // ignore: cast_nullable_to_non_nullable
as String,ticketNumber: null == ticketNumber ? _self.ticketNumber : ticketNumber // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,customerAccountId: freezed == customerAccountId ? _self.customerAccountId : customerAccountId // ignore: cast_nullable_to_non_nullable
as String?,cafNumber: freezed == cafNumber ? _self.cafNumber : cafNumber // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,subCategory: freezed == subCategory ? _self.subCategory : subCategory // ignore: cast_nullable_to_non_nullable
as String?,complaint: null == complaint ? _self.complaint : complaint // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,assignedTo: freezed == assignedTo ? _self.assignedTo : assignedTo // ignore: cast_nullable_to_non_nullable
as String?,assignedToName: freezed == assignedToName ? _self.assignedToName : assignedToName // ignore: cast_nullable_to_non_nullable
as String?,createdDate: null == createdDate ? _self.createdDate : createdDate // ignore: cast_nullable_to_non_nullable
as String,closedDate: freezed == closedDate ? _self.closedDate : closedDate // ignore: cast_nullable_to_non_nullable
as String?,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
