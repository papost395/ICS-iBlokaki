import 'package:pocketbase/pocketbase.dart';
import 'package:order/features/products/domain/entities/department.dart';
import 'package:order/features/products/domain/entities/product.dart';

class ProductModel {
  static Product fromRecord(RecordModel record) {
    return Product(
      id: record.id,
      shopId: record.getStringValue('shop_id'),
      categoryId: record.getStringValue('category_id'),
      name: record.getStringValue('name'),
      price: record.getDoubleValue('price'),
      department: Department.fromString(
        record.getStringValue('department'),
      ),
    );
  }

  static Map<String, dynamic> toBody(Product product) {
    return {
      'shop_id': product.shopId,
      'category_id': product.categoryId,
      'name': product.name,
      'price': product.price,
      'department': product.department.name,
    };
  }
}
