import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:order/core/constants/api_constants.dart';
import 'package:order/features/settings/data/datasources/local_settings_datasource.dart';
import 'package:order/features/settings/data/datasources/remote_settings_datasource.dart';
import 'package:order/features/settings/data/models/shop_config_model.dart';
import 'package:order/features/settings/domain/entities/shop_config.dart';
import 'package:order/features/settings/domain/repositories/settings_repository.dart';
import 'package:order/core/database/database_helper.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.pb,
    this.isLocalMode = false,
  });

  final LocalSettingsDataSource localDataSource;
  final RemoteSettingsDataSource remoteDataSource;
  final PocketBase pb;
  final bool isLocalMode;

  @override
  Future<ShopConfig> getShopConfig(String shopId) async {
    if (isLocalMode) {
      final config = await DatabaseHelper.instance.getShopConfig(shopId);
      if (config != null) return config;
      // Fallback
      return ShopConfig(id: 'local_config', shopId: shopId, receiptHeader: 'Τοπικό Κατάστημα', receiptFooter: 'Ευχαριστούμε!');
    }
    return remoteDataSource.getShopConfig(shopId);
  }

  @override
  Stream<ShopConfig> watchShopConfig(String shopId) {
    if (isLocalMode) {
      // Just returning a future as stream for local mode. 
      // Ideally this would be a proper stream if we had a reactive local DB.
      return Stream.fromFuture(getShopConfig(shopId));
    }

    final controller = StreamController<ShopConfig>.broadcast();

    remoteDataSource.getShopConfig(shopId).then(controller.add);

    pb.collection(ApiConstants.shopConfigsCollection).subscribe(
      '*',
      (e) async {
        if (e.record != null) {
          controller.add(ShopConfigModel.fromRecord(e.record!));
        }
      },
    );

    controller.onCancel = () {
      pb.collection(ApiConstants.shopConfigsCollection).unsubscribe('*');
    };

    return controller.stream;
  }

  @override
  Future<void> updateShopConfig(ShopConfig config) async {
    if (isLocalMode) {
      await DatabaseHelper.instance.updateShopConfig(config);
      return;
    }
    return remoteDataSource.updateShopConfig(config);
  }

  @override
  Future<ThemeMode> getThemeMode() async {
    return localDataSource.getThemeMode();
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) {
    return localDataSource.setThemeMode(mode);
  }

  @override
  Future<Locale> getLocale() async {
    return localDataSource.getLocale();
  }

  @override
  Future<void> setLocale(Locale locale) {
    return localDataSource.setLocale(locale);
  }

  @override
  Future<Map<String, String>> getCloudKeys() {
    return localDataSource.getCloudKeys();
  }

  @override
  Future<void> setCloudKeys(String appId, String appKey) {
    return localDataSource.setCloudKeys(appId, appKey);
  }
}
