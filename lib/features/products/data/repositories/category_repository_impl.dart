import 'dart:async';
import 'package:pocketbase/pocketbase.dart';
import 'package:order/core/constants/api_constants.dart';
import 'package:order/features/products/data/datasources/category_remote_datasource.dart';
import 'package:order/features/products/domain/entities/category.dart';
import 'package:order/features/products/domain/repositories/category_repository.dart';

import 'package:order/core/database/database_helper.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl({
    required this.remoteDataSource,
    required this.pb,
    this.isLocalMode = false,
  });

  final CategoryRemoteDataSource remoteDataSource;
  final PocketBase pb;
  final bool isLocalMode;

  @override
  Future<List<Category>> getCategories(String shopId) async {
    if (isLocalMode) {
      return await DatabaseHelper.instance.getCategories(shopId);
    }
    return remoteDataSource.getCategories(shopId);
  }

  @override
  Stream<List<Category>> watchCategories(String shopId) {
    if (isLocalMode) {
      return Stream.fromFuture(DatabaseHelper.instance.getCategories(shopId));
    }

    final controller = StreamController<List<Category>>.broadcast();

    remoteDataSource.getCategories(shopId).then(controller.add);

    pb.collection(ApiConstants.categoriesCollection).subscribe(
      '*',
      (e) async {
        final categories = await remoteDataSource.getCategories(shopId);
        controller.add(categories);
      },
    );

    controller.onCancel = () {
      pb.collection(ApiConstants.categoriesCollection).unsubscribe('*');
    };

    return controller.stream;
  }
}
