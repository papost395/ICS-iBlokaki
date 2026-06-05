import 'package:flutter/material.dart';
import 'package:order/features/settings/domain/entities/shop_config.dart';

abstract class SettingsRepository {
  Future<ShopConfig> getShopConfig(String shopId);
  Stream<ShopConfig> watchShopConfig(String shopId);
  Future<void> updateShopConfig(ShopConfig config);

  Future<ThemeMode> getThemeMode();
  Future<void> setThemeMode(ThemeMode mode);
  Future<Locale> getLocale();
  Future<void> setLocale(Locale locale);

  Future<Map<String, String>> getCloudKeys();
  Future<void> setCloudKeys(String appId, String appKey);
}
