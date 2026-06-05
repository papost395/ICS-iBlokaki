class DeviceStatus {
  final bool cutterError;
  final bool printerTimeout;
  final bool fiscalFileFullOrClosed;
  final bool printerOffline;
  final bool batteryWarning;
  final bool printerPaperEnd;
  final bool ejReportPrinting;
  final bool deviceBusy;

  DeviceStatus({
    required this.cutterError,
    required this.printerTimeout,
    required this.fiscalFileFullOrClosed,
    required this.printerOffline,
    required this.batteryWarning,
    required this.printerPaperEnd,
    required this.ejReportPrinting,
    required this.deviceBusy,
  });

  factory DeviceStatus.fromHex(String hexString) {
    if (hexString.length != 2) return DeviceStatus.empty();
    final value = int.tryParse(hexString, radix: 16) ?? 0;
    return DeviceStatus(
      deviceBusy: (value & (1 << 0)) != 0,
      ejReportPrinting: (value & (1 << 1)) != 0,
      printerPaperEnd: (value & (1 << 2)) != 0,
      batteryWarning: (value & (1 << 3)) != 0,
      printerOffline: (value & (1 << 4)) != 0,
      fiscalFileFullOrClosed: (value & (1 << 5)) != 0,
      printerTimeout: (value & (1 << 6)) != 0,
      cutterError: (value & (1 << 7)) != 0,
    );
  }

  factory DeviceStatus.empty() {
    return DeviceStatus(
      cutterError: false,
      printerTimeout: false,
      fiscalFileFullOrClosed: false,
      printerOffline: false,
      batteryWarning: false,
      printerPaperEnd: false,
      ejReportPrinting: false,
      deviceBusy: false,
    );
  }
}

class FiscalStatus {
  final bool ejReportOpen;
  final bool cashOutIsOpen;
  final bool cashInIsOpen;
  final bool transactionInPayment;
  final bool transactionOpen;
  final bool dayIsOpen;
  final bool drawerIsOpen;

  FiscalStatus({
    required this.ejReportOpen,
    required this.cashOutIsOpen,
    required this.cashInIsOpen,
    required this.transactionInPayment,
    required this.transactionOpen,
    required this.dayIsOpen,
    required this.drawerIsOpen,
  });

  factory FiscalStatus.fromHex(String hexString) {
    if (hexString.length != 2) return FiscalStatus.empty();
    final value = int.tryParse(hexString, radix: 16) ?? 0;
    return FiscalStatus(
      drawerIsOpen: (value & (1 << 0)) != 0,
      dayIsOpen: (value & (1 << 1)) != 0,
      transactionOpen: (value & (1 << 2)) != 0,
      transactionInPayment: (value & (1 << 4)) != 0,
      cashInIsOpen: (value & (1 << 5)) != 0,
      cashOutIsOpen: (value & (1 << 6)) != 0,
      ejReportOpen: (value & (1 << 7)) != 0,
    );
  }

  factory FiscalStatus.empty() {
    return FiscalStatus(
      ejReportOpen: false,
      cashOutIsOpen: false,
      cashInIsOpen: false,
      transactionInPayment: false,
      transactionOpen: false,
      dayIsOpen: false,
      drawerIsOpen: false,
    );
  }
}

class MatStatus {
  final DeviceStatus deviceStatus;
  final FiscalStatus fiscalStatus;

  MatStatus({
    required this.deviceStatus,
    required this.fiscalStatus,
  });

  factory MatStatus.fromString(String statusString) {
    // Expected length 4 for two 2-digit hex values, e.g. "4116"
    // But the protocol says status is a section consisting of two numeric 2-character hexadecimal fields
    // "Device status Fiscal status", e.g. "4116" or separated? PDF says "Status is a section consisting of two numeric 2-character hexadecimal fields".
    if (statusString.length < 4) {
      return MatStatus(
        deviceStatus: DeviceStatus.empty(),
        fiscalStatus: FiscalStatus.empty(),
      );
    }
    
    return MatStatus(
      deviceStatus: DeviceStatus.fromHex(statusString.substring(0, 2)),
      fiscalStatus: FiscalStatus.fromHex(statusString.substring(2, 4)),
    );
  }
}
