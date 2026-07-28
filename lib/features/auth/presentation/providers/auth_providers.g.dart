// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authRepositoryHash() => r'14f82696f92a7de63f98865011c9a7fc5d892dc7';

/// See also [authRepository].
@ProviderFor(authRepository)
final authRepositoryProvider = Provider<AuthRepository>.internal(
  authRepository,
  name: r'authRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthRepositoryRef = ProviderRef<AuthRepository>;
String _$currentUserHash() => r'3f0b1fb560d0622f40ba1a4b216afeee9a2dabfd';

/// See also [currentUser].
@ProviderFor(currentUser)
final currentUserProvider = AutoDisposeProvider<User?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserRef = AutoDisposeProviderRef<User?>;
String _$currentShopIdHash() => r'da80582136b8f2cb8319202a9521741b2b59fd41';

/// See also [currentShopId].
@ProviderFor(currentShopId)
final currentShopIdProvider = AutoDisposeProvider<String?>.internal(
  currentShopId,
  name: r'currentShopIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentShopIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentShopIdRef = AutoDisposeProviderRef<String?>;
String _$waiterRepositoryHash() => r'1d575f86dd632797d762ffa5344764f5cfffcfe8';

/// See also [waiterRepository].
@ProviderFor(waiterRepository)
final waiterRepositoryProvider = Provider<WaiterRepository>.internal(
  waiterRepository,
  name: r'waiterRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$waiterRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WaiterRepositoryRef = ProviderRef<WaiterRepository>;
String _$waitersFutureHash() => r'8df3c69a1caa77e79a6c02097ff247efcfd3701e';

/// See also [waitersFuture].
@ProviderFor(waitersFuture)
final waitersFutureProvider = AutoDisposeFutureProvider<List<Waiter>>.internal(
  waitersFuture,
  name: r'waitersFutureProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$waitersFutureHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WaitersFutureRef = AutoDisposeFutureProviderRef<List<Waiter>>;
String _$authStateHash() => r'609fe13f6b367bc49836857d7353d7018512721d';

/// See also [AuthState].
@ProviderFor(AuthState)
final authStateProvider = AsyncNotifierProvider<AuthState, User?>.internal(
  AuthState.new,
  name: r'authStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthState = AsyncNotifier<User?>;
String _$localAuthNotifierHash() => r'0f2877beb4f1ecc6af138d0e327584123b67205a';

/// See also [LocalAuthNotifier].
@ProviderFor(LocalAuthNotifier)
final localAuthNotifierProvider =
    NotifierProvider<LocalAuthNotifier, LocalAuthState>.internal(
      LocalAuthNotifier.new,
      name: r'localAuthNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$localAuthNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LocalAuthNotifier = Notifier<LocalAuthState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
