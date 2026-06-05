import 'package:order/features/products/domain/entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts(String shopId);
  Future<List<Product>> getProductsByCategory({
    required String shopId,
    required String categoryId,
  });
  Stream<List<Product>> watchProducts(String shopId);
  Future<void> updateProduct(Product product);
  Future<void> uploadCsv({required String shopId, required String filePath});
}
