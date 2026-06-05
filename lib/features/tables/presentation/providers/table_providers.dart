import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:order/core/providers/pocketbase_provider.dart';
import 'package:order/features/auth/presentation/providers/auth_providers.dart';
import 'package:order/features/tables/data/datasources/table_remote_datasource.dart';
import 'package:order/features/tables/data/repositories/table_repository_impl.dart';
import 'package:order/features/tables/domain/entities/table_entity.dart';
import 'package:order/features/tables/domain/entities/table_status.dart';
import 'package:order/features/tables/domain/repositories/table_repository.dart';

part 'table_providers.g.dart';

@Riverpod(keepAlive: true)
TableRepository tableRepository(Ref ref) {
  final pb = ref.watch(pocketBaseProvider);
  return TableRepositoryImpl(
    remoteDataSource: TableRemoteDataSourceImpl(pb: pb),
    pb: pb,
  );
}

@Riverpod(keepAlive: true)
Stream<List<RestaurantTable>> tablesStream(Ref ref) {
  final shopId = ref.watch(currentShopIdProvider);
  if (shopId == null) return const Stream.empty();
  final repo = ref.watch(tableRepositoryProvider);
  return repo.watchTables(shopId);
}

@riverpod
class TableActions extends _$TableActions {
  @override
  FutureOr<void> build() {}

  Future<void> updateStatus({
    required String tableId,
    required TableStatus status,
  }) async {
    final repo = ref.read(tableRepositoryProvider);
    await repo.updateTableStatus(tableId: tableId, status: status);
  }

  Future<void> addTable({
    required String shopId,
    required String name,
  }) async {
    final repo = ref.read(tableRepositoryProvider);
    await repo.addTable(shopId, name);
  }

  Future<void> deleteTable(String id) async {
    final repo = ref.read(tableRepositoryProvider);
    await repo.deleteTable(id);
  }

  Future<void> updateTableName({
    required String tableId,
    required String name,
  }) async {
    final repo = ref.read(tableRepositoryProvider);
    await repo.updateTableName(tableId: tableId, name: name);
  }
}
