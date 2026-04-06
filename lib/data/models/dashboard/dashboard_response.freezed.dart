// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DashboardResponse {

@JsonKey(name: 'status_code') int get statusCode;@JsonKey(name: 'status_msg') String get statusMsg;@JsonKey(name: 'totalStbs') int get totalStbs;@JsonKey(name: 'totalAssignedStbs') int get totalAssignedStbs;@JsonKey(name: 'totalUnAssignedStbs') int get totalUnAssignedStbs;@JsonKey(name: 'totalComplaints') int get totalComplaints;@JsonKey(name: 'totalClosedComplaints') int get totalClosedComplaints;@JsonKey(name: 'totalActiveCustomers') int get totalActiveCustomers;@JsonKey(name: 'totalDeactiveCustomers') int get totalDeactiveCustomers;@JsonKey(name: 'totalCurrentMonthBill') double get totalCurrentMonthBill;@JsonKey(name: 'totalDueAmount') double get totalDueAmount;@JsonKey(name: 'outStandingAmount') double get outStandingAmount;@JsonKey(name: 'msoShare') double get msoShare;@JsonKey(name: 'totalCurrentMonthMsoShare') double get totalCurrentMonthMsoShare;@JsonKey(name: 'currentMonthOutstanding') double get currentMonthOutstanding;@JsonKey(name: 'currentMonthLCOBill') double get currentMonthLCOBill;@JsonKey(name: 'lcocurrentmonthdueamount') double get lcuCurrentMonthDueAmount;@JsonKey(name: 'totalPaidCustomers') int get totalPaidCustomers;@JsonKey(name: 'totalUnPaidCustomers') int get totalUnPaidCustomers;@JsonKey(name: 'gettotalPaidCustomers') int get gettotalPaidCustomers;@JsonKey(name: 'gettotalUnPaidCustomers') int get gettotalUnPaidCustomers;@JsonKey(name: 'lov_emp_grp_customers') int? get lovEmpGrpCustomers;
/// Create a copy of DashboardResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardResponseCopyWith<DashboardResponse> get copyWith => _$DashboardResponseCopyWithImpl<DashboardResponse>(this as DashboardResponse, _$identity);

  /// Serializes this DashboardResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardResponse&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.statusMsg, statusMsg) || other.statusMsg == statusMsg)&&(identical(other.totalStbs, totalStbs) || other.totalStbs == totalStbs)&&(identical(other.totalAssignedStbs, totalAssignedStbs) || other.totalAssignedStbs == totalAssignedStbs)&&(identical(other.totalUnAssignedStbs, totalUnAssignedStbs) || other.totalUnAssignedStbs == totalUnAssignedStbs)&&(identical(other.totalComplaints, totalComplaints) || other.totalComplaints == totalComplaints)&&(identical(other.totalClosedComplaints, totalClosedComplaints) || other.totalClosedComplaints == totalClosedComplaints)&&(identical(other.totalActiveCustomers, totalActiveCustomers) || other.totalActiveCustomers == totalActiveCustomers)&&(identical(other.totalDeactiveCustomers, totalDeactiveCustomers) || other.totalDeactiveCustomers == totalDeactiveCustomers)&&(identical(other.totalCurrentMonthBill, totalCurrentMonthBill) || other.totalCurrentMonthBill == totalCurrentMonthBill)&&(identical(other.totalDueAmount, totalDueAmount) || other.totalDueAmount == totalDueAmount)&&(identical(other.outStandingAmount, outStandingAmount) || other.outStandingAmount == outStandingAmount)&&(identical(other.msoShare, msoShare) || other.msoShare == msoShare)&&(identical(other.totalCurrentMonthMsoShare, totalCurrentMonthMsoShare) || other.totalCurrentMonthMsoShare == totalCurrentMonthMsoShare)&&(identical(other.currentMonthOutstanding, currentMonthOutstanding) || other.currentMonthOutstanding == currentMonthOutstanding)&&(identical(other.currentMonthLCOBill, currentMonthLCOBill) || other.currentMonthLCOBill == currentMonthLCOBill)&&(identical(other.lcuCurrentMonthDueAmount, lcuCurrentMonthDueAmount) || other.lcuCurrentMonthDueAmount == lcuCurrentMonthDueAmount)&&(identical(other.totalPaidCustomers, totalPaidCustomers) || other.totalPaidCustomers == totalPaidCustomers)&&(identical(other.totalUnPaidCustomers, totalUnPaidCustomers) || other.totalUnPaidCustomers == totalUnPaidCustomers)&&(identical(other.gettotalPaidCustomers, gettotalPaidCustomers) || other.gettotalPaidCustomers == gettotalPaidCustomers)&&(identical(other.gettotalUnPaidCustomers, gettotalUnPaidCustomers) || other.gettotalUnPaidCustomers == gettotalUnPaidCustomers)&&(identical(other.lovEmpGrpCustomers, lovEmpGrpCustomers) || other.lovEmpGrpCustomers == lovEmpGrpCustomers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,statusCode,statusMsg,totalStbs,totalAssignedStbs,totalUnAssignedStbs,totalComplaints,totalClosedComplaints,totalActiveCustomers,totalDeactiveCustomers,totalCurrentMonthBill,totalDueAmount,outStandingAmount,msoShare,totalCurrentMonthMsoShare,currentMonthOutstanding,currentMonthLCOBill,lcuCurrentMonthDueAmount,totalPaidCustomers,totalUnPaidCustomers,gettotalPaidCustomers,gettotalUnPaidCustomers,lovEmpGrpCustomers]);

