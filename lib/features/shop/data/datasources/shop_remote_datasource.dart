import 'package:pocketbase/pocketbase.dart';
import 'package:order/core/constants/api_constants.dart';
import 'package:order/core/errors/exceptions.dart';
import 'package:order/features/shop/data/models/shop_model.dart';
import 'package:order/features/shop/domain/entities/shop.dart';

abstract class ShopRemoteDataSource {
  Future<Shop> getShop(String shopId);
}

class ShopRemoteDataSourceImpl implements ShopRemoteDataSource {
  ShopRemoteDataSourceImpl({required this.pb});

  final PocketBase pb;

  @override
  Future<Shop> getShop(String shopId) async {
    try {
      final record = await pb
          .collection(ApiConstants.shopsCollection)
          .getOne(shopId);
      return ShopModel.fromRecord(record);
    } catch (e) {
      throw ServerException('Failed to fetch shop: ${e.toString()}');
    }
  }
}
