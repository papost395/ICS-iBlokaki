import 'dart:async';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:order/core/constants/api_constants.dart';
import 'package:order/features/products/data/datasources/product_remote_datasource.dart';
import 'package:order/features/products/domain/entities/product.dart';
import 'package:order/features/products/domain/entities/category.dart';
import 'package:order/features/products/domain/entities/department.dart';
import 'package:order/features/products/domain/repositories/product_repository.dart';

import 'package:order/core/database/database_helper.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.pb,
    this.isLocalMode = false,
  });

  final ProductRemoteDataSource remoteDataSource;
  final PocketBase pb;
  final bool isLocalMode;

  @override
  Future<List<Product>> getProducts(String shopId) async {
    if (isLocalMode) {
      return await DatabaseHelper.instance.getProducts(shopId);
    }
    return remoteDataSource.getProducts(shopId);
  }

  @override
  Future<List<Product>> getProductsByCategory({
    required String shopId,
    required String categoryId,
  }) async {
    if (isLocalMode) {
      final allProducts = await DatabaseHelper.instance.getProducts(shopId);
      return allProducts.where((p) => p.categoryId == categoryId).toList();
    }
    return remoteDataSource.getProductsByCategory(
      shopId: shopId,
      categoryId: categoryId,
    );
  }

  @override
  Stream<List<Product>> watchProducts(String shopId) {
    if (isLocalMode) {
      return Stream.fromFuture(DatabaseHelper.instance.getProducts(shopId));
    }

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
  Future<void> updateProduct(Product product) async {
    if (isLocalMode) {
      // addProduct uses ConflictAlgorithm.replace, so it acts as an upsert/update
      return await DatabaseHelper.instance.addProduct(product);
    }
    return remoteDataSource.updateProduct(product);
  }

  @override
  Future<void> uploadCsv({
    required String shopId,
    required String filePath,
  }) async {
    if (isLocalMode) {
      final file = File(filePath);
      final contents = await file.readAsString();
      final rows = Csv().decode(contents);
      
      // Skip header row if present (assuming Product_Name,Price,Category_Name,Department)
      bool isFirstRow = true;
      
      final allProducts = await DatabaseHelper.instance.getProducts(shopId);
      final productsByName = {for (var p in allProducts) p.name.toLowerCase(): p};

      for (var row in rows) {
        if (isFirstRow) {
          isFirstRow = false;
          continue; // Skip header
        }
        
        if (row.length >= 4) {
          final productName = row[0].toString().trim();
          final priceStr = row[1].toString().trim();
          final categoryName = row[2].toString().trim();
          final departmentStr = row[3].toString().trim().toLowerCase();
          
          if (productName.isEmpty || categoryName.isEmpty) continue;
          
          final price = double.tryParse(priceStr) ?? 0.0;
          
          Department dept;
          switch (departmentStr) {
            case 'bar':
              dept = Department.bar;
              break;
            case 'cashier':
              dept = Department.none; // Changed from cashier to none
              break;
            default:
              dept = Department.kitchen;
          }
          
          // Find or create category
          var category = await DatabaseHelper.instance.getCategoryByName(shopId, categoryName);
          if (category == null) {
            category = Category(
              id: 'c_${DateTime.now().millisecondsSinceEpoch}',
              shopId: shopId,
              name: categoryName,
            );
            await DatabaseHelper.instance.addCategory(category);
            // small delay to ensure unique IDs if iterating too fast
            await Future.delayed(const Duration(milliseconds: 1));
          }
          
          final productKey = productName.toLowerCase();
          var product = productsByName[productKey];

          if (product != null) {
            // Update existing
            product = product.copyWith(
              price: price,
              categoryId: category.id,
              department: dept,
            );
          } else {
            // Create new
            product = Product(
              id: 'p_${DateTime.now().millisecondsSinceEpoch}',
              shopId: shopId,
              categoryId: category.id,
              name: productName,
              price: price,
              department: dept,
            );
            productsByName[productKey] = product;
          }
          
          await DatabaseHelper.instance.addProduct(product);
          await Future.delayed(const Duration(milliseconds: 1));
        }
      }
      return;
    }
    return remoteDataSource.uploadCsv(shopId: shopId, filePath: filePath);
  }
}
