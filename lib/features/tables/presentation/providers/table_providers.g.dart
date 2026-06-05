// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tableRepositoryHash() => r'4505fa5863dcb1cf04686c1e4a425e5a2ac5822e';

/// See also [tableRepository].
@ProviderFor(tableRepository)
final tableRepositoryProvider = Provider<TableRepository>.internal(
  tableRepository,
  name: r'tableRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tableRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TableRepositoryRef = ProviderRef<TableRepository>;
String _$tablesStreamHash() => r'ce51f9ca8bd923e7e3931d5152f2913a639249ac';

/// See also [tablesStream].
@ProviderFor(tablesStream)
final tablesStreamProvider = StreamProvider<List<RestaurantTable>>.internal(
  tablesStream,
  name: r'tablesStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tablesStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TablesStreamRef = StreamProviderRef<List<RestaurantTable>>;
String _$tableActionsHash() => r'aa77a824606571037b840a511231f0c698d3250f';

/// See also [TableActions].
@ProviderFor(TableActions)
final tableActionsProvider =
    AutoDisposeAsyncNotifierProvider<TableActions, void>.internal(
      TableActions.new,
      name: r'tableActionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$tableActionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TableActions = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
