import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:order/core/constants/api_constants.dart';

import 'package:order/core/providers/device_config_provider.dart';

import 'package:order/core/providers/shared_prefs_provider.dart';

part 'pocketbase_provider.g.dart';

@Riverpod(keepAlive: true)
PocketBase pocketBase(Ref ref) {
  final config = ref.watch(deviceConfigNotifierProvider);
  final url = config.apiUrl ?? ApiConstants.baseUrl;
  
  final prefs = ref.watch(sharedPrefsProvider);
  final store = AsyncAuthStore(
    save: (String data) async => prefs.setString('pb_auth', data),
    initial: prefs.getString('pb_auth'),
  );
  
  return PocketBase(url, authStore: store);
}
