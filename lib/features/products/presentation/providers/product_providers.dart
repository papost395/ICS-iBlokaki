import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:order/core/providers/pocketbase_provider.dart';
import 'package:order/features/auth/presentation/providers/auth_providers.dart';
import 'package:order/features/products/data/datasources/category_remote_datasource.dart';
import 'package:order/features/products/data/datasources/product_remote_datasource.dart';
import 'package:order/features/products/data/repositories/category_repository_impl.dart';
import 'package:order/features/products/data/repositories/product_repository_impl.dart';
import 'package:order/features/products/domain/entities/category.dart';
import 'package:order/features/products/domain/entities/product.dart';
import 'package:order/features/products/domain/repositories/category_repository.dart';
import 'package:order/features/products/domain/repositories/product_repository.dart';

import 'package:order/core/providers/storage_mode_provider.dart';
import 'package:order/core/database/database_helper.dart';

part 'product_providers.g.dart';

@Riverpod(keepAlive: true)
ProductRepository productRepository(Ref ref) {
  final pb = ref.watch(pocketBaseProvider);
  final isLocalMode = ref.watch(storageModeNotifierProvider);
  return ProductRepositoryImpl(
    remoteDataSource: ProductRemoteDataSourceImpl(pb: pb),
    pb: pb,
    isLocalMode: isLocalMode,
  );
}

@Riverpod(keepAlive: true)
CategoryRepository categoryRepository(Ref ref) {
  final pb = ref.watch(pocketBaseProvider);
  final isLocalMode = ref.watch(storageModeNotifierProvider);
  return CategoryRepositoryImpl(
    remoteDataSource: CategoryRemoteDataSourceImpl(pb: pb),
    pb: pb,
    isLocalMode: isLocalMode,
  );
}

@riverpod
Stream<List<Product>> productsStream(Ref ref) {
  final shopId = ref.watch(currentShopIdProvider);
  if (shopId == null) return const Stream.empty();
  final repo = ref.watch(productRepositoryProvider);
  return repo.watchProducts(shopId);
}

@riverpod
Stream<List<Category>> categoriesStream(Ref ref) {
  final shopId = ref.watch(currentShopIdProvider);
  if (shopId == null) return const Stream.empty();
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.watchCategories(shopId);
}

@riverpod
Future<List<Product>> productsByCategory(
  Ref ref,
  String categoryId,
) async {
  final shopId = ref.watch(currentShopIdProvider);
  if (shopId == null) return [];
  final repo = ref.watch(productRepositoryProvider);
  return repo.getProductsByCategory(
    shopId: shopId,
    categoryId: categoryId,
  );
}

@riverpod
class ProductActions extends _$ProductActions {
  @override
  FutureOr<void> build() {}

  Future<void> updateProduct(Product product) async {
    final repo = ref.read(productRepositoryProvider);
    await repo.updateProduct(product);
    ref.invalidate(productsStreamProvider);
  }
}
