import 'package:pocketbase/pocketbase.dart';
import 'package:order/features/auth/domain/entities/waiter.dart';

class WaiterModel {
  static Waiter fromRecord(RecordModel record) {
    return Waiter(
      id: record.id,
      shopId: record.getStringValue('shop_id'),
      name: record.getStringValue('name'),
      pin: record.getStringValue('pin'),
    );
  }

  static Map<String, dynamic> toBody(Waiter waiter) {
    return {
      'shop_id': waiter.shopId,
      'name': waiter.name,
      'pin': waiter.pin,
    };
  }
}
