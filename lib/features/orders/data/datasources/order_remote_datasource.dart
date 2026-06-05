import 'package:pocketbase/pocketbase.dart';
import 'package:order/core/constants/api_constants.dart';
import 'package:order/core/errors/exceptions.dart';
import 'package:order/features/orders/data/models/order_model.dart';
import 'package:order/features/orders/data/models/order_item_model.dart';
import 'package:order/features/orders/domain/entities/order.dart';
import 'package:order/features/orders/domain/entities/order_item.dart';

abstract class OrderRemoteDataSource {
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
  Future<List<Order>> getActiveOrders(String shopId);
  Future<void> addItem({required String shopId, required OrderItem item});
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

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  OrderRemoteDataSourceImpl({required this.pb});

  final PocketBase pb;

  @override
  Future<Order> createOrder({
    required String shopId,
    required String tableId,
    required String waiterId,
  }) async {
    try {
      final record =
          await pb.collection(ApiConstants.ordersCollection).create(body: {
        'shop_id': shopId,
        'table_id': tableId,
        'waiter_id': waiterId,
        'status': OrderStatus.pending.name,
        'total': 0.0,
      });
      return OrderModel.fromRecord(record);
    } catch (e) {
      throw ServerException('Failed to create order: ${e.toString()}');
    }
  }

  @override
  Future<Order> getOrder(String orderId) async {
    try {
      final record = await pb
          .collection(ApiConstants.ordersCollection)
          .getOne(orderId);
          
      final itemsResult = await pb
          .collection(ApiConstants.orderItemsCollection)
          .getFullList(
            filter: 'order_id = "$orderId"',
            expand: 'product_id',
          );
          
      final items = itemsResult.map(OrderItemModel.fromRecord).toList();
      
      final order = OrderModel.fromRecord(record);
      return order.copyWith(items: items);
    } catch (e) {
      throw ServerException('Failed to fetch order: ${e.toString()}');
    }
  }

  @override
  Future<List<Order>> getOrdersByTable({
    required String shopId,
    required String tableId,
  }) async {
    try {
      final result = await pb
          .collection(ApiConstants.ordersCollection)
          .getFullList(
            filter:
                'shop_id = "$shopId" && table_id = "$tableId" && status != "completed" && status != "cancelled"',
            sort: '-created',
          );
          
      if (result.isEmpty) return [];

      final orderIds = result.map((r) => r.id).toList();
      final orderIdsFilter = orderIds.map((id) => 'order_id = "$id"').join(' || ');

      final itemsResult = await pb
          .collection(ApiConstants.orderItemsCollection)
          .getFullList(
            filter: orderIdsFilter,
            expand: 'product_id',
          );

      final items = itemsResult.map(OrderItemModel.fromRecord).toList();

      return result.map((r) {
        final order = OrderModel.fromRecord(r);
        return order.copyWith(items: items.where((i) => i.orderId == order.id).toList());
      }).toList();
    } catch (e) {
      throw ServerException('Failed to fetch orders: ${e.toString()}');
    }
  }

  @override
  Future<List<Order>> getOrderHistoryByTable({
    required String shopId,
    required String tableId,
    int limit = 10,
  }) async {
    try {
      final result = await pb
          .collection(ApiConstants.ordersCollection)
          .getList(
            page: 1,
            perPage: limit,
            filter:
                'shop_id = "$shopId" && table_id = "$tableId" && status != "cancelled"',
            sort: '-created',
          );
          
      if (result.items.isEmpty) return [];

      final orderIds = result.items.map((r) => r.id).toList();
      final orderIdsFilter = orderIds.map((id) => 'order_id = "$id"').join(' || ');

      final itemsResult = await pb
          .collection(ApiConstants.orderItemsCollection)
          .getFullList(
            filter: orderIdsFilter,
            expand: 'product_id',
          );

      final items = itemsResult.map(OrderItemModel.fromRecord).toList();

      return result.items.map((r) {
        final order = OrderModel.fromRecord(r);
        return order.copyWith(items: items.where((i) => i.orderId == order.id).toList());
      }).toList();
    } catch (e) {
      throw ServerException('Failed to fetch order history: ${e.toString()}');
    }
  }

  @override
  Future<List<Order>> getActiveOrders(String shopId) async {
    try {
      final result = await pb
          .collection(ApiConstants.ordersCollection)
          .getFullList(
            filter:
                'shop_id = "$shopId" && status != "completed" && status != "cancelled"',
            sort: '-created',
          );
          
      if (result.isEmpty) return [];

      final orderIds = result.map((r) => r.id).toList();
      final orderIdsFilter = orderIds.map((id) => 'order_id = "$id"').join(' || ');

      final itemsResult = await pb
          .collection(ApiConstants.orderItemsCollection)
          .getFullList(
            filter: orderIdsFilter,
            expand: 'product_id',
          );

      final items = itemsResult.map(OrderItemModel.fromRecord).toList();

      return result.map((r) {
        final order = OrderModel.fromRecord(r);
        return order.copyWith(items: items.where((i) => i.orderId == order.id).toList());
      }).toList();
    } catch (e) {
      throw ServerException('Failed to fetch active orders: ${e.toString()}');
    }
  }

  @override
  Future<void> addItem({required String shopId, required OrderItem item}) async {
    try {
      final body = {
        'shop_id': shopId,
        'order_id': item.orderId,
        'product_id': item.productId,
        'quantity': item.quantity,
        'unit_price': item.priceAtOrder,
        'notes': item.notes,
        'print_status': item.printStatus,
      };

      await pb
          .collection(ApiConstants.orderItemsCollection)
          .create(body: body);
    } on ClientException catch (e) {
      if (e.statusCode == 404) {
        return;
      }
      throw ServerException('Failed to add item: ${e.response}');
    } catch (e) {
      throw ServerException('Failed to add item: ${e.toString()}');
    }
  }

  @override
  Future<void> removeItem(String orderItemId) async {
    try {
      await pb
          .collection(ApiConstants.orderItemsCollection)
          .delete(orderItemId);
    } catch (e) {
      throw ServerException('Failed to remove item: ${e.toString()}');
    }
  }

  @override
  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
  }) async {
    try {
      await pb.collection(ApiConstants.ordersCollection).update(
        orderId,
        body: {'status': status.name},
      );
    } catch (e) {
      throw ServerException('Failed to update order status: ${e.toString()}');
    }
  }

  @override
  Future<void> updateItemPrintStatus({
    required String itemId,
    required String printStatus,
  }) async {
    try {
      await pb.collection(ApiConstants.orderItemsCollection).update(
        itemId,
        body: {'print_status': printStatus},
      );
    } catch (e) {
      throw ServerException('Failed to update print status: ${e.toString()}');
    }
  }

  @override
  Future<void> updateItemNotes({
    required String itemId,
    required String notes,
  }) async {
    try {
      await pb.collection(ApiConstants.orderItemsCollection).update(
        itemId,
        body: {'notes': notes},
      );
    } catch (e) {
      throw ServerException('Failed to update item notes: ${e.toString()}');
    }
  }

  @override
  Future<void> updateItemReceiptOnly({
    required String itemId,
    required bool receiptOnly,
  }) async {
    try {
      await pb.collection(ApiConstants.orderItemsCollection).update(
        itemId,
        body: {'receipt_only': receiptOnly},
      );
    } catch (e) {
      throw ServerException('Failed to update receipt_only: ${e.toString()}');
    }
  }
}
