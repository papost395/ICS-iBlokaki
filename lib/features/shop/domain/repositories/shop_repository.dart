import 'package:order/features/shop/domain/entities/shop.dart';

abstract class ShopRepository {
  Future<Shop> getShop(String shopId);
  Stream<Shop> watchShop(String shopId);
}