@override
String toString() {
  return 'DashboardResponse(statusCode: $statusCode, statusMsg: $statusMsg, totalStbs: $totalStbs, totalAssignedStbs: $totalAssignedStbs, totalUnAssignedStbs: $totalUnAssignedStbs, totalComplaints: $totalComplaints, totalClosedComplaints: $totalClosedComplaints, totalActiveCustomers: $totalActiveCustomers, totalDeactiveCustomers: $totalDeactiveCustomers, totalCurrentMonthBill: $totalCurrentMonthBill, totalDueAmount: $totalDueAmount, outStandingAmount: $outStandingAmount, msoShare: $msoShare, totalCurrentMonthMsoShare: $totalCurrentMonthMsoShare, currentMonthOutstanding: $currentMonthOutstanding, currentMonthLCOBill: $currentMonthLCOBill, lcuCurrentMonthDueAmount: $lcuCurrentMonthDueAmount, totalPaidCustomers: $totalPaidCustomers, totalUnPaidCustomers: $totalUnPaidCustomers, gettotalPaidCustomers: $gettotalPaidCustomers, gettotalUnPaidCustomers: $gettotalUnPaidCustomers, lovEmpGrpCustomers: $lovEmpGrpCustomers)';
}


}

/// @nodoc
abstract mixin class $DashboardResponseCopyWith<$Res>  {
  factory $DashboardResponseCopyWith(DashboardResponse value, $Res Function(DashboardResponse) _then) = _$DashboardResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'status_code') int statusCode,@JsonKey(name: 'status_msg') String statusMsg,@JsonKey(name: 'totalStbs') int totalStbs,@JsonKey(name: 'totalAssignedStbs') int totalAssignedStbs,@JsonKey(name: 'totalUnAssignedStbs') int totalUnAssignedStbs,@JsonKey(name: 'totalComplaints') int totalComplaints,@JsonKey(name: 'totalClosedComplaints') int totalClosedComplaints,@JsonKey(name: 'totalActiveCustomers') int totalActiveCustomers,@JsonKey(name: 'totalDeactiveCustomers') int totalDeactiveCustomers,@JsonKey(name: 'totalCurrentMonthBill') double totalCurrentMonthBill,@JsonKey(name: 'totalDueAmount') double totalDueAmount,@JsonKey(name: 'outStandingAmount') double outStandingAmount,@JsonKey(name: 'msoShare') double msoShare,@JsonKey(name: 'totalCurrentMonthMsoShare') double totalCurrentMonthMsoShare,@JsonKey(name: 'currentMonthOutstanding') double currentMonthOutstanding,@JsonKey(name: 'currentMonthLCOBill') double currentMonthLCOBill,@JsonKey(name: 'lcocurrentmonthdueamount') double lcuCurrentMonthDueAmount,@JsonKey(name: 'totalPaidCustomers') int totalPaidCustomers,@JsonKey(name: 'totalUnPaidCustomers') int totalUnPaidCustomers,@JsonKey(name: 'gettotalPaidCustomers') int gettotalPaidCustomers,@JsonKey(name: 'gettotalUnPaidCustomers') int gettotalUnPaidCustomers,@JsonKey(name: 'lov_emp_grp_customers') int? lovEmpGrpCustomers
});




}
/// @nodoc
class _$DashboardResponseCopyWithImpl<$Res>
    implements $DashboardResponseCopyWith<$Res> {
  _$DashboardResponseCopyWithImpl(this._self, this._then);

  final DashboardResponse _self;
  final $Res Function(DashboardResponse) _then;

/// Create a copy of DashboardResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? statusCode = null,Object? statusMsg = null,Object? totalStbs = null,Object? totalAssignedStbs = null,Object? totalUnAssignedStbs = null,Object? totalComplaints = null,Object? totalClosedComplaints = null,Object? totalActiveCustomers = null,Object? totalDeactiveCustomers = null,Object? totalCurrentMonthBill = null,Object? totalDueAmount = null,Object? outStandingAmount = null,Object? msoShare = null,Object? totalCurrentMonthMsoShare = null,Object? currentMonthOutstanding = null,Object? currentMonthLCOBill = null,Object? lcuCurrentMonthDueAmount = null,Object? totalPaidCustomers = null,Object? totalUnPaidCustomers = null,Object? gettotalPaidCustomers = null,Object? gettotalUnPaidCustomers = null,Object? lovEmpGrpCustomers = freezed,}) {
  return _then(_self.copyWith(
statusCode: null == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int,statusMsg: null == statusMsg ? _self.statusMsg : statusMsg // ignore: cast_nullable_to_non_nullable
as String,totalStbs: null == totalStbs ? _self.totalStbs : totalStbs // ignore: cast_nullable_to_non_nullable
as int,totalAssignedStbs: null == totalAssignedStbs ? _self.totalAssignedStbs : totalAssignedStbs // ignore: cast_nullable_to_non_nullable
as int,totalUnAssignedStbs: null == totalUnAssignedStbs ? _self.totalUnAssignedStbs : totalUnAssignedStbs // ignore: cast_nullable_to_non_nullable
as int,totalComplaints: null == totalComplaints ? _self.totalComplaints : totalComplaints // ignore: cast_nullable_to_non_nullable
as int,totalClosedComplaints: null == totalClosedComplaints ? _self.totalClosedComplaints : totalClosedComplaints // ignore: cast_nullable_to_non_nullable
as int,totalActiveCustomers: null == totalActiveCustomers ? _self.totalActiveCustomers : totalActiveCustomers // ignore: cast_nullable_to_non_nullable
as int,totalDeactiveCustomers: null == totalDeactiveCustomers ? _self.totalDeactiveCustomers : totalDeactiveCustomers // ignore: cast_nullable_to_non_nullable
as int,totalCurrentMonthBill: null == totalCurrentMonthBill ? _self.totalCurrentMonthBill : totalCurrentMonthBill // ignore: cast_nullable_to_non_nullable
as double,totalDueAmount: null == totalDueAmount ? _self.totalDueAmount : totalDueAmount // ignore: cast_nullable_to_non_nullable
as double,outStandingAmount: null == outStandingAmount ? _self.outStandingAmount : outStandingAmount // ignore: cast_nullable_to_non_nullable
as double,msoShare: null == msoShare ? _self.msoShare : msoShare // ignore: cast_nullable_to_non_nullable
as double,totalCurrentMonthMsoShare: null == totalCurrentMonthMsoShare ? _self.totalCurrentMonthMsoShare : totalCurrentMonthMsoShare // ignore: cast_nullable_to_non_nullable
as double,currentMonthOutstanding: null == currentMonthOutstanding ? _self.currentMonthOutstanding : currentMonthOutstanding // ignore: cast_nullable_to_non_nullable
as double,currentMonthLCOBill: null == currentMonthLCOBill ? _self.currentMonthLCOBill : currentMonthLCOBill // ignore: cast_nullable_to_non_nullable
as double,lcuCurrentMonthDueAmount: null == lcuCurrentMonthDueAmount ? _self.lcuCurrentMonthDueAmount : lcuCurrentMonthDueAmount // ignore: cast_nullable_to_non_nullable
as double,totalPaidCustomers: null == totalPaidCustomers ? _self.totalPaidCustomers : totalPaidCustomers // ignore: cast_nullable_to_non_nullable
as int,totalUnPaidCustomers: null == totalUnPaidCustomers ? _self.totalUnPaidCustomers : totalUnPaidCustomers // ignore: cast_nullable_to_non_nullable
as int,gettotalPaidCustomers: null == gettotalPaidCustomers ? _self.gettotalPaidCustomers : gettotalPaidCustomers // ignore: cast_nullable_to_non_nullable
as int,gettotalUnPaidCustomers: null == gettotalUnPaidCustomers ? _self.gettotalUnPaidCustomers : gettotalUnPaidCustomers // ignore: cast_nullable_to_non_nullable
as int,lovEmpGrpCustomers: freezed == lovEmpGrpCustomers ? _self.lovEmpGrpCustomers : lovEmpGrpCustomers // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardResponse].
extension DashboardResponsePatterns on DashboardResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardResponse value)  $default,){
final _that = this;
switch (_that) {
case _DashboardResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardResponse value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'status_code')  int statusCode, @JsonKey(name: 'status_msg')  String statusMsg, @JsonKey(name: 'totalStbs')  int totalStbs, @JsonKey(name: 'totalAssignedStbs')  int totalAssignedStbs, @JsonKey(name: 'totalUnAssignedStbs')  int totalUnAssignedStbs, @JsonKey(name: 'totalComplaints')  int totalComplaints, @JsonKey(name: 'totalClosedComplaints')  int totalClosedComplaints, @JsonKey(name: 'totalActiveCustomers')  int totalActiveCustomers, @JsonKey(name: 'totalDeactiveCustomers')  int totalDeactiveCustomers, @JsonKey(name: 'totalCurrentMonthBill')  double totalCurrentMonthBill, @JsonKey(name: 'totalDueAmount')  double totalDueAmount, @JsonKey(name: 'outStandingAmount')  double outStandingAmount, @JsonKey(name: 'msoShare')  double msoShare, @JsonKey(name: 'totalCurrentMonthMsoShare')  double totalCurrentMonthMsoShare, @JsonKey(name: 'currentMonthOutstanding')  double currentMonthOutstanding, @JsonKey(name: 'currentMonthLCOBill')  double currentMonthLCOBill, @JsonKey(name: 'lcocurrentmonthdueamount')  double lcuCurrentMonthDueAmount, @JsonKey(name: 'totalPaidCustomers')  int totalPaidCustomers, @JsonKey(name: 'totalUnPaidCustomers')  int totalUnPaidCustomers, @JsonKey(name: 'gettotalPaidCustomers')  int gettotalPaidCustomers, @JsonKey(name: 'gettotalUnPaidCustomers')  int gettotalUnPaidCustomers, @JsonKey(name: 'lov_emp_grp_customers')  int? lovEmpGrpCustomers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardResponse() when $default != null:
return $default(_that.statusCode,_that.statusMsg,_that.totalStbs,_that.totalAssignedStbs,_that.totalUnAssignedStbs,_that.totalComplaints,_that.totalClosedComplaints,_that.totalActiveCustomers,_that.totalDeactiveCustomers,_that.totalCurrentMonthBill,_that.totalDueAmount,_that.outStandingAmount,_that.msoShare,_that.totalCurrentMonthMsoShare,_that.currentMonthOutstanding,_that.currentMonthLCOBill,_that.lcuCurrentMonthDueAmount,_that.totalPaidCustomers,_that.totalUnPaidCustomers,_that.gettotalPaidCustomers,_that.gettotalUnPaidCustomers,_that.lovEmpGrpCustomers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'status_code')  int statusCode, @JsonKey(name: 'status_msg')  String statusMsg, @JsonKey(name: 'totalStbs')  int totalStbs, @JsonKey(name: 'totalAssignedStbs')  int totalAssignedStbs, @JsonKey(name: 'totalUnAssignedStbs')  int totalUnAssignedStbs, @JsonKey(name: 'totalComplaints')  int totalComplaints, @JsonKey(name: 'totalClosedComplaints')  int totalClosedComplaints, @JsonKey(name: 'totalActiveCustomers')  int totalActiveCustomers, @JsonKey(name: 'totalDeactiveCustomers')  int totalDeactiveCustomers, @JsonKey(name: 'totalCurrentMonthBill')  double totalCurrentMonthBill, @JsonKey(name: 'totalDueAmount')  double totalDueAmount, @JsonKey(name: 'outStandingAmount')  double outStandingAmount, @JsonKey(name: 'msoShare')  double msoShare, @JsonKey(name: 'totalCurrentMonthMsoShare')  double totalCurrentMonthMsoShare, @JsonKey(name: 'currentMonthOutstanding')  double currentMonthOutstanding, @JsonKey(name: 'currentMonthLCOBill')  double currentMonthLCOBill, @JsonKey(name: 'lcocurrentmonthdueamount')  double lcuCurrentMonthDueAmount, @JsonKey(name: 'totalPaidCustomers')  int totalPaidCustomers, @JsonKey(name: 'totalUnPaidCustomers')  int totalUnPaidCustomers, @JsonKey(name: 'gettotalPaidCustomers')  int gettotalPaidCustomers, @JsonKey(name: 'gettotalUnPaidCustomers')  int gettotalUnPaidCustomers, @JsonKey(name: 'lov_emp_grp_customers')  int? lovEmpGrpCustomers)  $default,) {final _that = this;
switch (_that) {
case _DashboardResponse():
return $default(_that.statusCode,_that.statusMsg,_that.totalStbs,_that.totalAssignedStbs,_that.totalUnAssignedStbs,_that.totalComplaints,_that.totalClosedComplaints,_that.totalActiveCustomers,_that.totalDeactiveCustomers,_that.totalCurrentMonthBill,_that.totalDueAmount,_that.outStandingAmount,_that.msoShare,_that.totalCurrentMonthMsoShare,_that.currentMonthOutstanding,_that.currentMonthLCOBill,_that.lcuCurrentMonthDueAmount,_that.totalPaidCustomers,_that.totalUnPaidCustomers,_that.gettotalPaidCustomers,_that.gettotalUnPaidCustomers,_that.lovEmpGrpCustomers);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'status_code')  int statusCode, @JsonKey(name: 'status_msg')  String statusMsg, @JsonKey(name: 'totalStbs')  int totalStbs, @JsonKey(name: 'totalAssignedStbs')  int totalAssignedStbs, @JsonKey(name: 'totalUnAssignedStbs')  int totalUnAssignedStbs, @JsonKey(name: 'totalComplaints')  int totalComplaints, @JsonKey(name: 'totalClosedComplaints')  int totalClosedComplaints, @JsonKey(name: 'totalActiveCustomers')  int totalActiveCustomers, @JsonKey(name: 'totalDeactiveCustomers')  int totalDeactiveCustomers, @JsonKey(name: 'totalCurrentMonthBill')  double totalCurrentMonthBill, @JsonKey(name: 'totalDueAmount')  double totalDueAmount, @JsonKey(name: 'outStandingAmount')  double outStandingAmount, @JsonKey(name: 'msoShare')  double msoShare, @JsonKey(name: 'totalCurrentMonthMsoShare')  double totalCurrentMonthMsoShare, @JsonKey(name: 'currentMonthOutstanding')  double currentMonthOutstanding, @JsonKey(name: 'currentMonthLCOBill')  double currentMonthLCOBill, @JsonKey(name: 'lcocurrentmonthdueamount')  double lcuCurrentMonthDueAmount, @JsonKey(name: 'totalPaidCustomers')  int totalPaidCustomers, @JsonKey(name: 'totalUnPaidCustomers')  int totalUnPaidCustomers, @JsonKey(name: 'gettotalPaidCustomers')  int gettotalPaidCustomers, @JsonKey(name: 'gettotalUnPaidCustomers')  int gettotalUnPaidCustomers, @JsonKey(name: 'lov_emp_grp_customers')  int? lovEmpGrpCustomers)?  $default,) {final _that = this;
switch (_that) {
case _DashboardResponse() when $default != null:
return $default(_that.statusCode,_that.statusMsg,_that.totalStbs,_that.totalAssignedStbs,_that.totalUnAssignedStbs,_that.totalComplaints,_that.totalClosedComplaints,_that.totalActiveCustomers,_that.totalDeactiveCustomers,_that.totalCurrentMonthBill,_that.totalDueAmount,_that.outStandingAmount,_that.msoShare,_that.totalCurrentMonthMsoShare,_that.currentMonthOutstanding,_that.currentMonthLCOBill,_that.lcuCurrentMonthDueAmount,_that.totalPaidCustomers,_that.totalUnPaidCustomers,_that.gettotalPaidCustomers,_that.gettotalUnPaidCustomers,_that.lovEmpGrpCustomers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DashboardResponse implements DashboardResponse {
  const _DashboardResponse({@JsonKey(name: 'status_code') this.statusCode = 0, @JsonKey(name: 'status_msg') this.statusMsg = '', @JsonKey(name: 'totalStbs') this.totalStbs = 0, @JsonKey(name: 'totalAssignedStbs') this.totalAssignedStbs = 0, @JsonKey(name: 'totalUnAssignedStbs') this.totalUnAssignedStbs = 0, @JsonKey(name: 'totalComplaints') this.totalComplaints = 0, @JsonKey(name: 'totalClosedComplaints') this.totalClosedComplaints = 0, @JsonKey(name: 'totalActiveCustomers') this.totalActiveCustomers = 0, @JsonKey(name: 'totalDeactiveCustomers') this.totalDeactiveCustomers = 0, @JsonKey(name: 'totalCurrentMonthBill') this.totalCurrentMonthBill = 0.0, @JsonKey(name: 'totalDueAmount') this.totalDueAmount = 0.0, @JsonKey(name: 'outStandingAmount') this.outStandingAmount = 0.0, @JsonKey(name: 'msoShare') this.msoShare = 0.0, @JsonKey(name: 'totalCurrentMonthMsoShare') this.totalCurrentMonthMsoShare = 0.0, @JsonKey(name: 'currentMonthOutstanding') this.currentMonthOutstanding = 0.0, @JsonKey(name: 'currentMonthLCOBill') this.currentMonthLCOBill = 0.0, @JsonKey(name: 'lcocurrentmonthdueamount') this.lcuCurrentMonthDueAmount = 0.0, @JsonKey(name: 'totalPaidCustomers') this.totalPaidCustomers = 0, @JsonKey(name: 'totalUnPaidCustomers') this.totalUnPaidCustomers = 0, @JsonKey(name: 'gettotalPaidCustomers') this.gettotalPaidCustomers = 0, @JsonKey(name: 'gettotalUnPaidCustomers') this.gettotalUnPaidCustomers = 0, @JsonKey(name: 'lov_emp_grp_customers') this.lovEmpGrpCustomers});
  factory _DashboardResponse.fromJson(Map<String, dynamic> json) => _$DashboardResponseFromJson(json);

@override@JsonKey(name: 'status_code') final  int statusCode;
@override@JsonKey(name: 'status_msg') final  String statusMsg;
@override@JsonKey(name: 'totalStbs') final  int totalStbs;
@override@JsonKey(name: 'totalAssignedStbs') final  int totalAssignedStbs;
@override@JsonKey(name: 'totalUnAssignedStbs') final  int totalUnAssignedStbs;
@override@JsonKey(name: 'totalComplaints') final  int totalComplaints;
@override@JsonKey(name: 'totalClosedComplaints') final  int totalClosedComplaints;
@override@JsonKey(name: 'totalActiveCustomers') final  int totalActiveCustomers;
@override@JsonKey(name: 'totalDeactiveCustomers') final  int totalDeactiveCustomers;
@override@JsonKey(name: 'totalCurrentMonthBill') final  double totalCurrentMonthBill;
@override@JsonKey(name: 'totalDueAmount') final  double totalDueAmount;
@override@JsonKey(name: 'outStandingAmount') final  double outStandingAmount;
@override@JsonKey(name: 'msoShare') final  double msoShare;
@override@JsonKey(name: 'totalCurrentMonthMsoShare') final  double totalCurrentMonthMsoShare;
@override@JsonKey(name: 'currentMonthOutstanding') final  double currentMonthOutstanding;
@override@JsonKey(name: 'currentMonthLCOBill') final  double currentMonthLCOBill;
@override@JsonKey(name: 'lcocurrentmonthdueamount') final  double lcuCurrentMonthDueAmount;
@override@JsonKey(name: 'totalPaidCustomers') final  int totalPaidCustomers;
@override@JsonKey(name: 'totalUnPaidCustomers') final  int totalUnPaidCustomers;
@override@JsonKey(name: 'gettotalPaidCustomers') final  int gettotalPaidCustomers;
@override@JsonKey(name: 'gettotalUnPaidCustomers') final  int gettotalUnPaidCustomers;
@override@JsonKey(name: 'lov_emp_grp_customers') final  int? lovEmpGrpCustomers;

/// Create a copy of DashboardResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardResponseCopyWith<_DashboardResponse> get copyWith => __$DashboardResponseCopyWithImpl<_DashboardResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DashboardResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardResponse&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.statusMsg, statusMsg) || other.statusMsg == statusMsg)&&(identical(other.totalStbs, totalStbs) || other.totalStbs == totalStbs)&&(identical(other.totalAssignedStbs, totalAssignedStbs) || other.totalAssignedStbs == totalAssignedStbs)&&(identical(other.totalUnAssignedStbs, totalUnAssignedStbs) || other.totalUnAssignedStbs == totalUnAssignedStbs)&&(identical(other.totalComplaints, totalComplaints) || other.totalComplaints == totalComplaints)&&(identical(other.totalClosedComplaints, totalClosedComplaints) || other.totalClosedComplaints == totalClosedComplaints)&&(identical(other.totalActiveCustomers, totalActiveCustomers) || other.totalActiveCustomers == totalActiveCustomers)&&(identical(other.totalDeactiveCustomers, totalDeactiveCustomers) || other.totalDeactiveCustomers == totalDeactiveCustomers)&&(identical(other.totalCurrentMonthBill, totalCurrentMonthBill) || other.totalCurrentMonthBill == totalCurrentMonthBill)&&(identical(other.totalDueAmount, totalDueAmount) || other.totalDueAmount == totalDueAmount)&&(identical(other.outStandingAmount, outStandingAmount) || other.outStandingAmount == outStandingAmount)&&(identical(other.msoShare, msoShare) || other.msoShare == msoShare)&&(identical(other.totalCurrentMonthMsoShare, totalCurrentMonthMsoShare) || other.totalCurrentMonthMsoShare == totalCurrentMonthMsoShare)&&(identical(other.currentMonthOutstanding, currentMonthOutstanding) || other.currentMonthOutstanding == currentMonthOutstanding)&&(identical(other.currentMonthLCOBill, currentMonthLCOBill) || other.currentMonthLCOBill == currentMonthLCOBill)&&(identical(other.lcuCurrentMonthDueAmount, lcuCurrentMonthDueAmount) || other.lcuCurrentMonthDueAmount == lcuCurrentMonthDueAmount)&&(identical(other.totalPaidCustomers, totalPaidCustomers) || other.totalPaidCustomers == totalPaidCustomers)&&(identical(other.totalUnPaidCustomers, totalUnPaidCustomers) || other.totalUnPaidCustomers == totalUnPaidCustomers)&&(identical(other.gettotalPaidCustomers, gettotalPaidCustomers) || other.gettotalPaidCustomers == gettotalPaidCustomers)&&(identical(other.gettotalUnPaidCustomers, gettotalUnPaidCustomers) || other.gettotalUnPaidCustomers == gettotalUnPaidCustomers)&&(identical(other.lovEmpGrpCustomers, lovEmpGrpCustomers) || other.lovEmpGrpCustomers == lovEmpGrpCustomers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,statusCode,statusMsg,totalStbs,totalAssignedStbs,totalUnAssignedStbs,totalComplaints,totalClosedComplaints,totalActiveCustomers,totalDeactiveCustomers,totalCurrentMonthBill,totalDueAmount,outStandingAmount,msoShare,totalCurrentMonthMsoShare,currentMonthOutstanding,currentMonthLCOBill,lcuCurrentMonthDueAmount,totalPaidCustomers,totalUnPaidCustomers,gettotalPaidCustomers,gettotalUnPaidCustomers,lovEmpGrpCustomers]);

@override
String toString() {
  return 'DashboardResponse(statusCode: $statusCode, statusMsg: $statusMsg, totalStbs: $totalStbs, totalAssignedStbs: $totalAssignedStbs, totalUnAssignedStbs: $totalUnAssignedStbs, totalComplaints: $totalComplaints, totalClosedComplaints: $totalClosedComplaints, totalActiveCustomers: $totalActiveCustomers, totalDeactiveCustomers: $totalDeactiveCustomers, totalCurrentMonthBill: $totalCurrentMonthBill, totalDueAmount: $totalDueAmount, outStandingAmount: $outStandingAmount, msoShare: $msoShare, totalCurrentMonthMsoShare: $totalCurrentMonthMsoShare, currentMonthOutstanding: $currentMonthOutstanding, currentMonthLCOBill: $currentMonthLCOBill, lcuCurrentMonthDueAmount: $lcuCurrentMonthDueAmount, totalPaidCustomers: $totalPaidCustomers, totalUnPaidCustomers: $totalUnPaidCustomers, gettotalPaidCustomers: $gettotalPaidCustomers, gettotalUnPaidCustomers: $gettotalUnPaidCustomers, lovEmpGrpCustomers: $lovEmpGrpCustomers)';
}


}

/// @nodoc
abstract mixin class _$DashboardResponseCopyWith<$Res> implements $DashboardResponseCopyWith<$Res> {
  factory _$DashboardResponseCopyWith(_DashboardResponse value, $Res Function(_DashboardResponse) _then) = __$DashboardResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'status_code') int statusCode,@JsonKey(name: 'status_msg') String statusMsg,@JsonKey(name: 'totalStbs') int totalStbs,@JsonKey(name: 'totalAssignedStbs') int totalAssignedStbs,@JsonKey(name: 'totalUnAssignedStbs') int totalUnAssignedStbs,@JsonKey(name: 'totalComplaints') int totalComplaints,@JsonKey(name: 'totalClosedComplaints') int totalClosedComplaints,@JsonKey(name: 'totalActiveCustomers') int totalActiveCustomers,@JsonKey(name: 'totalDeactiveCustomers') int totalDeactiveCustomers,@JsonKey(name: 'totalCurrentMonthBill') double totalCurrentMonthBill,@JsonKey(name: 'totalDueAmount') double totalDueAmount,@JsonKey(name: 'outStandingAmount') double outStandingAmount,@JsonKey(name: 'msoShare') double msoShare,@JsonKey(name: 'totalCurrentMonthMsoShare') double totalCurrentMonthMsoShare,@JsonKey(name: 'currentMonthOutstanding') double currentMonthOutstanding,@JsonKey(name: 'currentMonthLCOBill') double currentMonthLCOBill,@JsonKey(name: 'lcocurrentmonthdueamount') double lcuCurrentMonthDueAmount,@JsonKey(name: 'totalPaidCustomers') int totalPaidCustomers,@JsonKey(name: 'totalUnPaidCustomers') int totalUnPaidCustomers,@JsonKey(name: 'gettotalPaidCustomers') int gettotalPaidCustomers,@JsonKey(name: 'gettotalUnPaidCustomers') int gettotalUnPaidCustomers,@JsonKey(name: 'lov_emp_grp_customers') int? lovEmpGrpCustomers
});




}
/// @nodoc
class __$DashboardResponseCopyWithImpl<$Res>
    implements _$DashboardResponseCopyWith<$Res> {
  __$DashboardResponseCopyWithImpl(this._self, this._then);

  final _DashboardResponse _self;
  final $Res Function(_DashboardResponse) _then;

/// Create a copy of DashboardResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? statusCode = null,Object? statusMsg = null,Object? totalStbs = null,Object? totalAssignedStbs = null,Object? totalUnAssignedStbs = null,Object? totalComplaints = null,Object? totalClosedComplaints = null,Object? totalActiveCustomers = null,Object? totalDeactiveCustomers = null,Object? totalCurrentMonthBill = null,Object? totalDueAmount = null,Object? outStandingAmount = null,Object? msoShare = null,Object? totalCurrentMonthMsoShare = null,Object? currentMonthOutstanding = null,Object? currentMonthLCOBill = null,Object? lcuCurrentMonthDueAmount = null,Object? totalPaidCustomers = null,Object? totalUnPaidCustomers = null,Object? gettotalPaidCustomers = null,Object? gettotalUnPaidCustomers = null,Object? lovEmpGrpCustomers = freezed,}) {
  return _then(_DashboardResponse(
statusCode: null == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int,statusMsg: null == statusMsg ? _self.statusMsg : statusMsg // ignore: cast_nullable_to_non_nullable
as String,totalStbs: null == totalStbs ? _self.totalStbs : totalStbs // ignore: cast_nullable_to_non_nullable
as int,totalAssignedStbs: null == totalAssignedStbs ? _self.totalAssignedStbs : totalAssignedStbs // ignore: cast_nullable_to_non_nullable
as int,totalUnAssignedStbs: null == totalUnAssignedStbs ? _self.totalUnAssignedStbs : totalUnAssignedStbs // ignore: cast_nullable_to_non_nullable
as int,totalComplaints: null == totalComplaints ? _self.totalComplaints : totalComplaints // ignore: cast_nullable_to_non_nullable
as int,totalClosedComplaints: null == totalClosedComplaints ? _self.totalClosedComplaints : totalClosedComplaints // ignore: cast_nullable_to_non_nullable
as int,totalActiveCustomers: null == totalActiveCustomers ? _self.totalActiveCustomers : totalActiveCustomers // ignore: cast_nullable_to_non_nullable
as int,totalDeactiveCustomers: null == totalDeactiveCustomers ? _self.totalDeactiveCustomers : totalDeactiveCustomers // ignore: cast_nullable_to_non_nullable
as int,totalCurrentMonthBill: null == totalCurrentMonthBill ? _self.totalCurrentMonthBill : totalCurrentMonthBill // ignore: cast_nullable_to_non_nullable
as double,totalDueAmount: null == totalDueAmount ? _self.totalDueAmount : totalDueAmount // ignore: cast_nullable_to_non_nullable
as double,outStandingAmount: null == outStandingAmount ? _self.outStandingAmount : outStandingAmount // ignore: cast_nullable_to_non_nullable
as double,msoShare: null == msoShare ? _self.msoShare : msoShare // ignore: cast_nullable_to_non_nullable
as double,totalCurrentMonthMsoShare: null == totalCurrentMonthMsoShare ? _self.totalCurrentMonthMsoShare : totalCurrentMonthMsoShare // ignore: cast_nullable_to_non_nullable
as double,currentMonthOutstanding: null == currentMonthOutstanding ? _self.currentMonthOutstanding : currentMonthOutstanding // ignore: cast_nullable_to_non_nullable
as double,currentMonthLCOBill: null == currentMonthLCOBill ? _self.currentMonthLCOBill : currentMonthLCOBill // ignore: cast_nullable_to_non_nullable
as double,lcuCurrentMonthDueAmount: null == lcuCurrentMonthDueAmount ? _self.lcuCurrentMonthDueAmount : lcuCurrentMonthDueAmount // ignore: cast_nullable_to_non_nullable
as double,totalPaidCustomers: null == totalPaidCustomers ? _self.totalPaidCustomers : totalPaidCustomers // ignore: cast_nullable_to_non_nullable
as int,totalUnPaidCustomers: null == totalUnPaidCustomers ? _self.totalUnPaidCustomers : totalUnPaidCustomers // ignore: cast_nullable_to_non_nullable
as int,gettotalPaidCustomers: null == gettotalPaidCustomers ? _self.gettotalPaidCustomers : gettotalPaidCustomers // ignore: cast_nullable_to_non_nullable
as int,gettotalUnPaidCustomers: null == gettotalUnPaidCustomers ? _self.gettotalUnPaidCustomers : gettotalUnPaidCustomers // ignore: cast_nullable_to_non_nullable
as int,lovEmpGrpCustomers: freezed == lovEmpGrpCustomers ? _self.lovEmpGrpCustomers : lovEmpGrpCustomers // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
