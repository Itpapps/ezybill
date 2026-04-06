import 'package:freezed_annotation/freezed_annotation.dart';

part 'invoice_item.freezed.dart';
part 'invoice_item.g.dart';

@freezed
sealed class InvoiceItem with _$InvoiceItem {
  const factory InvoiceItem({
    @JsonKey(name: 'billingId') @Default('') String billingId,
    @JsonKey(name: 'billDate') @Default('') String billDate,
    @JsonKey(name: 'dueDate') @Default('') String dueDate,
    @JsonKey(name: 'totalAmount') @Default(0.0) double totalAmount,
    @JsonKey(name: 'quantity') @Default(0) int quantity,
    @JsonKey(name: 'basePrice') @Default(0.0) double basePrice,
    @JsonKey(name: 'serialNumber') @Default('') String serialNumber,
    @JsonKey(name: 'macVcNumber') @Default('') String macVcNumber,
    @JsonKey(name: 'pname') @Default('') String pname,
    @JsonKey(name: 'setupPrice') @Default(0.0) double setupPrice,
    @JsonKey(name: 'taxAmount') @Default(0.0) double taxAmount,
    @JsonKey(name: 'pendingAmount') @Default(0.0) double pendingAmount,
    @JsonKey(name: 'discountAmount') @Default(0.0) double discountAmount,
    @JsonKey(name: 'isAdhoc') @Default(0) int isAdhoc,
  }) = _InvoiceItem;

  factory InvoiceItem.fromJson(Map<String, dynamic> json) =>
      _$InvoiceItemFromJson(_sanitize(json));

  static Map<String, dynamic> _sanitize(Map<String, dynamic> json) {
    final r = Map<String, dynamic>.from(json);
    const doubleFields = [
      'totalAmount', 'basePrice', 'setupPrice',
      'taxAmount', 'pendingAmount', 'discountAmount',
    ];
    const intFields = ['quantity', 'isAdhoc'];
    for (final key in doubleFields) {
      final v = r[key];
      if (v is String) r[key] = double.tryParse(v) ?? 0.0;
      if (v == null) r[key] = 0.0;
    }
    for (final key in intFields) {
      final v = r[key];
      if (v is String) r[key] = int.tryParse(v) ?? 0;
      if (v == null) r[key] = 0;
    }
    return r;
  }
}
