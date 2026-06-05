import 'package:order/features/products/domain/entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories(String shopId);
  Stream<List<Category>> watchCategories(String shopId);
}
