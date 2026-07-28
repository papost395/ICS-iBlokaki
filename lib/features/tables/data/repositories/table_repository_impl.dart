import 'dart:async';
import 'package:pocketbase/pocketbase.dart';
import 'package:order/core/constants/api_constants.dart';
import 'package:order/features/tables/data/datasources/table_remote_datasource.dart';
import 'package:order/core/database/database_helper.dart';
import 'package:order/features/tables/domain/entities/table_entity.dart';
import 'package:order/features/tables/domain/entities/table_status.dart';
import 'package:order/features/tables/domain/repositories/table_repository.dart';

class TableRepositoryImpl implements TableRepository {
  TableRepositoryImpl({
    required this.remoteDataSource,
    required this.pb,
    this.isLocalMode = false,
  });

  final TableRemoteDataSource remoteDataSource;
  final PocketBase pb;
  final bool isLocalMode;

  @override
  Future<List<RestaurantTable>> getTables(String shopId) {
    if (isLocalMode) {
      return DatabaseHelper.instance.getTables(shopId);
    }
    return remoteDataSource.getTables(shopId);
  }

  @override
  Stream<List<RestaurantTable>> watchTables(String shopId) {
    final controller = StreamController<List<RestaurantTable>>.broadcast();
    Future<UnsubscribeFunc>? subscriptionFuture;

    if (isLocalMode) {
      DatabaseHelper.instance.getTables(shopId).then((tables) {
        if (!controller.isClosed) {
          controller.add(tables);
        }
      });
      // In local mode, we don't have a real-time subscription for tables yet.
      // Returning stream from future is enough for basic viewing.
      return controller.stream;
    }

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
    if (isLocalMode) {
      return DatabaseHelper.instance.updateTableStatus(tableId, status);
    }
    return remoteDataSource.updateTableStatus(
      tableId: tableId,
      status: status,
    );
  }

  @override
  Future<RestaurantTable> addTable(String shopId, String name) async {
    if (isLocalMode) {
      final id = 'local_table_${DateTime.now().millisecondsSinceEpoch}';
      final table = RestaurantTable(
        id: id,
        shopId: shopId,
        name: name,
        status: const Free(),
      );
      await DatabaseHelper.instance.addTable(table);
      return table;
    }
    return remoteDataSource.addTable(shopId, name);
  }

  @override
  Future<void> deleteTable(String id) {
    if (isLocalMode) {
      return DatabaseHelper.instance.deleteTable(id);
    }
    return remoteDataSource.deleteTable(id);
  }

  @override
  Future<void> updateTableName({
    required String tableId,
    required String name,
  }) {
    if (isLocalMode) {
      return DatabaseHelper.instance.updateTableName(tableId, name);
    }
    return remoteDataSource.updateTableName(
      tableId: tableId,
      name: name,
    );
  }
}
