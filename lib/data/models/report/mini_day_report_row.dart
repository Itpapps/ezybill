import 'package:freezed_annotation/freezed_annotation.dart';

part 'mini_day_report_row.freezed.dart';
part 'mini_day_report_row.g.dart';

@freezed
sealed class MiniDayReportRow with _$MiniDayReportRow {
  const factory MiniDayReportRow({
    @JsonKey(name: 'payment_mode') @Default('') String paymentMode,
    @JsonKey(name: 'cust_count') @Default(0) int custCount,
    @JsonKey(name: 'total') @Default(0.0) double total,
  }) = _MiniDayReportRow;

  factory MiniDayReportRow.fromJson(Map<String, dynamic> json) =>
      _$MiniDayReportRowFromJson(_sanitize(json));
}

Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
  final r = Map<String, dynamic>.from(json);
  // int fields
  const intFields = ['cust_count'];
  for (final key in intFields) {
    final v = r[key];
    if (v is String) {
      r[key] = int.tryParse(v) ?? 0;
    } else if (v == null) {
      r[key] = null;
    }
  }
  // double fields
  const doubleFields = ['total'];
  for (final key in doubleFields) {
    final v = r[key];
    if (v is String) {
      r[key] = double.tryParse(v) ?? 0.0;
    } else if (v is int) {
      r[key] = v.toDouble();
    } else if (v == null) {
      r[key] = null;
    }
  }
  return r;
}
