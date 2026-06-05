import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:order/features/tables/domain/entities/table_status.dart';

part 'table_entity.freezed.dart';

@freezed
abstract class RestaurantTable with _$RestaurantTable {
  const factory RestaurantTable({
    required String id,
    required String shopId,
    required String name,
    required TableStatus status,
  }) = _RestaurantTable;
}
