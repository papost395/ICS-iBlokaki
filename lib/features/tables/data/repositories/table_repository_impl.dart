import 'dart:async';
import 'package:pocketbase/pocketbase.dart';
import 'package:order/core/constants/api_constants.dart';
import 'package:order/features/tables/data/datasources/table_remote_datasource.dart';
import 'package:order/features/tables/domain/entities/table_entity.dart';
import 'package:order/features/tables/domain/entities/table_status.dart';
import 'package:order/features/tables/domain/repositories/table_repository.dart';

class TableRepositoryImpl implements TableRepository {
  TableRepositoryImpl({
    required this.remoteDataSource,
    required this.pb,
  });

  final TableRemoteDataSource remoteDataSource;
  final PocketBase pb;

  @override
  Future<List<RestaurantTable>> getTables(String shopId) {
    return remoteDataSource.getTables(shopId);
  }

  @override
  Stream<List<RestaurantTable>> watchTables(String shopId) {
    final controller = StreamController<List<RestaurantTable>>.broadcast();
    Future<UnsubscribeFunc>? subscriptionFuture;

    remoteDataSource.getTables(shopId).then((tables) {
      if (!controller.isClosed) {
        controller.add(tables);
      }
    });

    subscriptionFuture = pb.collection(ApiConstants.tablesCollection).subscribe(
      '*',
      (e) async {
        try {
          final tables = await remoteDataSource.getTables(shopId);
          if (!controller.isClosed) {
            controller.add(tables);
          }
        } catch (_) {}
      },
    );

    controller.onCancel = () async {
      try {
        final unsubscribe = await subscriptionFuture;
        await unsubscribe?.call();
      } catch (_) {}
    };

    return controller.stream;
  }

  @override
  Future<void> updateTableStatus({
    required String tableId,
    required TableStatus status,
  }) {
    return remoteDataSource.updateTableStatus(
      tableId: tableId,
      status: status,
    );
  }

  @override
  Future<RestaurantTable> addTable(String shopId, String name) {
    return remoteDataSource.addTable(shopId, name);
  }

  @override
  Future<void> deleteTable(String id) {
    return remoteDataSource.deleteTable(id);
  }

  @override
  Future<void> updateTableName({
    required String tableId,
    required String name,
  }) {
    return remoteDataSource.updateTableName(
      tableId: tableId,
      name: name,
    );
  }
}
