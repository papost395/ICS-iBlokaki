import 'package:pocketbase/pocketbase.dart';
import 'package:order/features/printing/domain/entities/printer_device.dart';

class PrinterModel {
  static PrinterDevice fromRecord(RecordModel record) {
    return PrinterDevice(
      id: record.id,
      shopId: record.getStringValue('shop_id'),
      name: record.getStringValue('name'),
      connectionType: ConnectionType.values.firstWhere(
        (c) => c.name == record.getStringValue('connection_type'),
        orElse: () => ConnectionType.network,
      ),
      address: record.getStringValue('address'),
      role: PrinterRole.values.firstWhere(
        (r) => r.name == record.getStringValue('role'),
        orElse: () => PrinterRole.cashier,
      ),
      isUtf8: record.getBoolValue('is_utf8'),
      isCp737: record.getBoolValue('is_cp737'),
      paperSize: record.getIntValue('paper_size') == 58 ? 58 : 80,
    );
  }

  static Map<String, dynamic> toBody(PrinterDevice printer) {
    return {
      'shop_id': printer.shopId,
      'name': printer.name,
      'connection_type': printer.connectionType.name,
      'address': printer.address,
      'role': printer.role.name,
      'is_utf8': printer.isUtf8,
      'is_cp737': printer.isCp737,
      'paper_size': printer.paperSize,
    };
  }
}
