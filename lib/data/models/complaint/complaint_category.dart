import 'package:freezed_annotation/freezed_annotation.dart';

part 'complaint_category.freezed.dart';
part 'complaint_category.g.dart';

@freezed
sealed class ComplaintCategory with _$ComplaintCategory {
  const factory ComplaintCategory({
    @JsonKey(name: 'categoryId') @Default(0) int categoryId,
    @JsonKey(name: 'categoryName') @Default('') String categoryName,
    @JsonKey(name: 'parent_category_id') @Default(0) int parentCategoryId,
  }) = _ComplaintCategory;

  factory ComplaintCategory.fromJson(Map<String, dynamic> json) =>
      _$ComplaintCategoryFromJson(_sanitize(json));
}

Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
  final r = Map<String, dynamic>.from(json);
  const intFields = ['categoryId', 'parent_category_id'];
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
