// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complaint_subcategory.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ComplaintSubcategory _$ComplaintSubcategoryFromJson(
  Map<String, dynamic> json,
) => _ComplaintSubcategory(
  subCategoryId: (json['subCategoryId'] as num?)?.toInt() ?? 0,
  subCategoryName: json['subCategoryName'] as String? ?? '',
  categoryId: (json['categoryId'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ComplaintSubcategoryToJson(
  _ComplaintSubcategory instance,
) => <String, dynamic>{
  'subCategoryId': instance.subCategoryId,
  'subCategoryName': instance.subCategoryName,
  'categoryId': instance.categoryId,
};
