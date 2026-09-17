import 'package:freezed_annotation/freezed_annotation.dart';

part 'form_validation.freezed.dart';
part 'form_validation.g.dart';

@freezed
sealed class FormValidation with _$FormValidation {
  const factory FormValidation({
    @JsonKey(name: 'column_name') required String columnName,
    @JsonKey(name: 'is_mandatory') required String isMandatory,
  }) = _FormValidation;

  factory FormValidation.fromJson(Map<String, dynamic> json) =>
      _$FormValidationFromJson(_sanitize(json));

  /// `is_mandatory` is a numeric-looking value ("1" / "0"). If it ever arrives
  /// as a real number, the generated `as String` cast throws, the exception is
  /// swallowed in loadFormValidations, and the WHOLE list comes back empty —
  /// every mandatory flag silently off. Coerce to String so one row can never
  /// take the rest down.
  static Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
    final r = Map<String, dynamic>.from(json);
    for (final key in const ['column_name', 'is_mandatory']) {
      final v = r[key];
      if (v is num || v is bool) r[key] = v.toString();
      if (v == null) r[key] = '';
    }
    return r;
  }
}
