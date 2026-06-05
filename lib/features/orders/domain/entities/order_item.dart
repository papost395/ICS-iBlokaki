import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:order/features/products/domain/entities/department.dart';

part 'order_item.freezed.dart';
part 'order_item.g.dart';

@freezed
abstract class OrderItem with _$OrderItem {
  const factory OrderItem({
    required String id,
    required String orderId,
    required String productId,
    required String productName,
    required int quantity,
    required double priceAtOrder,
    @Default(Department.none) Department department,
    @Default('') String notes,
    @Default('pending') String printStatus,
    @Default(false) bool receiptOnly,
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
}
