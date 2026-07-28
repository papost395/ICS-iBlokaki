import 'package:freezed_annotation/freezed_annotation.dart';

part 'printer_device.freezed.dart';
part 'printer_device.g.dart';

enum ConnectionType {
  @JsonValue('network')
  network,
  @JsonValue('bluetooth')
  bluetooth,
  @JsonValue('cloud')
  cloud,
}

enum PrinterRole {
  @JsonValue('cashier')
  cashier,
  @JsonValue('kitchen')
  kitchen,
  @JsonValue('bar')
  bar,
}

@freezed
abstract class PrinterDevice with _$PrinterDevice {
  const factory PrinterDevice({
    required String id,
    required String shopId,
    required String name,
    required ConnectionType connectionType,
    required String address,
    required PrinterRole role,
    @Default(false) bool isUtf8,
    @Default(false) bool isCp737,
    @Default(80) int paperSize,
    @Default(false) bool isDoubleSize,
    @Default(false) bool isExtraBold,
  }) = _PrinterDevice;

  factory PrinterDevice.fromJson(Map<String, dynamic> json) =>
      _$PrinterDeviceFromJson(json);
}
