// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DashboardResponse _$DashboardResponseFromJson(
  Map<String, dynamic> json,
) => _DashboardResponse(
  statusCode: (json['status_code'] as num?)?.toInt() ?? 0,
  statusMsg: json['status_msg'] as String? ?? '',
  totalStbs: (json['totalStbs'] as num?)?.toInt() ?? 0,
  totalAssignedStbs: (json['totalAssignedStbs'] as num?)?.toInt() ?? 0,
  totalUnAssignedStbs: (json['totalUnAssignedStbs'] as num?)?.toInt() ?? 0,
  totalComplaints: (json['totalComplaints'] as num?)?.toInt() ?? 0,
  totalClosedComplaints: (json['totalClosedComplaints'] as num?)?.toInt() ?? 0,
  totalActiveCustomers: (json['totalActiveCustomers'] as num?)?.toInt() ?? 0,
  totalDeactiveCustomers:
      (json['totalDeactiveCustomers'] as num?)?.toInt() ?? 0,
  totalCurrentMonthBill:
      (json['totalCurrentMonthBill'] as num?)?.toDouble() ?? 0.0,
  totalDueAmount: (json['totalDueAmount'] as num?)?.toDouble() ?? 0.0,
  outStandingAmount: (json['outStandingAmount'] as num?)?.toDouble() ?? 0.0,
  msoShare: (json['msoShare'] as num?)?.toDouble() ?? 0.0,
  totalCurrentMonthMsoShare:
      (json['totalCurrentMonthMsoShare'] as num?)?.toDouble() ?? 0.0,
  currentMonthOutstanding:
      (json['currentMonthOutstanding'] as num?)?.toDouble() ?? 0.0,
  currentMonthLCOBill: (json['currentMonthLCOBill'] as num?)?.toDouble() ?? 0.0,
  lcuCurrentMonthDueAmount:
      (json['lcocurrentmonthdueamount'] as num?)?.toDouble() ?? 0.0,
  totalPaidCustomers: (json['totalPaidCustomers'] as num?)?.toInt() ?? 0,
  totalUnPaidCustomers: (json['totalUnPaidCustomers'] as num?)?.toInt() ?? 0,
  gettotalPaidCustomers: (json['gettotalPaidCustomers'] as num?)?.toInt() ?? 0,
  gettotalUnPaidCustomers:
      (json['gettotalUnPaidCustomers'] as num?)?.toInt() ?? 0,
  lovEmpGrpCustomers: (json['lov_emp_grp_customers'] as num?)?.toInt(),
);

Map<String, dynamic> _$DashboardResponseToJson(_DashboardResponse instance) =>
    <String, dynamic>{
      'status_code': instance.statusCode,
      'status_msg': instance.statusMsg,
      'totalStbs': instance.totalStbs,
      'totalAssignedStbs': instance.totalAssignedStbs,
      'totalUnAssignedStbs': instance.totalUnAssignedStbs,
      'totalComplaints': instance.totalComplaints,
      'totalClosedComplaints': instance.totalClosedComplaints,
      'totalActiveCustomers': instance.totalActiveCustomers,
      'totalDeactiveCustomers': instance.totalDeactiveCustomers,
      'totalCurrentMonthBill': instance.totalCurrentMonthBill,
      'totalDueAmount': instance.totalDueAmount,
      'outStandingAmount': instance.outStandingAmount,
      'msoShare': instance.msoShare,
      'totalCurrentMonthMsoShare': instance.totalCurrentMonthMsoShare,
      'currentMonthOutstanding': instance.currentMonthOutstanding,
      'currentMonthLCOBill': instance.currentMonthLCOBill,
      'lcocurrentmonthdueamount': instance.lcuCurrentMonthDueAmount,
      'totalPaidCustomers': instance.totalPaidCustomers,
      'totalUnPaidCustomers': instance.totalUnPaidCustomers,
      'gettotalPaidCustomers': instance.gettotalPaidCustomers,
      'gettotalUnPaidCustomers': instance.gettotalUnPaidCustomers,
      'lov_emp_grp_customers': instance.lovEmpGrpCustomers,
    };
