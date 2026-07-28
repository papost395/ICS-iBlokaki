import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:order/features/orders/domain/entities/order_item.dart';
import 'package:order/features/printing/domain/entities/printer_device.dart';

part 'print_job.freezed.dart';

@freezed
abstract class PrintJob with _$PrintJob {
  const factory PrintJob({
    required PrinterDevice printer,
    required List<OrderItem> items,
    required String tableName,
    required String waiterName,
    String? header,
    String? footer,
    String? logoPath,
    String? stationName,
    DateTime? timestamp,
  }) = _PrintJob;
}
