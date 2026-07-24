// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InvoiceItem _$InvoiceItemFromJson(Map<String, dynamic> json) => _InvoiceItem(
  billingId: json['billingId'] as String? ?? '',
  billDate: json['billDate'] as String? ?? '',
  dueDate: json['dueDate'] as String? ?? '',
  totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
  quantity: (json['quantity'] as num?)?.toInt() ?? 0,
  basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
  serialNumber: json['serialNumber'] as String? ?? '',
  macVcNumber: json['macVcNumber'] as String? ?? '',
  pname: json['pname'] as String? ?? '',
  setupPrice: (json['setupPrice'] as num?)?.toDouble() ?? 0.0,
  taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
  pendingAmount: (json['pendingAmount'] as num?)?.toDouble() ?? 0.0,
  discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
  isAdhoc: (json['isAdhoc'] as num?)?.toInt() ?? 0,
  billAmount: (json['billAmount'] as num?)?.toDouble() ?? 0.0,
  msoShare: (json['msoShare'] as num?)?.toDouble() ?? 0.0,
  billPeriodStartDate: json['billPeriodStartDate'] as String? ?? '',
  billPeriodEndDate: json['billPeriodEndDate'] as String? ?? '',
  remarks: json['remarks'] as String? ?? '',
);

Map<String, dynamic> _$InvoiceItemToJson(_InvoiceItem instance) =>
    <String, dynamic>{
      'billingId': instance.billingId,
      'billDate': instance.billDate,
      'dueDate': instance.dueDate,
      'totalAmount': instance.totalAmount,
      'quantity': instance.quantity,
      'basePrice': instance.basePrice,
      'serialNumber': instance.serialNumber,
      'macVcNumber': instance.macVcNumber,
      'pname': instance.pname,
      'setupPrice': instance.setupPrice,
      'taxAmount': instance.taxAmount,
      'pendingAmount': instance.pendingAmount,
      'discountAmount': instance.discountAmount,
      'isAdhoc': instance.isAdhoc,
      'billAmount': instance.billAmount,
      'msoShare': instance.msoShare,
      'billPeriodStartDate': instance.billPeriodStartDate,
      'billPeriodEndDate': instance.billPeriodEndDate,
      'remarks': instance.remarks,
    };
