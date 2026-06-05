import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:order/features/orders/domain/entities/order_item.dart';

part 'order.freezed.dart';
part 'order.g.dart';

enum OrderStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

@freezed
abstract class Order with _$Order {
  const Order._();

  const factory Order({
    required String id,
    required String shopId,
    required String tableId,
    required String waiterId,
    @Default(OrderStatus.pending) OrderStatus status,
    @Default([]) List<OrderItem> items,
    @Default(0.0) double total,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  double get calculatedTotal =>
      items.fold(0.0, (sum, item) => sum + (item.priceAtOrder * item.quantity));
}
