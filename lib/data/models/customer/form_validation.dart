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
      _$FormValidationFromJson(json);
}
