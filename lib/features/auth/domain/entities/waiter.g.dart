// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'waiter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Waiter _$WaiterFromJson(Map<String, dynamic> json) => _Waiter(
  id: json['id'] as String,
  shopId: json['shopId'] as String,
  name: json['name'] as String,
  pin: json['pin'] as String,
  isAdmin: json['isAdmin'] as bool? ?? false,
);

Map<String, dynamic> _$WaiterToJson(_Waiter instance) => <String, dynamic>{
  'id': instance.id,
  'shopId': instance.shopId,
  'name': instance.name,
  'pin': instance.pin,
  'isAdmin': instance.isAdmin,
};
