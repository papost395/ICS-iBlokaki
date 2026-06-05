import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:order/core/providers/shared_prefs_provider.dart';

part 'device_config_provider.g.dart';

class DeviceConfig {
  final String? apiUrl;
  final String? shopId;

  const DeviceConfig({this.apiUrl, this.shopId});

  bool get isConfigured => apiUrl != null && apiUrl!.isNotEmpty && shopId != null && shopId!.isNotEmpty;
}

@Riverpod(keepAlive: true)
class DeviceConfigNotifier extends _$DeviceConfigNotifier {
  static const _apiUrlKey = 'device_api_url';
  static const _shopIdKey = 'device_shop_id';

  @override
  DeviceConfig build() {
    final prefs = ref.watch(sharedPrefsProvider);
    return DeviceConfig(
      apiUrl: prefs.getString(_apiUrlKey),
      shopId: prefs.getString(_shopIdKey),
    );
  }

  Future<void> setConfig({required String apiUrl, required String shopId}) async {
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setString(_apiUrlKey, apiUrl);
    await prefs.setString(_shopIdKey, shopId);
    state = DeviceConfig(apiUrl: apiUrl, shopId: shopId);
  }

  Future<void> clearConfig() async {
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.remove(_apiUrlKey);
    await prefs.remove(_shopIdKey);
    state = const DeviceConfig();
  }
}
