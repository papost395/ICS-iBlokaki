import 'package:pocketbase/pocketbase.dart';
import 'package:order/core/constants/api_constants.dart';
import 'package:order/core/errors/exceptions.dart';
import 'package:order/features/printing/data/models/printer_model.dart';
import 'package:order/features/printing/domain/entities/printer_device.dart';

abstract class PrinterRemoteDataSource {
  Future<List<PrinterDevice>> getPrinters(String shopId);
  Future<PrinterDevice> addPrinter(PrinterDevice printer);
  Future<void> deletePrinter(String id);
  Future<PrinterDevice> updatePrinter(PrinterDevice printer);
}

class PrinterRemoteDataSourceImpl implements PrinterRemoteDataSource {
  PrinterRemoteDataSourceImpl({required this.pb});

  final PocketBase pb;

  @override
  Future<List<PrinterDevice>> getPrinters(String shopId) async {
    try {
      final result = await pb
          .collection(ApiConstants.printersCollection)
          .getFullList(
            filter: 'shop_id = "$shopId"',
            sort: 'name',
          );
      return result.map(PrinterModel.fromRecord).toList();
    } catch (e) {
      throw ServerException('Failed to fetch printers: ${e.toString()}');
    }
  }

  @override
  Future<PrinterDevice> addPrinter(PrinterDevice printer) async {
    try {
      final result = await pb
          .collection(ApiConstants.printersCollection)
          .create(body: PrinterModel.toBody(printer));
      return PrinterModel.fromRecord(result);
    } catch (e) {
      throw ServerException('Failed to add printer: ${e.toString()}');
    }
  }

  @override
  Future<void> deletePrinter(String id) async {
    try {
      await pb.collection(ApiConstants.printersCollection).delete(id);
    } catch (e) {
      throw ServerException('Failed to delete printer: ${e.toString()}');
    }
  }

  @override
  Future<PrinterDevice> updatePrinter(PrinterDevice printer) async {
    try {
      final result = await pb
          .collection(ApiConstants.printersCollection)
          .update(printer.id, body: PrinterModel.toBody(printer));
      return PrinterModel.fromRecord(result);
    } catch (e) {
      throw ServerException('Failed to update printer: ${e.toString()}');
    }
  }
}
