// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mini_day_report_row.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MiniDayReportRow _$MiniDayReportRowFromJson(Map<String, dynamic> json) =>
    _MiniDayReportRow(
      paymentMode: json['payment_mode'] as String? ?? '',
      custCount: (json['cust_count'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$MiniDayReportRowToJson(_MiniDayReportRow instance) =>
    <String, dynamic>{
      'payment_mode': instance.paymentMode,
      'cust_count': instance.custCount,
      'total': instance.total,
    };
