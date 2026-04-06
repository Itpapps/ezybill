import 'package:freezed_annotation/freezed_annotation.dart';

part 'complaint_subcategory.freezed.dart';
part 'complaint_subcategory.g.dart';

@freezed
sealed class ComplaintSubcategory with _$ComplaintSubcategory {
  const factory ComplaintSubcategory({
    @JsonKey(name: 'subCategoryId') @Default(0) int subCategoryId,
    @JsonKey(name: 'subCategoryName') @Default('') String subCategoryName,
    @JsonKey(name: 'categoryId') @Default(0) int categoryId,
  }) = _ComplaintSubcategory;

  factory ComplaintSubcategory.fromJson(Map<String, dynamic> json) =>
      _$ComplaintSubcategoryFromJson(_sanitize(json));
}

Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
  final r = Map<String, dynamic>.from(json);
  const intFields = ['subCategoryId', 'categoryId'];
  for (final key in intFields) {
    final v = r[key];
    if (v is String) {
      r[key] = int.tryParse(v) ?? 0;
    } else if (v == null) {
      r[key] = null;
    }
  }
  return r;
}
