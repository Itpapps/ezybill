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

  // The server's getComplaintsubCategory_post emits each row as
  //   {complaint_category_id, complaint_category_name}
  // — the same keys Android reads in GetSubcategoriesRest. Map them onto the
  // model's camelCase fields when those are absent, so the generated fromJson
  // (which only knows subCategoryId / subCategoryName) sees populated values.
  if (!r.containsKey('subCategoryId') && r.containsKey('complaint_category_id')) {
    r['subCategoryId'] = r['complaint_category_id'];
  }
  if (!r.containsKey('subCategoryName') &&
      r.containsKey('complaint_category_name')) {
    r['subCategoryName'] = r['complaint_category_name'];
  }

  const intFields = ['subCategoryId', 'categoryId'];
  for (final key in intFields) {
    final v = r[key];
    if (v is String) {
      r[key] = int.tryParse(v) ?? 0;
    } else if (v == null) {
      r[key] = null;
    }
  }
  // The server may emit the name as a number when the row is malformed
  // (`isset(...) ? ... : 0`); keep the String cast in fromJson safe.
  if (r['subCategoryName'] is num) r['subCategoryName'] = r['subCategoryName'].toString();
  return r;
}
