import 'package:order/features/orders/domain/entities/order.dart';
import 'package:order/features/orders/domain/entities/order_item.dart';

abstract class OrderRepository {
  Future<Order> createOrder({
    required String shopId,
    required String tableId,
    required String waiterId,
  });
  Future<Order> getOrder(String orderId);
  Future<List<Order>> getOrdersByTable({
    required String shopId,
    required String tableId,
  });
  Future<List<Order>> getOrderHistoryByTable({
    required String shopId,
    required String tableId,
    int limit = 10,
  });
  Stream<List<Order>> watchActiveOrders(String shopId);
  Future<void> addItem({
    required String orderId,
    required String shopId,
    required OrderItem item,
  });
  Future<void> removeItem(String orderItemId);
  Future<void> updateItemPrintStatus({
    required String itemId,
    required String printStatus,
  });
  Future<void> updateItemNotes({
    required String itemId,
    required String notes,
  });
  Future<void> updateItemReceiptOnly({
    required String itemId,
    required bool receiptOnly,
  });
  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
  });
}
