import 'package:freezed_annotation/freezed_annotation.dart';

part 'sale_record.freezed.dart';
part 'sale_record.g.dart';

@freezed
abstract class SaleRecord with _$SaleRecord {
  const factory SaleRecord({
    required String id,
    required String shopId,
    required String productId,
    required String productName,
    required int quantity,
    required double price,
    required int timestamp, // millisecondsSinceEpoch
  }) = _SaleRecord;

  factory SaleRecord.fromJson(Map<String, dynamic> json) =>
      _$SaleRecordFromJson(json);
}
