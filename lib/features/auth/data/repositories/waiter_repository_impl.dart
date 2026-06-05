import 'package:order/features/auth/data/datasources/waiter_remote_datasource.dart';
import 'package:order/features/auth/domain/entities/waiter.dart';
import 'package:order/features/auth/domain/repositories/waiter_repository.dart';

class WaiterRepositoryImpl implements WaiterRepository {
  WaiterRepositoryImpl({required this.remoteDataSource});

  final WaiterRemoteDataSource remoteDataSource;

  @override
  Future<List<Waiter>> getWaiters(String shopId) {
    return remoteDataSource.getWaiters(shopId);
  }

  @override
  Future<Waiter?> getWaiterByPin(String shopId, String pin) {
    return remoteDataSource.getWaiterByPin(shopId, pin);
  }

  @override
  Future<Waiter> addWaiter(Waiter waiter) {
    return remoteDataSource.addWaiter(waiter);
  }

  @override
  Future<void> deleteWaiter(String id) {
    return remoteDataSource.deleteWaiter(id);
  }
}
