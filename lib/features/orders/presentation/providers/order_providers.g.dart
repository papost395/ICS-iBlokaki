// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$orderRepositoryHash() => r'cc7186d0ea82b6f084f879b1f0098e9f4ed7b596';

/// See also [orderRepository].
@ProviderFor(orderRepository)
final orderRepositoryProvider = Provider<OrderRepository>.internal(
  orderRepository,
  name: r'orderRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$orderRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OrderRepositoryRef = ProviderRef<OrderRepository>;
String _$activeOrdersStreamHash() =>
    r'f5a5c7525d71c6d25cb6b3c93aaa5ad338c7b093';

/// See also [activeOrdersStream].
@ProviderFor(activeOrdersStream)
final activeOrdersStreamProvider =
    AutoDisposeStreamProvider<List<Order>>.internal(
      activeOrdersStream,
      name: r'activeOrdersStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeOrdersStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveOrdersStreamRef = AutoDisposeStreamProviderRef<List<Order>>;
String _$orderHistoryHash() => r'cd9d3bd547cbb4a5578677b108cd866505977ed6';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [orderHistory].
@ProviderFor(orderHistory)
const orderHistoryProvider = OrderHistoryFamily();

/// See also [orderHistory].
class OrderHistoryFamily extends Family<AsyncValue<List<Order>>> {
  /// See also [orderHistory].
  const OrderHistoryFamily();

  /// See also [orderHistory].
  OrderHistoryProvider call({required String tableId}) {
    return OrderHistoryProvider(tableId: tableId);
  }

  @override
  OrderHistoryProvider getProviderOverride(
    covariant OrderHistoryProvider provider,
  ) {
    return call(tableId: provider.tableId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'orderHistoryProvider';
}

/// See also [orderHistory].
class OrderHistoryProvider extends AutoDisposeFutureProvider<List<Order>> {
  /// See also [orderHistory].
  OrderHistoryProvider({required String tableId})
    : this._internal(
        (ref) => orderHistory(ref as OrderHistoryRef, tableId: tableId),
        from: orderHistoryProvider,
        name: r'orderHistoryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$orderHistoryHash,
        dependencies: OrderHistoryFamily._dependencies,
        allTransitiveDependencies:
            OrderHistoryFamily._allTransitiveDependencies,
        tableId: tableId,
      );

  OrderHistoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tableId,
  }) : super.internal();

  final String tableId;

  @override
  Override overrideWith(
    FutureOr<List<Order>> Function(OrderHistoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OrderHistoryProvider._internal(
        (ref) => create(ref as OrderHistoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tableId: tableId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Order>> createElement() {
    return _OrderHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderHistoryProvider && other.tableId == tableId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tableId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OrderHistoryRef on AutoDisposeFutureProviderRef<List<Order>> {
  /// The parameter `tableId` of this provider.
  String get tableId;
}

class _OrderHistoryProviderElement
    extends AutoDisposeFutureProviderElement<List<Order>>
    with OrderHistoryRef {
  _OrderHistoryProviderElement(super.provider);

  @override
  String get tableId => (origin as OrderHistoryProvider).tableId;
}

String _$orderActionsHash() => r'dc7194924025d670e5a04711c71af907d74a8b24';

/// See also [OrderActions].
@ProviderFor(OrderActions)
final orderActionsProvider =
    AutoDisposeAsyncNotifierProvider<OrderActions, void>.internal(
      OrderActions.new,
      name: r'orderActionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$orderActionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OrderActions = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
