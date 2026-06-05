import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:order/core/constants/api_constants.dart';
import 'package:order/features/printing/data/datasources/printer_remote_datasource.dart';
import 'package:order/features/printing/domain/entities/print_job.dart';
import 'package:order/features/printing/domain/entities/printer_device.dart';
import 'package:order/features/printing/domain/repositories/printer_repository.dart';
import 'package:order/features/settings/domain/repositories/settings_repository.dart';
import 'package:order/features/printing/data/datasources/sunmi_cloud_printer.dart';
import 'package:logger/logger.dart';

class PrinterRepositoryImpl implements PrinterRepository {
  PrinterRepositoryImpl({
    required this.remoteDataSource,
    required this.pb,
    required this.settingsRepo,
  });

  final PrinterRemoteDataSource remoteDataSource;
  final PocketBase pb;
  final SettingsRepository settingsRepo;
  final _bluetooth = BlueThermalPrinter.instance;

  var logger = Logger(
    printer: PrettyPrinter(
        methodCount: 2, // Number of method calls to be displayed
        errorMethodCount: 8, // Number of method calls if stacktrace is provided
        lineLength: 120, // Width of the output
        colors: true, // Colorful log messages
        printEmojis: true, // Print an emoji for each log message
        // Should each log print contain a timestamp
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  @override
  Future<List<PrinterDevice>> getPrinters(String shopId) {
    return remoteDataSource.getPrinters(shopId);
  }

  @override
  Future<PrinterDevice> addPrinter(PrinterDevice printer) {
    return remoteDataSource.addPrinter(printer);
  }

  @override
  Future<void> deletePrinter(String id) {
    return remoteDataSource.deletePrinter(id);
  }

  @override
  Future<PrinterDevice> updatePrinter(PrinterDevice printer) {
    return remoteDataSource.updatePrinter(printer);
  }

  @override
  Stream<List<PrinterDevice>> watchPrinters(String shopId) {
    final controller = StreamController<List<PrinterDevice>>.broadcast();
    Future<UnsubscribeFunc>? subscriptionFuture;

    remoteDataSource.getPrinters(shopId).then((printers) {
      if (!controller.isClosed) {
        controller.add(printers);
      }
    });

    subscriptionFuture = pb.collection(ApiConstants.printersCollection).subscribe(
      '*',
      (e) async {
        try {
          final printers = await remoteDataSource.getPrinters(shopId);
          if (!controller.isClosed) {
            controller.add(printers);
          }
        } catch (_) {}
      },
    );

    controller.onCancel = () async {
      try {
        final unsubscribe = await subscriptionFuture;
        await unsubscribe?.call();
      } catch (_) {}
    };

    return controller.stream;
  }

  Future<bool> _requestBluetoothPermissions() async {
    if (!Platform.isAndroid) return true;

    int sdkInt = 0;
    try {
      final versionStr = Platform.operatingSystemVersion;
      final match = RegExp(r'SDK\s+(\d+)').firstMatch(versionStr);
      if (match != null) {
        sdkInt = int.tryParse(match.group(1) ?? '') ?? 0;
      } else {
        final matchDigits = RegExp(r'(\d+)').firstMatch(versionStr);
        if (matchDigits != null) {
          sdkInt = int.tryParse(matchDigits.group(1) ?? '') ?? 0;
        }
      }
    } catch (_) {}

    if (sdkInt >= 31) {
      final status = await Permission.bluetoothConnect.request();
      final scanStatus = await Permission.bluetoothScan.request();
      return status.isGranted && scanStatus.isGranted;
    } else {
      final status = await Permission.location.request();
      return status.isGranted;
    }
  }

  @override
  Future<void> printJob(PrintJob job) async {
    if (job.printer.connectionType == ConnectionType.network) {
      final parts = job.printer.address.split(':');
      final ip = parts[0];
      final port = parts.length > 1 ? int.tryParse(parts[1]) ?? 9100 : 9100;

      Socket? socket;
      try {
        socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 4));
        final bytes = _compileEscPosBytes(job);
        socket.add(bytes);
        await socket.flush();
      } finally {
        await socket?.close();
      }
    } else if (job.printer.connectionType == ConnectionType.cloud) {
      final sunmi = SunmiCloudPrinter(settingsRepo);
      sunmi.clear();

      final bytes = _compileEscPosBytes(job);
      sunmi.addRawBytes(bytes);
      
      final tradeNo = DateTime.now().millisecondsSinceEpoch.toString();
      final sn = job.printer.address.trim();

      await sunmi.pushContent(
        tradeNo: tradeNo,
        sn: sn,
        count: 1,
      );
    } else {
      // Bluetooth actual printing
      try {
        final hasPermission = await _requestBluetoothPermissions();
        if (!hasPermission) {
          throw Exception('Δεν παραχωρήθηκαν δικαιώματα Bluetooth / Τοποθεσίας.');
        }

        final devices = await _bluetooth.getBondedDevices();
        BluetoothDevice? targetDevice;
        final cleanPrinterAddress = job.printer.address.trim().toUpperCase();

        for (final device in devices) {
          final cleanDeviceAddress = device.address?.trim().toUpperCase();
          if (cleanDeviceAddress == cleanPrinterAddress) {
            targetDevice = device;
            break;
          }
        }

        targetDevice ??= BluetoothDevice(job.printer.name, job.printer.address);

        // Always disconnect first to reset connection state
        try {
          await _bluetooth.disconnect();
        } catch (_) {}
        // Short delay to let BT stack reset
        await Future.delayed(const Duration(milliseconds: 300));

        logger.i('BT: Connecting to ${job.printer.name} (${job.printer.address})...');
        // Timeout on connect to prevent hanging forever
        await _bluetooth.connect(targetDevice).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception('Bluetooth connect timeout (10s)'),
        );
        logger.i('BT: Connected. Sending ${job.items.length} items...');

        final bytes = _compileEscPosBytes(job);
        await _bluetooth.writeBytes(Uint8List.fromList(bytes));
        
        // Wait for buffer transmission before disconnecting
        await Future.delayed(const Duration(milliseconds: 800));
        await _bluetooth.disconnect();
        logger.i('BT: Print complete, disconnected.');
      } catch (e) {
        logger.e('Bluetooth print error: $e');
        // Ensure disconnect on error too
        try { await _bluetooth.disconnect(); } catch (_) {}
        rethrow;
      }
    }
  }

  @override
  Future<bool> testConnection(
    PrinterDevice printer, {
    String header = '',
    String footer = '',
  }) async {
    logger.i('Footer for test print: $footer');

    if (printer.connectionType == ConnectionType.network) {
      final parts = printer.address.split(':');
      final ip = parts[0];
      final port = parts.length > 1 ? int.tryParse(parts[1]) ?? 9100 : 9100;

      Socket? socket;
      try {
        socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 4));
        final bytes = _compileTestEscPosBytes(printer, header, footer);
        socket.add(bytes);
        await socket.flush();
        return true;
      } catch (_) {
        return false;
      } finally {
        await socket?.close();
      }
    } else if (printer.connectionType == ConnectionType.cloud) {
      try {
        final sunmi = SunmiCloudPrinter(settingsRepo);
        sunmi.clear();

        final bytes = _compileTestEscPosBytes(printer, header, footer);
        sunmi.addRawBytes(bytes);
        
        final tradeNo = DateTime.now().millisecondsSinceEpoch.toString();
        final sn = printer.address.trim();

        await sunmi.pushContent(
          tradeNo: tradeNo,
          sn: sn,
          count: 1,
        );
        return true;
      } catch (e) {
        logger.e('Cloud test print error: $e');
        return false;
      }
    } else {
      // Bluetooth actual test print
      try {
        final hasPermission = await _requestBluetoothPermissions();
        if (!hasPermission) {
          throw Exception('Δεν παραχωρήθηκαν δικαιώματα Bluetooth / Τοποθεσίας.');
        }

        final devices = await _bluetooth.getBondedDevices();
        BluetoothDevice? targetDevice;
        final cleanPrinterAddress = printer.address.trim().toUpperCase();

        for (final device in devices) {
          final cleanDeviceAddress = device.address?.trim().toUpperCase();
          if (cleanDeviceAddress == cleanPrinterAddress) {
            targetDevice = device;
            break;
          }
        }

        targetDevice ??= BluetoothDevice(printer.name, printer.address);

        // Always disconnect first to reset connection state
        try {
          await _bluetooth.disconnect();
        } catch (_) {}

        await _bluetooth.connect(targetDevice);

        final bytes = _compileTestEscPosBytes(printer, header, footer);
        await _bluetooth.writeBytes(Uint8List.fromList(bytes));
        
        // Wait for buffer transmission before disconnecting
        await Future.delayed(const Duration(milliseconds: 800));
        await _bluetooth.disconnect();
        return true;
      } catch (e) {
        debugPrint('Bluetooth test print error: $e');
        return false;
      }
    }
  }

  List<int> _compileTestEscPosBytes(PrinterDevice printer, String header, String footer) {
    final bytes = <int>[];
    final int width = printer.paperSize == 58 ? 32 : 48;
    final String separator = '-' * width;

    // 1. Initialize printer
    bytes.addAll([0x1B, 0x40]);
    // 2. Select encoding dynamically
    bytes.addAll(_compileEncodingHeader(printer));

    // 3. Header (Center)
    if (header.isNotEmpty) {
      bytes.addAll([0x1B, 0x61, 1]); // Center
      bytes.addAll(_encodeText('$header\n\n', printer));
    }

    // 4. Title (Center, Bold, Double width & height)
    bytes.addAll([0x1B, 0x61, 1]); // Center
    bytes.addAll([0x1B, 0x45, 1]); // Bold on
    bytes.addAll([0x1D, 0x21, 0x11]); // Double height/width
    bytes.addAll(_encodeText('ΔΟΚΙΜΑΣΤΙΚΗ ΕΚΤΥΠΩΣΗ\n(TEST PRINT)\n\n', printer));
    bytes.addAll([0x1D, 0x21, 0x00]); // Reset size
    bytes.addAll([0x1B, 0x45, 0]); // Bold off

    // 5. Details (Left)
    bytes.addAll([0x1B, 0x61, 0]); // Left
    bytes.addAll(_encodeText('Εκτυπωτής: ${printer.name}\n', printer));
    bytes.addAll(_encodeText('Σύνδεση: ${printer.connectionType.name.toUpperCase()}\n', printer));
    bytes.addAll(_encodeText('Διεύθυνση: ${printer.address}\n', printer));
    bytes.addAll(_encodeText('Ρόλος: ${printer.role.name.toUpperCase()}\n', printer));
    bytes.addAll(_encodeText('Καταχώρηση: ${DateTime.now().toLocal().toString().substring(0, 19)}\n', printer));
    bytes.addAll(_encodeText('$separator\n\n', printer));

    // 6. Footer (Center)
    if (footer.isNotEmpty) {
      bytes.addAll([0x1B, 0x61, 1]); // Center
      bytes.addAll(_encodeText('$footer\n', printer));
    }

    // 7. Feed lines and cut paper
    bytes.addAll([0x1B, 0x64, 4]); // Feed 4 lines
    bytes.addAll([0x1D, 0x56, 66, 0]); // Cut paper

    return bytes;
  }

  /// Compile print job to ESC/POS binary format.
  List<int> _compileEscPosBytes(PrintJob job) {
    final bytes = <int>[];
    final int width = job.printer.paperSize == 58 ? 32 : 48;
    final String separator = '-' * width;

    // 1. Initialize printer
    bytes.addAll([0x1B, 0x40]);
    // 2. Select encoding dynamically
    bytes.addAll(_compileEncodingHeader(job.printer));

    // Determine if this is a reprint early
    bool isReprint = false;
    DateTime? originalTime;
    if (job.items.isNotEmpty) {
      final firstStatus = job.items.first.printStatus;
      if (firstStatus.startsWith('printed_')) {
        final allSameBatch = job.items.every((i) => i.printStatus == firstStatus);
        if (allSameBatch) {
          isReprint = true;
          try {
            originalTime = DateTime.parse(firstStatus.substring(8));
          } catch (_) {}
        }
      }
    }

    // 3. Header (Center)
    if (job.header != null && job.header!.isNotEmpty) {
      bytes.addAll([0x1B, 0x61, 1]); // Center
      bytes.addAll(_encodeText('${job.header}\n\n', job.printer));
    } else {
      bytes.addAll([0x1B, 0x61, 1]); // Center
      bytes.addAll([0x1B, 0x45, 1]); // Bold on
      bytes.addAll(_encodeText('Δελτίο Παραγγελίας\n\n', job.printer));
      bytes.addAll([0x1D, 0x21, 0x00]); // Reset size
      bytes.addAll([0x1B, 0x45, 0]); // Bold off
    }

    // Reprint Banner directly under header
    if (isReprint) {
      bytes.addAll([0x1B, 0x61, 1]); // Center
      bytes.addAll([0x1B, 0x45, 1]); // Bold on
      bytes.addAll(_encodeText('*** ΕΠΑΝΕΚΤΥΠΩΣΗ ***\n', job.printer));
      bytes.addAll([0x1B, 0x45, 0]); // Bold off
    }

    // 4. Header details (Left)
    bytes.addAll([0x1B, 0x61, 0]); // Left
    if (job.printer.paperSize == 58) {
      bytes.addAll(_encodeText('Τραπέζι: ${job.tableName}\n', job.printer));
      bytes.addAll(_encodeText('Σερβιτόρος: ${job.waiterName}\n', job.printer));
      if (isReprint) {
        bytes.addAll(_encodeText('Επανεκτύπωση: ${DateTime.now().toLocal().toString().substring(0, 19)}\n', job.printer));
        if (originalTime != null) {
          bytes.addAll(_encodeText('Καταχώρηση: ${originalTime.toLocal().toString().substring(0, 19)}\n', job.printer));
        }
      } else {
        if (job.timestamp != null) {
          bytes.addAll(_encodeText('Καταχώρηση: ${job.timestamp!.toLocal().toString().substring(0, 19)}\n', job.printer));
        }
      }
    } else {
      bytes.addAll(_encodeText('${_fitLine('Τραπέζι: ${job.tableName}', width)}\n', job.printer));
      bytes.addAll(_encodeText('${_fitLine('Σερβιτόρος: ${job.waiterName}', width)}\n', job.printer));
      if (isReprint) {
        bytes.addAll(_encodeText('${_fitLine('Επανεκτύπωση: ${DateTime.now().toLocal().toString().substring(0, 19)}', width)}\n', job.printer));
        if (originalTime != null) {
          bytes.addAll(_encodeText('${_fitLine('Καταχώρηση: ${originalTime.toLocal().toString().substring(0, 19)}', width)}\n\n', job.printer));
        }
      } else {
        if (job.timestamp != null) {
          bytes.addAll(_encodeText('${_fitLine('Καταχώρηση: ${job.timestamp!.toLocal().toString().substring(0, 19)}', width)}\n', job.printer));
        }
      }
      bytes.addAll(_encodeText('$separator\n', job.printer));
    }

    // 5. Items Header
    final bool isCashier = job.printer.role == PrinterRole.cashier;

    if (job.printer.paperSize == 58) {
      bytes.addAll([0x1B, 0x45, 1]); // Bold
      final int nameWidth = 18;
      final int priceWidth = 6;
      final int qtyWidth = 6;
      final String space = ' ';

      if (isCashier) {
        final col1 = 'Προϊόν'.padRight(nameWidth);
        //final col2 = 'Τιμή'.padLeft(priceWidth);
        final col3 = 'ΤΜΧ'.padLeft(qtyWidth);
        //bytes.addAll(_encodeText('$col1$space$col2$space$col3\n', job.printer));
        bytes.addAll(_encodeText('$col1$space$space$space$space$col3\n', job.printer));
      } else {
        final int kitchenNameWidth = nameWidth + priceWidth + space.length;
        final col1 = 'Προϊόν'.padRight(kitchenNameWidth);
        final col2 = 'ΤΜΧ'.padLeft(qtyWidth);
        bytes.addAll(_encodeText('$col1$space$space$space$col2\n\n', job.printer));
      }
      bytes.addAll([0x1B, 0x45, 0]); // Bold off
    }

    // 6. Items
    for (final item in job.items) {
      if (job.printer.paperSize == 58) {
        final int nameWidth = 18;
        final int priceWidth = 6;
        final int qtyWidth = 6;
        final String space = ' ';

        String line;
        if (isCashier) {
          final rawName = item.productName.length > nameWidth
              ? item.productName.substring(0, nameWidth)
              : item.productName;
          final name = rawName.padRight(nameWidth);
          //final price = item.priceAtOrder.toStringAsFixed(2).padLeft(priceWidth);
          final qty = item.quantity.toString().padLeft(qtyWidth);
          line = '$name$space$space$space$space$space$qty';
        } else {
          bytes.addAll([0x1B, 0x45, 1]); // Bold quantity in kitchen
          final int kitchenNameWidth = nameWidth + priceWidth + space.length;
          final rawName = item.productName.length > kitchenNameWidth
              ? item.productName.substring(0, kitchenNameWidth)
              : item.productName;
          final name = rawName.padRight(kitchenNameWidth);
          final qty = item.quantity.toString().padLeft(qtyWidth);
          line = '$name$space$qty';
        }
        
        bytes.addAll(_encodeText('$line\n', job.printer));
        bytes.addAll([0x1B, 0x45, 0]); // Bold off

        if (item.notes.isNotEmpty) {
          bytes.addAll(_encodeText('  * Σημείωση: ${item.notes}\n', job.printer));
        }
      } else {
        // 80mm formatting
        if (isCashier) {
          // Cashier 80mm layout (48 chars total)
          // 4 spaces inwards -> Name(28) + Price(8) + Qty(8) + "    " = 48
          final price = item.priceAtOrder.toStringAsFixed(2);
          final qty = item.quantity.toString();
          final nameStr = _truncate(item.productName, 28).padRight(28);
          final priceStr = _truncate(price, 8).padLeft(8);
          final qtyStr = _truncate(qty, 8).padLeft(8);
          
          final line = '$nameStr$priceStr$qtyStr    ';
          bytes.addAll(_encodeText('$line\n', job.printer));
        } else {
          // Kitchen 80mm layout (48 chars total)
          // 4 spaces inwards -> Name(36) + Qty(8) + "    " = 48
          final qty = item.quantity.toString();
          final nameStr = _truncate(item.productName, 36).padRight(36);
          final qtyStr = _truncate(qty, 8).padLeft(8);
          
          final line = '$nameStr$qtyStr    ';
          bytes.addAll(_encodeText('$line\n', job.printer));
        }

        if (item.notes.isNotEmpty) {
          bytes.addAll(_encodeText('${_fitLine('  * ${item.notes}', width)}\n', job.printer));
        }
      }
    }

    if (job.printer.paperSize == 80) {
      bytes.addAll(_encodeText('$separator\n', job.printer));

      // 7. Total for cashier (80mm only)
      if (isCashier && job.items.isNotEmpty) {
        final total = job.items.fold<double>(0, (sum, i) => sum + (i.priceAtOrder * i.quantity));
        bytes.addAll([0x1B, 0x45, 1]); // Bold
        final totalLine = _buildRow2('ΣΥΝΟΛΟ', '€${total.toStringAsFixed(2)}', 39, 9);
        bytes.addAll(_encodeText('$totalLine\n', job.printer));
        bytes.addAll([0x1B, 0x45, 0]); // Bold off
      }
    }

    // 8. Footer (Center)
    if (job.footer != null && job.footer!.isNotEmpty) {
      bytes.addAll([0x1B, 0x61, 1]); // Center
      bytes.addAll(_encodeText('\n${job.footer}\n', job.printer));
    }

    // 9. Feed lines and cut paper
    bytes.addAll([0x1B, 0x64, 4]); // Feed 4 lines
    bytes.addAll([0x1D, 0x56, 66, 0]); // Cut paper

    return bytes;
  }

  /// Calculate the "printed width" of a string.
  /// For monospaced thermal printers, each character = 1 column position.
  /// Greek/accented chars still occupy 1 column even though they may be multi-byte in UTF-8.
  int _printedWidth(String text) {
    return text.length; // Each char = 1 column on thermal printer
  }

  /// Truncate a string to fit within maxWidth printed columns.
  String _truncate(String text, int maxWidth) {
    if (text.length <= maxWidth) return text;
    return text.substring(0, maxWidth);
  }

  /// Fit a single text line within the given width, truncating if needed.
  String _fitLine(String text, int width) {
    return _truncate(text, width);
  }

  /// Build a 2-column row: name(left-aligned), col2(right-aligned)
  /// Total must equal col1Width + col2Width = 48
  String _buildRow2(String col1, String col2, int col1Width, int col2Width) {
    final name = _truncate(col1, col1Width).padRight(col1Width);
    final val = _truncate(col2, col2Width).padLeft(col2Width);
    return '$name$val';
  }

  List<int> _compileEncodingHeader(PrinterDevice printer) {
    if (printer.isUtf8) {
      // Set to multi-byte encoding type and set to UTF-8
      return [0x1C, 0x26, 0x1C, 0x43, 0xFF];
    } else if (printer.isCp737) {
      // Set to single-byte encoding type and set to CP737 (Greek CP14)
      return [0x1C, 0x2E, 0x1B, 0x74, 14];
    } else {
      // Fallback/CP1253: Set to single-byte and set to page 14
      return [0x1C, 0x2E, 0x1B, 0x74, 14];
    }
  }

  List<int> _encodeText(String text, PrinterDevice printer) {
    if (printer.isUtf8) {
      return utf8.encode(text);
    } else if (printer.isCp737) {
      return _encodeGreek737(text);
    } else {
      return _encodeGreek1253(text);
    }
  }

  /// Encode text to single-byte Greek CodePage 737 bytes.
  List<int> _encodeGreek737(String text) {
    final result = <int>[];
    for (var i = 0; i < text.length; i++) {
      final charCode = text.codeUnitAt(i);
      if (charCode < 128) {
        result.add(charCode);
      } else {
        if (charCode >= 0x0391 && charCode <= 0x03A9) {
          // Greek Capitals (Α-Ω): U+0391 to U+03A9 -> 0x80 to 0x97
          result.add(charCode - 0x0391 + 0x80);
        } else if (charCode >= 0x03B1 && charCode <= 0x03C8) {
          // Greek Small (α-ψ): U+03B1 to U+03C8 -> 0x98 to 0xAF
          result.add(charCode - 0x03B1 + 0x98);
        } else {
          switch (charCode) {
            case 0x03C9: result.add(0xE0); break; // ω
            case 0x03C2: result.add(0xAA); break; // ς (final sigma)
            case 0x03AC: result.add(0xE1); break; // ά
            case 0x03AD: result.add(0xE2); break; // έ
            case 0x03AE: result.add(0xE3); break; // ή
            case 0x03CA: result.add(0xE4); break; // ϊ
            case 0x03AF: result.add(0xE5); break; // ί
            case 0x03CC: result.add(0xE6); break; // ό
            case 0x03CD: result.add(0xE7); break; // ύ
            case 0x03CB: result.add(0xE8); break; // ϋ
            case 0x03CE: result.add(0xE9); break; // ώ
            case 0x0386: result.add(0xEA); break; // Ά
            case 0x0388: result.add(0xEB); break; // Έ
            case 0x0389: result.add(0xEC); break; // Ή
            case 0x038A: result.add(0xED); break; // Ί
            case 0x038C: result.add(0xEE); break; // Ό
            case 0x038E: result.add(0xEF); break; // Ύ
            case 0x038F: result.add(0xF0); break; // Ώ
            case 0x03AA: result.add(0xF4); break; // Ϊ
            case 0x03AB: result.add(0xF5); break; // Ϋ
            default:
              result.add(0x3F); // '?' for unmapped
          }
        }
      }
    }
    return result;
  }

  /// Encode text to single-byte Greek CodePage 1253 bytes.
  List<int> _encodeGreek1253(String text) {
    final result = <int>[];
    for (var i = 0; i < text.length; i++) {
      final charCode = text.codeUnitAt(i);
      if (charCode < 128) {
        result.add(charCode);
      } else {
        if (charCode >= 0x0391 && charCode <= 0x03A9) {
          // Greek Capitals (Α-Ω)
          result.add(charCode - 0x0391 + 0xC1);
        } else if (charCode >= 0x03B1 && charCode <= 0x03C9) {
          // Greek Small (α-ω)
          result.add(charCode - 0x03B1 + 0xE1);
        } else {
          switch (charCode) {
            case 0x0386: result.add(0xA2); break; // Ά
            case 0x0388: result.add(0xB8); break; // Έ
            case 0x0389: result.add(0xB9); break; // Ή
            case 0x038A: result.add(0xBA); break; // Ί
            case 0x038C: result.add(0xBC); break; // Ό
            case 0x038E: result.add(0xBE); break; // Ύ
            case 0x038F: result.add(0xBF); break; // Ώ
            case 0x03AC: result.add(0xDC); break; // ά
            case 0x03AD: result.add(0xDD); break; // έ
            case 0x03AE: result.add(0xDE); break; // ή
            case 0x03AF: result.add(0xDF); break; // ί
            case 0x03CC: result.add(0xFC); break; // ό
            case 0x03CD: result.add(0xFD); break; // ύ
            case 0x03CE: result.add(0xFE); break; // ώ
            default:
              result.add(0x3F); // '?' for unmapped
          }
        }
      }
    }
    return result;
  }
}
