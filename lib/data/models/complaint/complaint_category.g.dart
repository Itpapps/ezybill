// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complaint_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ComplaintCategory _$ComplaintCategoryFromJson(Map<String, dynamic> json) =>
    _ComplaintCategory(
      categoryId: (json['categoryId'] as num?)?.toInt() ?? 0,
      categoryName: json['categoryName'] as String? ?? '',
      parentCategoryId: (json['parent_category_id'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ComplaintCategoryToJson(_ComplaintCategory instance) =>
    <String, dynamic>{
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'parent_category_id': instance.parentCategoryId,
    };
