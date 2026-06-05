import 'package:pocketbase/pocketbase.dart';
import 'package:order/features/settings/domain/entities/shop_config.dart';

class ShopConfigModel {
  static ShopConfig fromRecord(RecordModel record) {
    return ShopConfig(
      id: record.id,
      shopId: record.getStringValue('shop_id'),
      isSplitPrintingEnabled:
          record.getBoolValue('is_split_printing_enabled'),
      receiptHeader: record.getStringValue('receipt_header'),
      receiptFooter: record.getStringValue('receipt_footer'),
    );
  }

  static Map<String, dynamic> toBody(ShopConfig config) {
    return {
      'is_split_printing_enabled': config.isSplitPrintingEnabled,
      'receipt_header': config.receiptHeader,
      'receipt_footer': config.receiptFooter,
    };
  }
}
