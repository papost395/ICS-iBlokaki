import 'package:pocketbase/pocketbase.dart';
import 'package:order/core/constants/api_constants.dart';
import 'package:order/core/errors/exceptions.dart';
import 'package:order/features/products/data/models/product_model.dart';
import 'package:order/features/products/domain/entities/product.dart';
import 'package:http/http.dart' as http;

abstract class ProductRemoteDataSource {
  Future<List<Product>> getProducts(String shopId);
  Future<List<Product>> getProductsByCategory({
    required String shopId,
    required String categoryId,
  });
  Future<void> updateProduct(Product product);
  Future<void> uploadCsv({required String shopId, required String filePath});
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  ProductRemoteDataSourceImpl({required this.pb});

  final PocketBase pb;

  @override
  Future<List<Product>> getProducts(String shopId) async {
    try {
      final result = await pb
          .collection(ApiConstants.productsCollection)
          .getFullList(
            filter: 'shop_id = "$shopId"',
            sort: 'name',
          );
      return result.map(ProductModel.fromRecord).toList();
    } catch (e) {
      throw ServerException('Failed to fetch products: ${e.toString()}');
    }
  }

  @override
  Future<List<Product>> getProductsByCategory({
    required String shopId,
    required String categoryId,
  }) async {
    try {
      final result = await pb
          .collection(ApiConstants.productsCollection)
          .getFullList(
            filter: 'shop_id = "$shopId" && category_id = "$categoryId"',
            sort: 'name',
          );
      return result.map(ProductModel.fromRecord).toList();
    } catch (e) {
      throw ServerException('Failed to fetch products: ${e.toString()}');
    }
  }

  @override
  Future<void> updateProduct(Product product) async {
    try {
      await pb
          .collection(ApiConstants.productsCollection)
          .update(product.id, body: ProductModel.toBody(product));
    } catch (e) {
      throw ServerException('Failed to update product: ${e.toString()}');
    }
  }

  @override
  Future<void> uploadCsv({
    required String shopId,
    required String filePath,
  }) async {
    try {
      final uri = Uri.parse(
        '${pb.baseURL}/api/shops/$shopId/csv',
      );
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = pb.authStore.token
        ..fields['shop_id'] = shopId
        ..files.add(await http.MultipartFile.fromPath('file', filePath));
      final response = await request.send();
      if (response.statusCode != 200) {
        throw ServerException('CSV upload failed: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException('Failed to upload CSV: ${e.toString()}');
    }
  }
}
