// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'printer_device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PrinterDevice _$PrinterDeviceFromJson(Map<String, dynamic> json) =>
    _PrinterDevice(
      id: json['id'] as String,
      shopId: json['shopId'] as String,
      name: json['name'] as String,
      connectionType: $enumDecode(
        _$ConnectionTypeEnumMap,
        json['connectionType'],
      ),
      address: json['address'] as String,
      role: $enumDecode(_$PrinterRoleEnumMap, json['role']),
      isUtf8: json['isUtf8'] as bool? ?? false,
      isCp737: json['isCp737'] as bool? ?? false,
      paperSize: (json['paperSize'] as num?)?.toInt() ?? 80,
      isDoubleSize: json['isDoubleSize'] as bool? ?? false,
      isExtraBold: json['isExtraBold'] as bool? ?? false,
    );

Map<String, dynamic> _$PrinterDeviceToJson(_PrinterDevice instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shopId': instance.shopId,
      'name': instance.name,
      'connectionType': _$ConnectionTypeEnumMap[instance.connectionType]!,
      'address': instance.address,
      'role': _$PrinterRoleEnumMap[instance.role]!,
      'isUtf8': instance.isUtf8,
      'isCp737': instance.isCp737,
      'paperSize': instance.paperSize,
      'isDoubleSize': instance.isDoubleSize,
      'isExtraBold': instance.isExtraBold,
    };

const _$ConnectionTypeEnumMap = {
  ConnectionType.network: 'network',
  ConnectionType.bluetooth: 'bluetooth',
  ConnectionType.cloud: 'cloud',
};

const _$PrinterRoleEnumMap = {
  PrinterRole.cashier: 'cashier',
  PrinterRole.kitchen: 'kitchen',
  PrinterRole.bar: 'bar',
};
