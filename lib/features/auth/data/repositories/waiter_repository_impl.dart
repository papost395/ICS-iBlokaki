import 'package:order/features/auth/data/datasources/waiter_remote_datasource.dart';
import 'package:order/features/auth/domain/entities/waiter.dart';
import 'package:order/features/auth/domain/repositories/waiter_repository.dart';

import 'package:order/core/database/database_helper.dart';

class WaiterRepositoryImpl implements WaiterRepository {
  WaiterRepositoryImpl({
    required this.remoteDataSource,
    this.isLocalMode = false,
  });

  final WaiterRemoteDataSource remoteDataSource;
  final bool isLocalMode;

  @override
  Future<List<Waiter>> getWaiters(String shopId) async {
    if (isLocalMode) {
      return await DatabaseHelper.instance.getWaiters(shopId);
    }
    return remoteDataSource.getWaiters(shopId);
  }

  @override
  Future<Waiter?> getWaiterByPin(String shopId, String pin) async {
    if (isLocalMode) {
      return await DatabaseHelper.instance.getWaiterByPin(shopId, pin);
    }
    return remoteDataSource.getWaiterByPin(shopId, pin);
  }

  @override
  Future<Waiter> addWaiter(Waiter waiter) async {
    if (isLocalMode) {
      await DatabaseHelper.instance.addWaiter(waiter);
      return waiter;
    }
    return remoteDataSource.addWaiter(waiter);
  }

  @override
  Future<void> deleteWaiter(String id) async {
    if (isLocalMode) {
      await DatabaseHelper.instance.deleteWaiter(id);
      return;
    }
    return remoteDataSource.deleteWaiter(id);
  }
}
