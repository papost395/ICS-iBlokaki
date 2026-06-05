// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Order _$OrderFromJson(Map<String, dynamic> json) => _Order(
  id: json['id'] as String,
  shopId: json['shopId'] as String,
  tableId: json['tableId'] as String,
  waiterId: json['waiterId'] as String,
  status:
      $enumDecodeNullable(_$OrderStatusEnumMap, json['status']) ??
      OrderStatus.pending,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  total: (json['total'] as num?)?.toDouble() ?? 0.0,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$OrderToJson(_Order instance) => <String, dynamic>{
  'id': instance.id,
  'shopId': instance.shopId,
  'tableId': instance.tableId,
  'waiterId': instance.waiterId,
  'status': _$OrderStatusEnumMap[instance.status]!,
  'items': instance.items,
  'total': instance.total,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.inProgress: 'in_progress',
  OrderStatus.completed: 'completed',
  OrderStatus.cancelled: 'cancelled',
};
