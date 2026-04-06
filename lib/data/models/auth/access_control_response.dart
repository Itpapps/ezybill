import 'package:freezed_annotation/freezed_annotation.dart';

part 'access_control_response.freezed.dart';
part 'access_control_response.g.dart';

/// Access control flags for the current user session.
///
/// CRITICAL: This endpoint uses inverted status codes:
///   status_code 0 = success
///   status_code 1 = failure
/// This is the OPPOSITE of all other endpoints in the API.
@freezed
sealed class AccessControlResponse with _$AccessControlResponse {
  const factory AccessControlResponse({
    // status_code 0 = success (inverted convention!)
    @JsonKey(name: 'status_code') @Default(1) int statusCode,
    @JsonKey(name: 'status_msg') @Default('') String statusMsg,
    @JsonKey(name: 'int_bulk_payment') @Default(1) int intBulkPayment,
    @JsonKey(name: 'invoice_page_access') @Default(1) int invoicePageAccess,
    @JsonKey(name: 'payment_hist_page_access') @Default(1) int paymentHistPageAccess,
    @JsonKey(name: 'access_for_complaints') @Default(1) int accessForComplaints,
    @JsonKey(name: 'int_stb_activation') @Default(1) int intStbActivation,
    @JsonKey(name: 'int_stb_deactivation') @Default(1) int intStbDeactivation,
    @JsonKey(name: 'int_stb_reactivation') @Default(1) int intStbReactivation,
    @JsonKey(name: 'int_payment_transaction_report_access') @Default(0) int pgTransactionReportAccess,
    @JsonKey(name: 'pgtransaction') @Default(0) int pgtransaction,
  }) = _AccessControlResponse;

  factory AccessControlResponse.fromJson(Map<String, dynamic> json) =>
      _$AccessControlResponseFromJson(_sanitizeAclJson(json));
}

Map<String, dynamic> _sanitizeAclJson(Map<String, dynamic> json) {
  final result = Map<String, dynamic>.from(json);
  for (final key in result.keys.toList()) {
    if (result[key] is String) {
      final parsed = int.tryParse(result[key] as String);
      if (parsed != null) result[key] = parsed;
    }
  }
  return result;
}
