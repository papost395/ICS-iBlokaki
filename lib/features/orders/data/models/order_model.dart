import 'package:pocketbase/pocketbase.dart';
import 'package:order/features/orders/domain/entities/order.dart';

class OrderModel {
  static Order fromRecord(RecordModel record) {
    return Order(
      id: record.id,
      shopId: record.getStringValue('shop_id'),
      tableId: record.getStringValue('table_id'),
      waiterId: record.getStringValue('waiter_id'),
      status: OrderStatus.values.firstWhere(
        (s) => s.name == record.getStringValue('status'),
        orElse: () => OrderStatus.pending,
      ),
      total: record.getDoubleValue('total'),
      createdAt: DateTime.tryParse(record.getStringValue('created')),
      updatedAt: DateTime.tryParse(record.getStringValue('updated')),
    );
  }
}
