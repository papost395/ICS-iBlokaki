import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:order/core/providers/shared_prefs_provider.dart';

part 'ecr_config_provider.g.dart';

class EcrConfig {
  final bool enabled;
  final String type; // e.g. "MAT"
  final String ipAddress;
  final int port;

  const EcrConfig({
    this.enabled = false,
    this.type = 'MAT',
    this.ipAddress = '',
    this.port = 9100,
  });
}

@Riverpod(keepAlive: true)
class EcrConfigNotifier extends _$EcrConfigNotifier {
  static const _enabledKey = 'ecr_enabled';
  static const _typeKey = 'ecr_type';
  static const _ipAddressKey = 'ecr_ip_address';
  static const _portKey = 'ecr_port';

  @override
  EcrConfig build() {
    final prefs = ref.watch(sharedPrefsProvider);
    return EcrConfig(
      enabled: prefs.getBool(_enabledKey) ?? false,
      type: prefs.getString(_typeKey) ?? 'MAT',
      ipAddress: prefs.getString(_ipAddressKey) ?? '',
      port: prefs.getInt(_portKey) ?? 9100,
    );
  }

  Future<void> setConfig({
    required bool enabled,
    required String type,
    required String ipAddress,
    required int port,
  }) async {
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setBool(_enabledKey, enabled);
    await prefs.setString(_typeKey, type);
    await prefs.setString(_ipAddressKey, ipAddress);
    await prefs.setInt(_portKey, port);
    
    state = EcrConfig(
      enabled: enabled,
      type: type,
      ipAddress: ipAddress,
      port: port,
    );
  }
}
