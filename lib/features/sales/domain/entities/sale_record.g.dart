// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SaleRecord _$SaleRecordFromJson(Map<String, dynamic> json) => _SaleRecord(
  id: json['id'] as String,
  shopId: json['shopId'] as String,
  productId: json['productId'] as String,
  productName: json['productName'] as String,
  quantity: (json['quantity'] as num).toInt(),
  price: (json['price'] as num).toDouble(),
  timestamp: (json['timestamp'] as num).toInt(),
);

Map<String, dynamic> _$SaleRecordToJson(_SaleRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shopId': instance.shopId,
      'productId': instance.productId,
      'productName': instance.productName,
      'quantity': instance.quantity,
      'price': instance.price,
      'timestamp': instance.timestamp,
    };
