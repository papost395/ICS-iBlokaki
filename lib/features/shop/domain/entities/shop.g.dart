// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Shop _$ShopFromJson(Map<String, dynamic> json) => _Shop(
  id: json['id'] as String,
  name: json['name'] as String,
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$ShopToJson(_Shop instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'isActive': instance.isActive,
};
