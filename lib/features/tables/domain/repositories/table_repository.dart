import 'package:order/features/tables/domain/entities/table_entity.dart';
import 'package:order/features/tables/domain/entities/table_status.dart';

abstract class TableRepository {
  Future<List<RestaurantTable>> getTables(String shopId);
  Stream<List<RestaurantTable>> watchTables(String shopId);
  Future<void> updateTableStatus({
    required String tableId,
    required TableStatus status,
  });
  Future<RestaurantTable> addTable(String shopId, String name);
  Future<void> deleteTable(String id);
  Future<void> updateTableName({required String tableId, required String name});
}
