import 'package:pocketbase/pocketbase.dart';
import 'package:order/features/shop/domain/entities/shop.dart';

class ShopModel {
  static Shop fromRecord(RecordModel record) {
    return Shop(
      id: record.id,
      name: record.getStringValue('name'),
      isActive: record.getBoolValue('is_active'),
    );
  }
}
