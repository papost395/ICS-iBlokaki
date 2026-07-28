import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:order/core/providers/pocketbase_provider.dart';
import 'package:order/features/auth/presentation/providers/auth_providers.dart';
import 'package:order/features/orders/data/datasources/order_remote_datasource.dart';
import 'package:order/features/orders/data/repositories/order_repository_impl.dart';
import 'package:order/features/orders/domain/entities/order.dart';
import 'package:order/features/orders/domain/entities/order_item.dart';
import 'package:order/features/orders/domain/repositories/order_repository.dart';
import 'package:order/features/tables/domain/entities/table_status.dart';
import 'package:order/features/tables/presentation/providers/table_providers.dart';

import 'package:order/core/providers/storage_mode_provider.dart';
import 'package:order/core/database/database_helper.dart';

part 'order_providers.g.dart';

@Riverpod(keepAlive: true)
OrderRepository orderRepository(Ref ref) {
  final pb = ref.watch(pocketBaseProvider);
  final isLocalMode = ref.watch(storageModeNotifierProvider);
  return OrderRepositoryImpl(
    remoteDataSource: OrderRemoteDataSourceImpl(pb: pb),
    pb: pb,
    isLocalMode: isLocalMode,
  );
}

@riverpod
Stream<List<Order>> activeOrdersStream(Ref ref) {
  final shopId = ref.watch(currentShopIdProvider);
  if (shopId == null) return const Stream.empty();
  final repo = ref.watch(orderRepositoryProvider);
  return repo.watchActiveOrders(shopId);
}

@riverpod
Future<List<Order>> orderHistory(Ref ref, {required String tableId}) {
  final shopId = ref.watch(currentShopIdProvider);
  if (shopId == null) return Future.value([]);
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getOrderHistoryByTable(shopId: shopId, tableId: tableId);
}

@riverpod
class OrderActions extends _$OrderActions {
  @override
  FutureOr<void> build() {}

  Future<Order> createOrder({
    required String tableId,
  }) async {
    final shopId = ref.read(currentShopIdProvider);
    final localAuth = ref.read(localAuthNotifierProvider);
    
    final waiterId = localAuth.waiterId;

    if (shopId == null || waiterId == null) {
      throw Exception('Not authenticated locally or globally');
    }

    final repo = ref.read(orderRepositoryProvider);
    final order = await repo.createOrder(
      shopId: shopId,
      tableId: tableId,
      waiterId: waiterId,
    );
    
    // Also mark table as occupied
    try {
      await ref.read(tableActionsProvider.notifier).updateStatus(tableId: tableId, status: const Occupied());
    } catch (e) {
      // Ignore if it fails to update table status here, not critical for order creation
    }
    
    ref.invalidate(activeOrdersStreamProvider);
    return order;
  }

  Future<void> addItem({
    required String orderId,
    required OrderItem item,
  }) async {
    final shopId = ref.read(currentShopIdProvider);
    if (shopId == null) throw Exception('Not authenticated');

    final repo = ref.read(orderRepositoryProvider);
    await repo.addItem(orderId: orderId, shopId: shopId, item: item);
    ref.invalidate(activeOrdersStreamProvider);
  }

  Future<void> updateStatus({
    required String orderId,
    required OrderStatus status,
  }) async {
    final repo = ref.read(orderRepositoryProvider);
    await repo.updateOrderStatus(orderId: orderId, status: status);
    ref.invalidate(activeOrdersStreamProvider);
  }

  Future<void> updateItemPrintStatus({
    required String itemId,
    required String printStatus,
  }) async {
    final repo = ref.read(orderRepositoryProvider);
    await repo.updateItemPrintStatus(itemId: itemId, printStatus: printStatus);
    ref.invalidate(activeOrdersStreamProvider);
  }

  Future<void> updateItemNotes({
    required String itemId,
    required String notes,
  }) async {
    final repo = ref.read(orderRepositoryProvider);
    await repo.updateItemNotes(itemId: itemId, notes: notes);
    ref.invalidate(activeOrdersStreamProvider);
  }

  Future<void> updateItemReceiptOnly({
    required String itemId,
    required bool receiptOnly,
  }) async {
    final repo = ref.read(orderRepositoryProvider);
    await repo.updateItemReceiptOnly(itemId: itemId, receiptOnly: receiptOnly);
    ref.invalidate(activeOrdersStreamProvider);
  }

  Future<void> cancelActiveOrdersForTable({
    required String tableId,
  }) async {
    final shopId = ref.read(currentShopIdProvider);
    if (shopId == null) return;
    
    final repo = ref.read(orderRepositoryProvider);
    final orders = await repo.getOrdersByTable(shopId: shopId, tableId: tableId);
    
    for (final order in orders) {
      if (order.status != OrderStatus.completed && order.status != OrderStatus.cancelled) {
        await repo.updateOrderStatus(orderId: order.id, status: OrderStatus.cancelled);
      }
    }
    ref.invalidate(activeOrdersStreamProvider);
  }

  Future<void> completeActiveOrdersForTable({
    required String tableId,
  }) async {
    final shopId = ref.read(currentShopIdProvider);
    if (shopId == null) return;
    
    final repo = ref.read(orderRepositoryProvider);
    final orders = await repo.getOrdersByTable(shopId: shopId, tableId: tableId);
    
    final salesRecords = <Map<String, dynamic>>[];
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    
    for (final order in orders) {
      if (order.status != OrderStatus.completed && order.status != OrderStatus.cancelled) {
        await repo.updateOrderStatus(orderId: order.id, status: OrderStatus.completed);
        
        for (final item in order.items) {
          salesRecords.add({
            'id': 'sale_${item.id}',
            'shopId': shopId,
            'productId': item.productId,
            'productName': item.productName,
            'quantity': item.quantity,
            'price': item.priceAtOrder,
            'timestamp': nowMs,
            'orderType': 'table',
          });
        }
      }
    }
    
    if (salesRecords.isNotEmpty) {
      await DatabaseHelper.instance.addSalesRecords(salesRecords);
    }
    
    ref.invalidate(activeOrdersStreamProvider);
  }
}
