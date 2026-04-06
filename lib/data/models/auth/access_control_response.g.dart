// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'access_control_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AccessControlResponse _$AccessControlResponseFromJson(
  Map<String, dynamic> json,
) => _AccessControlResponse(
  statusCode: (json['status_code'] as num?)?.toInt() ?? 1,
  statusMsg: json['status_msg'] as String? ?? '',
  intBulkPayment: (json['int_bulk_payment'] as num?)?.toInt() ?? 1,
  invoicePageAccess: (json['invoice_page_access'] as num?)?.toInt() ?? 1,
  paymentHistPageAccess:
      (json['payment_hist_page_access'] as num?)?.toInt() ?? 1,
  accessForComplaints: (json['access_for_complaints'] as num?)?.toInt() ?? 1,
  intStbActivation: (json['int_stb_activation'] as num?)?.toInt() ?? 1,
  intStbDeactivation: (json['int_stb_deactivation'] as num?)?.toInt() ?? 1,
  intStbReactivation: (json['int_stb_reactivation'] as num?)?.toInt() ?? 1,
  pgTransactionReportAccess:
      (json['int_payment_transaction_report_access'] as num?)?.toInt() ?? 0,
  pgtransaction: (json['pgtransaction'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$AccessControlResponseToJson(
  _AccessControlResponse instance,
) => <String, dynamic>{
  'status_code': instance.statusCode,
  'status_msg': instance.statusMsg,
  'int_bulk_payment': instance.intBulkPayment,
  'invoice_page_access': instance.invoicePageAccess,
  'payment_hist_page_access': instance.paymentHistPageAccess,
  'access_for_complaints': instance.accessForComplaints,
  'int_stb_activation': instance.intStbActivation,
  'int_stb_deactivation': instance.intStbDeactivation,
  'int_stb_reactivation': instance.intStbReactivation,
  'int_payment_transaction_report_access': instance.pgTransactionReportAccess,
  'pgtransaction': instance.pgtransaction,
};
