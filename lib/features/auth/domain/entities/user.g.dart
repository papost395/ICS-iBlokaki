// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  shopId: json['shopId'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'shopId': instance.shopId,
  'name': instance.name,
  'email': instance.email,
  'role': _$UserRoleEnumMap[instance.role]!,
};

const _$UserRoleEnumMap = {
  UserRole.admin: 'admin',
  UserRole.manager: 'manager',
  UserRole.waiter: 'waiter',
};
