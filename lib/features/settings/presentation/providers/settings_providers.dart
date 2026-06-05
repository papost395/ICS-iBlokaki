import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:order/core/providers/pocketbase_provider.dart';
import 'package:order/core/providers/shared_prefs_provider.dart';
import 'package:order/features/auth/presentation/providers/auth_providers.dart';
import 'package:order/features/settings/data/datasources/local_settings_datasource.dart';
import 'package:order/features/settings/data/datasources/remote_settings_datasource.dart';
import 'package:order/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:order/features/settings/domain/entities/shop_config.dart';
import 'package:order/features/settings/domain/repositories/settings_repository.dart';

part 'settings_providers.g.dart';

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) {
  final pb = ref.watch(pocketBaseProvider);
  final prefs = ref.watch(sharedPrefsProvider);
  return SettingsRepositoryImpl(
    localDataSource: LocalSettingsDataSourceImpl(prefs: prefs),
    remoteDataSource: RemoteSettingsDataSourceImpl(pb: pb),
    pb: pb,
  );
}

@riverpod
Stream<ShopConfig> shopConfigStream(Ref ref) {
  final shopId = ref.watch(currentShopIdProvider);
  if (shopId == null) return const Stream.empty();
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.watchShopConfig(shopId);
}

@Riverpod(keepAlive: true)
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() {
    final repo = ref.watch(settingsRepositoryProvider);
    repo.getThemeMode().then((mode) => state = mode);
    return ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.setThemeMode(mode);
    state = mode;
  }
}

@Riverpod(keepAlive: true)
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Locale build() {
    final repo = ref.watch(settingsRepositoryProvider);
    repo.getLocale().then((locale) => state = locale);
    return const Locale('el');
  }

  Future<void> setLocale(Locale locale) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.setLocale(locale);
    state = locale;
  }
}
