import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_response.freezed.dart';
part 'dashboard_response.g.dart';

@freezed
sealed class DashboardResponse with _$DashboardResponse {
  const factory DashboardResponse({
    @JsonKey(name: 'status_code') @Default(0) int statusCode,
    @JsonKey(name: 'status_msg') @Default('') String statusMsg,
    @JsonKey(name: 'totalStbs') @Default(0) int totalStbs,
    @JsonKey(name: 'totalAssignedStbs') @Default(0) int totalAssignedStbs,
    @JsonKey(name: 'totalUnAssignedStbs') @Default(0) int totalUnAssignedStbs,
    @JsonKey(name: 'totalComplaints') @Default(0) int totalComplaints,
    @JsonKey(name: 'totalClosedComplaints') @Default(0) int totalClosedComplaints,
    @JsonKey(name: 'totalActiveCustomers') @Default(0) int totalActiveCustomers,
    @JsonKey(name: 'totalDeactiveCustomers') @Default(0) int totalDeactiveCustomers,
    @JsonKey(name: 'totalCurrentMonthBill') @Default(0.0) double totalCurrentMonthBill,
    @JsonKey(name: 'totalDueAmount') @Default(0.0) double totalDueAmount,
    @JsonKey(name: 'outStandingAmount') @Default(0.0) double outStandingAmount,
    @JsonKey(name: 'msoShare') @Default(0.0) double msoShare,
    @JsonKey(name: 'totalCurrentMonthMsoShare') @Default(0.0) double totalCurrentMonthMsoShare,
    @JsonKey(name: 'currentMonthOutstanding') @Default(0.0) double currentMonthOutstanding,
    @JsonKey(name: 'currentMonthLCOBill') @Default(0.0) double currentMonthLCOBill,
    @JsonKey(name: 'lcocurrentmonthdueamount') @Default(0.0) double lcuCurrentMonthDueAmount,
    @JsonKey(name: 'totalPaidCustomers') @Default(0) int totalPaidCustomers,
    @JsonKey(name: 'totalUnPaidCustomers') @Default(0) int totalUnPaidCustomers,
    @JsonKey(name: 'gettotalPaidCustomers') @Default(0) int gettotalPaidCustomers,
    @JsonKey(name: 'gettotalUnPaidCustomers') @Default(0) int gettotalUnPaidCustomers,
    @JsonKey(name: 'lov_emp_grp_customers') int? lovEmpGrpCustomers,
  }) = _DashboardResponse;

  factory DashboardResponse.fromJson(Map<String, dynamic> json) =>
      _$DashboardResponseFromJson(_sanitize(json));

  static Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
    final r = Map<String, dynamic>.from(json);
    const intFields = [
      'status_code', 'totalStbs', 'totalAssignedStbs', 'totalUnAssignedStbs',
      'totalComplaints', 'totalClosedComplaints', 'totalActiveCustomers',
      'totalDeactiveCustomers', 'totalPaidCustomers', 'totalUnPaidCustomers',
      'gettotalPaidCustomers', 'gettotalUnPaidCustomers', 'lov_emp_grp_customers',
    ];
    const doubleFields = [
      'totalCurrentMonthBill', 'totalDueAmount', 'outStandingAmount',
      'msoShare', 'totalCurrentMonthMsoShare', 'currentMonthOutstanding',
      'currentMonthLCOBill', 'lcocurrentmonthdueamount',
    ];
    for (final key in intFields) {
      final v = r[key];
      if (v is String) r[key] = int.tryParse(v) ?? 0;
      if (v is List || v is Map) r[key] = 0;
    }
    for (final key in doubleFields) {
      final v = r[key];
      if (v == null) r[key] = 0.0;
      else if (v is String) r[key] = double.tryParse(v) ?? 0.0;
      else if (v is List || v is Map) r[key] = 0.0;
    }
    return r;
  }
}
