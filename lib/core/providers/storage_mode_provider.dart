import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:order/core/providers/shared_prefs_provider.dart';

part 'storage_mode_provider.g.dart';

@riverpod
class StorageModeNotifier extends _$StorageModeNotifier {
  static const _localModeKey = 'is_local_mode';

  @override
  bool build() {
    final prefs = ref.watch(sharedPrefsProvider);
    return prefs.getBool(_localModeKey) ?? false;
  }

  Future<void> setLocalMode(bool isLocal) async {
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setBool(_localModeKey, isLocal);
    state = isLocal;
  }
}
