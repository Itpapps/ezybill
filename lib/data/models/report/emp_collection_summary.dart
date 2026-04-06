import 'package:freezed_annotation/freezed_annotation.dart';

part 'emp_collection_summary.freezed.dart';
part 'emp_collection_summary.g.dart';

@freezed
sealed class EmpCollectionSummary with _$EmpCollectionSummary {
  const factory EmpCollectionSummary({
    @JsonKey(name: 'employee_id') @Default('') String employeeId,
    @JsonKey(name: 'name') @Default('') String name,
    @JsonKey(name: 'Amt') @Default(0.0) double amt,
  }) = _EmpCollectionSummary;

  factory EmpCollectionSummary.fromJson(Map<String, dynamic> json) =>
      _$EmpCollectionSummaryFromJson(_sanitize(json));
}

Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
  final r = Map<String, dynamic>.from(json);

  // Handle nullable String fields
  for (final key in ['employee_id', 'name']) {
    if (r[key] == null) {
      r[key] = null; // Let @Default handle it
    } else if (r[key] is! String) {
      r[key] = r[key].toString();
    }
  }

  // Handle nullable double field
  final amt = r['Amt'];
  if (amt is String) {
    r['Amt'] = double.tryParse(amt) ?? 0.0;
  } else if (amt is int) {
    r['Amt'] = amt.toDouble();
  } else if (amt == null) {
    r['Amt'] = null; // Let @Default handle it
  }

  return r;
}
