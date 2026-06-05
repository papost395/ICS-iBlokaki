import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalSettingsDataSource {
  ThemeMode getThemeMode();
  Future<void> setThemeMode(ThemeMode mode);
  Locale getLocale();
  Future<void> setLocale(Locale locale);
  Future<Map<String, String>> getCloudKeys();
  Future<void> setCloudKeys(String appId, String appKey);
}

class LocalSettingsDataSourceImpl implements LocalSettingsDataSource {
  LocalSettingsDataSourceImpl({required this.prefs});

  final SharedPreferences prefs;

  static const _themeModeKey = 'theme_mode';
  static const _localeKey = 'locale';

  @override
  ThemeMode getThemeMode() {
    final value = prefs.getString(_themeModeKey);
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) {
    return prefs.setString(_themeModeKey, mode.name);
  }

  @override
  Locale getLocale() {
    final value = prefs.getString(_localeKey);
    return switch (value) {
      'en' => const Locale('en'),
      'el' => const Locale('el'),
      _ => const Locale('el'),
    };
  }

  @override
  Future<void> setLocale(Locale locale) {
    return prefs.setString(_localeKey, locale.languageCode);
  }

  @override
  Future<Map<String, String>> getCloudKeys() async {
    return {
      'appId': prefs.getString('sunmi_app_id') ?? '',
      'appKey': prefs.getString('sunmi_app_key') ?? '',
    };
  }

  @override
  Future<void> setCloudKeys(String appId, String appKey) async {
    await prefs.setString('sunmi_app_id', appId);
    await prefs.setString('sunmi_app_key', appKey);
  }
}
