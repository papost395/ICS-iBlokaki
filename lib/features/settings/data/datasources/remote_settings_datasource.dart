import 'package:pocketbase/pocketbase.dart';
import 'package:order/core/constants/api_constants.dart';
import 'package:order/core/errors/exceptions.dart';
import 'package:order/features/settings/data/models/shop_config_model.dart';
import 'package:order/features/settings/domain/entities/shop_config.dart';

abstract class RemoteSettingsDataSource {
  Future<ShopConfig> getShopConfig(String shopId);
  Future<void> updateShopConfig(ShopConfig config);
}

class RemoteSettingsDataSourceImpl implements RemoteSettingsDataSource {
  RemoteSettingsDataSourceImpl({required this.pb});

  final PocketBase pb;

  @override
  Future<ShopConfig> getShopConfig(String shopId) async {
    try {
      final result = await pb
          .collection(ApiConstants.shopConfigsCollection)
          .getFirstListItem('shop_id = "$shopId"');
      return ShopConfigModel.fromRecord(result);
    } on ClientException catch (e) {
      if (e.statusCode == 404) {
        try {
          final newRecord = await pb.collection(ApiConstants.shopConfigsCollection).create(
            body: {
              'shop_id': shopId,
              'is_split_printing_enabled': false,
              'receipt_header': '',
              'receipt_footer': '',
            },
          );
          return ShopConfigModel.fromRecord(newRecord);
        } catch (createErr) {
          throw ServerException('Failed to create default shop config: ${createErr.toString()}');
        }
      }
      throw ServerException('Failed to fetch shop config: ${e.toString()}');
    } catch (e) {
      throw ServerException('Failed to fetch shop config: ${e.toString()}');
    }
  }

  @override
  Future<void> updateShopConfig(ShopConfig config) async {
    try {
      await pb.collection(ApiConstants.shopConfigsCollection).update(
            config.id,
            body: ShopConfigModel.toBody(config),
          );
    } catch (e) {
      throw ServerException('Failed to update shop config: ${e.toString()}');
    }
  }
}
