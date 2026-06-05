import 'package:pocketbase/pocketbase.dart';
import 'package:order/core/constants/api_constants.dart';
import 'package:order/core/errors/exceptions.dart';
import 'package:order/features/products/data/models/category_model.dart';
import 'package:order/features/products/domain/entities/category.dart';

abstract class CategoryRemoteDataSource {
  Future<List<Category>> getCategories(String shopId);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  CategoryRemoteDataSourceImpl({required this.pb});

  final PocketBase pb;

  @override
  Future<List<Category>> getCategories(String shopId) async {
    try {
      final result = await pb
          .collection(ApiConstants.categoriesCollection)
          .getFullList(
            filter: 'shop_id = "$shopId"',
            sort: 'name',
          );
      return result.map(CategoryModel.fromRecord).toList();
    } catch (e) {
      throw ServerException('Failed to fetch categories: ${e.toString()}');
    }
  }
}
