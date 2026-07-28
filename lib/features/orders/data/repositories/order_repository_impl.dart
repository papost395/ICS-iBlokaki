import 'dart:async';
import 'package:pocketbase/pocketbase.dart';
import 'package:order/core/constants/api_constants.dart';
import 'package:order/features/orders/data/datasources/order_remote_datasource.dart';
import 'package:order/features/orders/domain/entities/order.dart';
import 'package:order/features/orders/domain/entities/order_item.dart';
import 'package:order/features/orders/domain/repositories/order_repository.dart';
import 'package:order/core/database/database_helper.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl({
    required this.remoteDataSource,
    required this.pb,
    this.isLocalMode = false,
  });

  final OrderRemoteDataSource remoteDataSource;
  final PocketBase pb;
  final bool isLocalMode;

  @override
  Future<Order> createOrder({
    required String shopId,
    required String tableId,
    required String waiterId,
  }) async {
    if (isLocalMode) {
      final id = 'local_order_${DateTime.now().millisecondsSinceEpoch}';
      final order = Order(
        id: id,
        shopId: shopId,
        tableId: tableId,
        waiterId: waiterId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await DatabaseHelper.instance.addOrder(order);
      return order;
    }
    return remoteDataSource.createOrder(
      shopId: shopId,
      tableId: tableId,
      waiterId: waiterId,
    );
  }

  @override
  Future<Order> getOrder(String orderId) async {
    if (isLocalMode) {
      final order = await DatabaseHelper.instance.getOrder(orderId);
      if (order == null) throw Exception('Order not found');
      return order;
    }
    return remoteDataSource.getOrder(orderId);
  }

  @override
  Future<List<Order>> getOrdersByTable({
    required String shopId,
    required String tableId,
  }) {
    if (isLocalMode) {
      return DatabaseHelper.instance.getOrdersByTable(shopId, tableId);
    }
    return remoteDataSource.getOrdersByTable(
      shopId: shopId,
      tableId: tableId,
    );
  }

  @override
  Future<List<Order>> getOrderHistoryByTable({
    required String shopId,
    required String tableId,
    int limit = 10,
  }) {
    if (isLocalMode) {
      return DatabaseHelper.instance.getOrderHistoryByTable(shopId, tableId, limit);
    }
    return remoteDataSource.getOrderHistoryByTable(
      shopId: shopId,
      tableId: tableId,
      limit: limit,
    );
  }

  @override
  Stream<List<Order>> watchActiveOrders(String shopId) {
    if (isLocalMode) {
      return Stream.fromFuture(DatabaseHelper.instance.getActiveOrders(shopId));
    }

    final controller = StreamController<List<Order>>.broadcast();

    remoteDataSource.getActiveOrders(shopId).then(controller.add);

    Future<void> refreshOrders() async {
      final orders = await remoteDataSource.getActiveOrders(shopId);
      controller.add(orders);
    }

    pb.collection(ApiConstants.ordersCollection).subscribe('*', (e) => refreshOrders());
    pb.collection(ApiConstants.orderItemsCollection).subscribe('*', (e) => refreshOrders());

    controller.onCancel = () {
      pb.collection(ApiConstants.ordersCollection).unsubscribe('*');
      pb.collection(ApiConstants.orderItemsCollection).unsubscribe('*');
    };

    return controller.stream;
  }

  @override
  Future<void> addItem({
    required String orderId,
    required String shopId,
    required OrderItem item,
  }) {
    if (isLocalMode) {
      final itemId = item.id.isEmpty 
          ? 'local_item_${DateTime.now().microsecondsSinceEpoch}_${item.productId}' 
          : item.id;
      return DatabaseHelper.instance.addOrderItem(item.copyWith(id: itemId, orderId: orderId));
    }
    return remoteDataSource.addItem(shopId: shopId, item: item);
  }

  @override
  Future<void> removeItem(String orderItemId) {
    if (isLocalMode) {
      return DatabaseHelper.instance.removeOrderItem(orderItemId);
    }
    return remoteDataSource.removeItem(orderItemId);
  }

  @override
  Future<void> updateItemPrintStatus({
    required String itemId,
    required String printStatus,
  }) {
    if (isLocalMode) {
      return DatabaseHelper.instance.updateItemPrintStatus(itemId, printStatus);
    }
    return remoteDataSource.updateItemPrintStatus(
      itemId: itemId,
      printStatus: printStatus,
    );
  }

  @override
  Future<void> updateItemNotes({
    required String itemId,
    required String notes,
  }) {
    if (isLocalMode) {
      return DatabaseHelper.instance.updateItemNotes(itemId, notes);
    }
    return remoteDataSource.updateItemNotes(
      itemId: itemId,
      notes: notes,
    );
  }

  @override
  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
  }) {
    if (isLocalMode) {
      return DatabaseHelper.instance.updateOrderStatus(orderId, status);
    }
    return remoteDataSource.updateOrderStatus(
      orderId: orderId,
      status: status,
    );
  }

  @override
  Future<void> updateItemReceiptOnly({
    required String itemId,
    required bool receiptOnly,
  }) {
    if (isLocalMode) {
      return DatabaseHelper.instance.updateItemReceiptOnly(itemId, receiptOnly);
    }
    return remoteDataSource.updateItemReceiptOnly(
      itemId: itemId,
      receiptOnly: receiptOnly,
    );
  }
}
