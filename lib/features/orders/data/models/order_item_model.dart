import 'package:pocketbase/pocketbase.dart';
import 'package:order/features/orders/domain/entities/order_item.dart';
import 'package:order/features/products/domain/entities/department.dart';

class OrderItemModel {
  static OrderItem fromRecord(RecordModel record) {
    return OrderItem(
      id: record.id,
      orderId: record.getStringValue('order_id'),
      productId: record.getStringValue('product_id'),
      productName: (record.expand['product_id'] != null && record.expand['product_id']!.isNotEmpty)
          ? record.expand['product_id']!.first.getStringValue('name')
          : record.getStringValue('product_name'),
      quantity: record.getIntValue('quantity'),
      priceAtOrder: record.getDoubleValue('unit_price'),
      department: Department.fromString(
        (record.expand['product_id'] != null && record.expand['product_id']!.isNotEmpty)
            ? record.expand['product_id']!.first.getStringValue('department')
            : record.getStringValue('department'),
      ),
      notes: record.getStringValue('notes'),
      printStatus: record.getStringValue('print_status'),
      receiptOnly: record.getBoolValue('receipt_only'),
    );
  }

  static Map<String, dynamic> toBody(OrderItem item) {
    return {
      'order_id': item.orderId,
      'product_id': item.productId,
      'product_name': item.productName,
      'quantity': item.quantity,
      'price_at_order': item.priceAtOrder,
      'department': item.department.name,
      'notes': item.notes,
      'print_status': item.printStatus,
      'receipt_only': item.receiptOnly,
    };
  }
}
