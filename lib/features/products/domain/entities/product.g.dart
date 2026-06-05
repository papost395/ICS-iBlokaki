// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  id: json['id'] as String,
  shopId: json['shopId'] as String,
  categoryId: json['categoryId'] as String,
  name: json['name'] as String,
  price: (json['price'] as num).toDouble(),
  department:
      $enumDecodeNullable(_$DepartmentEnumMap, json['department']) ??
      Department.none,
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'id': instance.id,
  'shopId': instance.shopId,
  'categoryId': instance.categoryId,
  'name': instance.name,
  'price': instance.price,
  'department': _$DepartmentEnumMap[instance.department]!,
};

const _$DepartmentEnumMap = {
  Department.kitchen: 'kitchen',
  Department.bar: 'bar',
  Department.none: 'none',
};
