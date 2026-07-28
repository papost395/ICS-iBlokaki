import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop_config.freezed.dart';
part 'shop_config.g.dart';

@freezed
abstract class ShopConfig with _$ShopConfig {
  const factory ShopConfig({
    required String id,
    required String shopId,
    @Default(false) bool isSplitPrintingEnabled,
    @Default('') String receiptHeader,
    @Default('') String receiptFooter,
    String? logoPath,
    String? stationName,
  }) = _ShopConfig;

  factory ShopConfig.fromJson(Map<String, dynamic> json) =>
      _$ShopConfigFromJson(json);
}
