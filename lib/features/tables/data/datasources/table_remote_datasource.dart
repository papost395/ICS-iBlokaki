import 'package:pocketbase/pocketbase.dart';
import 'package:order/core/constants/api_constants.dart';
import 'package:order/core/errors/exceptions.dart';
import 'package:order/features/tables/data/models/table_model.dart';
import 'package:order/features/tables/domain/entities/table_entity.dart';
import 'package:order/features/tables/domain/entities/table_status.dart';

abstract class TableRemoteDataSource {
  Future<List<RestaurantTable>> getTables(String shopId);
  Future<void> updateTableStatus({
    required String tableId,
    required TableStatus status,
  });
  Future<RestaurantTable> addTable(String shopId, String name);
  Future<void> deleteTable(String id);
  Future<void> updateTableName({required String tableId, required String name});
}

class TableRemoteDataSourceImpl implements TableRemoteDataSource {
  TableRemoteDataSourceImpl({required this.pb});

  final PocketBase pb;

  @override
  Future<List<RestaurantTable>> getTables(String shopId) async {
    try {
      final result = await pb
          .collection(ApiConstants.tablesCollection)
          .getFullList(
            filter: 'shop_id = "$shopId"',
            sort: 'name',
          );
      return result.map(TableModel.fromRecord).toList();
    } catch (e) {
      throw ServerException('Failed to fetch tables: ${e.toString()}');
    }
  }

  @override
  Future<void> updateTableStatus({
    required String tableId,
    required TableStatus status,
  }) async {
    try {
      await pb.collection(ApiConstants.tablesCollection).update(
            tableId,
            body: TableModel.toBody(status: status),
          );
    } catch (e) {
      throw ServerException('Failed to update table: ${e.toString()}');
    }
  }

  @override
  Future<RestaurantTable> addTable(String shopId, String name) async {
    try {
      final result = await pb.collection(ApiConstants.tablesCollection).create(
            body: TableModel.toBodyFull(
              shopId: shopId,
              name: name,
              status: const Free(),
            ),
          );
      return TableModel.fromRecord(result);
    } catch (e) {
      throw ServerException('Failed to add table: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteTable(String id) async {
    try {
      await pb.collection(ApiConstants.tablesCollection).delete(id);
    } catch (e) {
      throw ServerException('Failed to delete table: ${e.toString()}');
    }
  }

  @override
  Future<void> updateTableName({
    required String tableId,
    required String name,
  }) async {
    try {
      await pb.collection(ApiConstants.tablesCollection).update(
            tableId,
            body: {'name': name},
          );
    } catch (e) {
      throw ServerException('Failed to update table name: ${e.toString()}');
    }
  }
}
