import 'dart:async';
import 'package:pocketbase/pocketbase.dart';
import 'package:order/core/constants/api_constants.dart';
import 'package:order/features/products/data/datasources/product_remote_datasource.dart';
import 'package:order/features/products/domain/entities/product.dart';
import 'package:order/features/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.pb,
  });

  final ProductRemoteDataSource remoteDataSource;
  final PocketBase pb;

  @override
  Future<List<Product>> getProducts(String shopId) {
    return remoteDataSource.getProducts(shopId);
  }

  @override
  Future<List<Product>> getProductsByCategory({
    required String shopId,
    required String categoryId,
  }) {
    return remoteDataSource.getProductsByCategory(
      shopId: shopId,
      categoryId: categoryId,
    );
  }

  @override
  Stream<List<Product>> watchProducts(String shopId) {
    final controller = StreamController<List<Product>>.broadcast();
    List<Product> currentProducts = [];

    remoteDataSource.getProducts(shopId).then((products) {
      currentProducts = products;
      controller.add(currentProducts);
    });

    pb.collection(ApiConstants.productsCollection).subscribe(
      '*',
      (e) async {
        currentProducts = await remoteDataSource.getProducts(shopId);
        controller.add(currentProducts);
      },
    );

    controller.onCancel = () {
      pb.collection(ApiConstants.productsCollection).unsubscribe('*');
    };

    return controller.stream;
  }

  @override
  Future<void> updateProduct(Product product) {
    return remoteDataSource.updateProduct(product);
  }

  @override
  Future<void> uploadCsv({
    required String shopId,
    required String filePath,
  }) {
    return remoteDataSource.uploadCsv(shopId: shopId, filePath: filePath);
  }
}
