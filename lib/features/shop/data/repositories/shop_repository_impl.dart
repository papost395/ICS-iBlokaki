import 'dart:async';
import 'package:pocketbase/pocketbase.dart';
import 'package:order/core/constants/api_constants.dart';
import 'package:order/features/shop/data/datasources/shop_remote_datasource.dart';
import 'package:order/features/shop/data/models/shop_model.dart';
import 'package:order/features/shop/domain/entities/shop.dart';
import 'package:order/features/shop/domain/repositories/shop_repository.dart';

class ShopRepositoryImpl implements ShopRepository {
  ShopRepositoryImpl({
    required this.remoteDataSource,
    required this.pb,
  });

  final ShopRemoteDataSource remoteDataSource;
  final PocketBase pb;

  @override
  Future<Shop> getShop(String shopId) {
    return remoteDataSource.getShop(shopId);
  }

  @override
  Stream<Shop> watchShop(String shopId) {
    final controller = StreamController<Shop>.broadcast();

    remoteDataSource.getShop(shopId).then(controller.add);

    pb.collection(ApiConstants.shopsCollection).subscribe(
      shopId,
      (e) {
        if (e.record != null) {
          controller.add(ShopModel.fromRecord(e.record!));
        }
      },
    );

    controller.onCancel = () {
      pb.collection(ApiConstants.shopsCollection).unsubscribe(shopId);
    };

    return controller.stream;
  }
}
