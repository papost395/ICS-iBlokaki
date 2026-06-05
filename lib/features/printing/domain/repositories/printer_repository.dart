import 'package:order/features/printing/domain/entities/printer_device.dart';
import 'package:order/features/printing/domain/entities/print_job.dart';

abstract class PrinterRepository {
  Future<List<PrinterDevice>> getPrinters(String shopId);
  Stream<List<PrinterDevice>> watchPrinters(String shopId);
  Future<void> printJob(PrintJob job);
  Future<bool> testConnection(PrinterDevice printer);
  Future<PrinterDevice> addPrinter(PrinterDevice printer);
  Future<void> deletePrinter(String id);
  Future<PrinterDevice> updatePrinter(PrinterDevice printer);
}
