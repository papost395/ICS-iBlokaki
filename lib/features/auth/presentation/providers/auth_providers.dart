import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:order/core/providers/pocketbase_provider.dart';
import 'package:order/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:order/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:order/features/auth/domain/entities/user.dart';
import 'package:order/features/auth/domain/repositories/auth_repository.dart';
import 'package:order/features/auth/data/datasources/waiter_remote_datasource.dart';
import 'package:order/features/auth/data/repositories/waiter_repository_impl.dart';
import 'package:order/features/auth/domain/repositories/waiter_repository.dart';
import 'package:order/features/auth/domain/entities/waiter.dart';
import 'package:order/core/providers/device_config_provider.dart';

part 'auth_providers.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final pb = ref.watch(pocketBaseProvider);
  return AuthRepositoryImpl(
    remoteDataSource: AuthRemoteDataSourceImpl(pb: pb),
  );
}

@Riverpod(keepAlive: true)
class AuthState extends _$AuthState {
  @override
  FutureOr<User?> build() {
    final repo = ref.watch(authRepositoryProvider);
    return repo.currentUser;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      return repo.login(email: email, password: password);
    });
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = const AsyncData(null);
  }
}

@riverpod
User? currentUser(Ref ref) {
  return ref.watch(authStateProvider).valueOrNull;
}

@riverpod
String? currentShopId(Ref ref) {
  return ref.watch(deviceConfigNotifierProvider).shopId;
}

enum LocalRole { waiter, none }

class LocalAuthState {
  final LocalRole role;
  final String? waiterId;
  final String? waiterName;
  const LocalAuthState({required this.role, this.waiterId, this.waiterName});
}

@Riverpod(keepAlive: true)
class LocalAuthNotifier extends _$LocalAuthNotifier {
  @override
  LocalAuthState build() {
    return const LocalAuthState(role: LocalRole.none);
  }

  void loginAsWaiter(String waiterId, String waiterName) {
    state = LocalAuthState(role: LocalRole.waiter, waiterId: waiterId, waiterName: waiterName);
  }

  void logout() {
    state = const LocalAuthState(role: LocalRole.none);
  }
}

@Riverpod(keepAlive: true)
WaiterRepository waiterRepository(Ref ref) {
  final pb = ref.watch(pocketBaseProvider);
  return WaiterRepositoryImpl(
    remoteDataSource: WaiterRemoteDataSourceImpl(pb: pb),
  );
}

@riverpod
Future<List<Waiter>> waitersFuture(Ref ref) async {
  final shopId = ref.watch(currentShopIdProvider);
  if (shopId == null) return [];
  final repo = ref.watch(waiterRepositoryProvider);
  return repo.getWaiters(shopId);
}
