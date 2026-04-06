import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_type.freezed.dart';
part 'customer_type.g.dart';

@freezed
sealed class CustomerType with _$CustomerType {
  const factory CustomerType({
    @JsonKey(name: 'customer_type_id') @Default(0) int customerTypeId,
    @JsonKey(name: 'customer_type') @Default('') String customerType,
    @JsonKey(name: 'description') @Default('') String description,
    @JsonKey(name: 'status') @Default(0) int status,
    @JsonKey(name: 'is_commercial_multi_box') @Default(0) int isCommercialMultiBox,
    @JsonKey(name: 'enable_display') @Default(0) int enableDisplay,
  }) = _CustomerType;

  factory CustomerType.fromJson(Map<String, dynamic> json) =>
      _$CustomerTypeFromJson(_sanitize(json));
}

Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
  final r = Map<String, dynamic>.from(json);
  const intFields = [
    'customer_type_id',
    'status',
    'is_commercial_multi_box',
    'enable_display',
  ];
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
