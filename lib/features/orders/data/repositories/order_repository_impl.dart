import 'dart:async';
import 'package:pocketbase/pocketbase.dart';
import 'package:order/core/constants/api_constants.dart';
import 'package:order/features/orders/data/datasources/order_remote_datasource.dart';
import 'package:order/features/orders/domain/entities/order.dart';
import 'package:order/features/orders/domain/entities/order_item.dart';
import 'package:order/features/orders/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl({
    required this.remoteDataSource,
    required this.pb,
  });

  final OrderRemoteDataSource remoteDataSource;
  final PocketBase pb;

  @override
  Future<Order> createOrder({
    required String shopId,
    required String tableId,
    required String waiterId,
  }) {
    return remoteDataSource.createOrder(
      shopId: shopId,
      tableId: tableId,
      waiterId: waiterId,
    );
  }

  @override
  Future<Order> getOrder(String orderId) {
    return remoteDataSource.getOrder(orderId);
  }

  @override
  Future<List<Order>> getOrdersByTable({
    required String shopId,
    required String tableId,
  }) {
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
    return remoteDataSource.getOrderHistoryByTable(
      shopId: shopId,
      tableId: tableId,
      limit: limit,
    );
  }

  @override
  Stream<List<Order>> watchActiveOrders(String shopId) {
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
    return remoteDataSource.addItem(shopId: shopId, item: item);
  }

  @override
  Future<void> removeItem(String orderItemId) {
    return remoteDataSource.removeItem(orderItemId);
  }

  @override
  Future<void> updateItemPrintStatus({
    required String itemId,
    required String printStatus,
  }) {
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
    return remoteDataSource.updateItemReceiptOnly(
      itemId: itemId,
      receiptOnly: receiptOnly,
    );
  }
}
