import 'package:pocketbase/pocketbase.dart';
import 'package:order/features/products/domain/entities/category.dart';

class CategoryModel {
  static Category fromRecord(RecordModel record) {
    return Category(
      id: record.id,
      shopId: record.getStringValue('shop_id'),
      name: record.getStringValue('name'),
    );
  }
}
