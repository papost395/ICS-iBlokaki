// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => _OrderItem(
  id: json['id'] as String,
  orderId: json['orderId'] as String,
  productId: json['productId'] as String,
  productName: json['productName'] as String,
  quantity: (json['quantity'] as num).toInt(),
  priceAtOrder: (json['priceAtOrder'] as num).toDouble(),
  department:
      $enumDecodeNullable(_$DepartmentEnumMap, json['department']) ??
      Department.none,
  notes: json['notes'] as String? ?? '',
  printStatus: json['printStatus'] as String? ?? 'pending',
  receiptOnly: json['receiptOnly'] as bool? ?? false,
);

Map<String, dynamic> _$OrderItemToJson(_OrderItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'productId': instance.productId,
      'productName': instance.productName,
      'quantity': instance.quantity,
      'priceAtOrder': instance.priceAtOrder,
      'department': _$DepartmentEnumMap[instance.department]!,
      'notes': instance.notes,
      'printStatus': instance.printStatus,
      'receiptOnly': instance.receiptOnly,
    };

const _$DepartmentEnumMap = {
  Department.kitchen: 'kitchen',
  Department.bar: 'bar',
  Department.none: 'none',
};
