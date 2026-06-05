import 'package:pocketbase/pocketbase.dart';
import 'package:order/features/tables/domain/entities/table_entity.dart';
import 'package:order/features/tables/domain/entities/table_status.dart';

class TableModel {
  static RestaurantTable fromRecord(RecordModel record) {
    final statusStr = record.getStringValue('status');
    final reservationTimeStr = record.getStringValue('reservation_time');
    final description = record.getStringValue('description');
    DateTime? reservationTime;
    if (reservationTimeStr.isNotEmpty) {
      reservationTime = DateTime.tryParse(reservationTimeStr);
    }

    return RestaurantTable(
      id: record.id,
      shopId: record.getStringValue('shop_id'),
      name: record.getStringValue('name'),
      status: TableStatus.fromString(
        statusStr,
        reservationTime: reservationTime,
        description: description,
      ),
    );
  }

  static Map<String, dynamic> toBody({
    required TableStatus status,
  }) {
    final body = <String, dynamic>{
      'status': status.value,
    };
    if (status case Reserved(:final reservationTime, :final description)) {
      body['reservation_time'] = reservationTime.toIso8601String();
      body['description'] = description;
    } else {
      body['reservation_time'] = null;
      body['description'] = null;
    }
    return body;
  }

  static Map<String, dynamic> toBodyFull({
    required String shopId,
    required String name,
    required TableStatus status,
  }) {
    final body = <String, dynamic>{
      'shop_id': shopId,
      'name': name,
      'status': status.value,
    };
    if (status case Reserved(:final reservationTime, :final description)) {
      body['reservation_time'] = reservationTime.toIso8601String();
      body['description'] = description;
    } else {
      body['reservation_time'] = null;
      body['description'] = null;
    }
    return body;
  }
}
