// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShopConfig _$ShopConfigFromJson(Map<String, dynamic> json) => _ShopConfig(
  id: json['id'] as String,
  shopId: json['shopId'] as String,
  isSplitPrintingEnabled: json['isSplitPrintingEnabled'] as bool? ?? false,
  receiptHeader: json['receiptHeader'] as String? ?? '',
  receiptFooter: json['receiptFooter'] as String? ?? '',
  logoPath: json['logoPath'] as String?,
  stationName: json['stationName'] as String?,
);

Map<String, dynamic> _$ShopConfigToJson(_ShopConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shopId': instance.shopId,
      'isSplitPrintingEnabled': instance.isSplitPrintingEnabled,
      'receiptHeader': instance.receiptHeader,
      'receiptFooter': instance.receiptFooter,
      'logoPath': instance.logoPath,
      'stationName': instance.stationName,
    };
