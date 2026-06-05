// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$shopRepositoryHash() => r'0248b8912f5b3c1e56dc639fe91fc7272564331a';

/// See also [shopRepository].
@ProviderFor(shopRepository)
final shopRepositoryProvider = Provider<ShopRepository>.internal(
  shopRepository,
  name: r'shopRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$shopRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShopRepositoryRef = ProviderRef<ShopRepository>;
String _$currentShopHash() => r'b4678a9816de68355e7029431eff1f61aa446b4c';

/// See also [currentShop].
@ProviderFor(currentShop)
final currentShopProvider = AutoDisposeStreamProvider<Shop>.internal(
  currentShop,
  name: r'currentShopProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentShopHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentShopRef = AutoDisposeStreamProviderRef<Shop>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
