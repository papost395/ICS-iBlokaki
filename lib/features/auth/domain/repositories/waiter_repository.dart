import 'package:order/features/auth/domain/entities/waiter.dart';

abstract class WaiterRepository {
  Future<List<Waiter>> getWaiters(String shopId);
  Future<Waiter?> getWaiterByPin(String shopId, String pin);
  Future<Waiter> addWaiter(Waiter waiter);
  Future<void> deleteWaiter(String id);
}
