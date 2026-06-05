import 'package:pocketbase/pocketbase.dart';
import 'package:order/core/errors/exceptions.dart';
import 'package:order/features/auth/data/models/waiter_model.dart';
import 'package:order/features/auth/domain/entities/waiter.dart';

abstract class WaiterRemoteDataSource {
  Future<List<Waiter>> getWaiters(String shopId);
  Future<Waiter?> getWaiterByPin(String shopId, String pin);
  Future<Waiter> addWaiter(Waiter waiter);
  Future<void> deleteWaiter(String id);
}

class WaiterRemoteDataSourceImpl implements WaiterRemoteDataSource {
  WaiterRemoteDataSourceImpl({required this.pb});

  final PocketBase pb;

  @override
  Future<List<Waiter>> getWaiters(String shopId) async {
    try {
      final result = await pb.collection('waiters').getFullList(
            filter: 'shop_id = "$shopId"',
            sort: 'name',
          );
      return result.map(WaiterModel.fromRecord).toList();
    } catch (e) {
      throw ServerException('Failed to fetch waiters: ${e.toString()}');
    }
  }

  @override
  Future<Waiter?> getWaiterByPin(String shopId, String pin) async {
    final filterString = 'shop_id = "$shopId" && pin = "$pin"';
    try {
      final result = await pb.collection('waiters').getFirstListItem(filterString);
      return WaiterModel.fromRecord(result);
    } catch (e) {
      // getFirstListItem throws an error (404) if not found
      print('Error getting waiter by pin. Filter used: [$filterString]');
      print('PocketBase Error: $e');
      return null;
    }
  }

  @override
  Future<Waiter> addWaiter(Waiter waiter) async {
    try {
      final body = WaiterModel.toBody(waiter);
      body.removeWhere((key, value) => key == 'id' && (value == null || value == ''));
      final result = await pb.collection('waiters').create(body: body);
      return WaiterModel.fromRecord(result);
    } catch (e) {
      throw ServerException('Failed to add waiter: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteWaiter(String id) async {
    try {
      await pb.collection('waiters').delete(id);
    } catch (e) {
      throw ServerException('Failed to delete waiter: ${e.toString()}');
    }
  }
}
