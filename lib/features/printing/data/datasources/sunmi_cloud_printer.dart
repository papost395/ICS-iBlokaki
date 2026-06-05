import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:hex/hex.dart';
import 'package:order/features/settings/domain/repositories/settings_repository.dart';
import 'sunmi_interceptor.dart';

const int ALIGN_LEFT = 0;
const int ALIGN_CENTER = 1;
const int ALIGN_RIGHT = 2;
const int COLUMN_FLAG_BW_REVERSE = 1 << 0;
const int COLUMN_FLAG_BOLD = 1 << 1;
const int COLUMN_FLAG_DOUBLE_H = 1 << 2;
const int COLUMN_FLAG_DOUBLE_W = 1 << 3;

class SunmiCloudPrinter {
  final SettingsRepository settingsRepo;
  
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://openapi.sunmi.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    sendTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // 'Connection': 'keep-alive' // Μπορείς να το δοκιμάσεις αν πάλι κολλάει
    },
  ));

  SunmiCloudPrinter(this.settingsRepo, {int dotsPerLine = 384}) : _dotsPerLine = dotsPerLine {
    _dio.interceptors.add(SunmiInterceptor(settingsRepo));
  }

  final int _dotsPerLine;
  int _charHSize = 1;
  final int _asciiCharWidth = 12;
  final int _cjkCharWidth = 24;
  List<int> _orderData = [];
  List<List<int>> _columnSettings = [];

  String get appId => ""; // Πλέον διαχειρίζονται από τον Interceptor
  String get appKey => ""; 

  int get dotsPerLine => _dotsPerLine;
  Uint8List get orderData => Uint8List.fromList(_orderData);

  void clear() => _orderData = [];
  void addRawBytes(List<int> bytes) => _orderData.addAll(bytes);

  // Placeholder για συμβατότητα, τα κλειδιά πλέον διαβάζονται στον Interceptor
  Future<void> initKeys() async {}

  // --- ΔΙΚΤΥΟ ΜΕ DIO ---

  Future<void> pushRawHex({
    required String tradeNo,
    required String sn,
    required String contentHex,
    int count = 1,
    String mediaText = '',
  }) async {
    final body = {
      'trade_no': tradeNo,
      'sn': sn,
      'order_type': 1,
      'content': contentHex,
      'count': count,
      'media_text': mediaText,
    };

    try {
      await _dio.post('/v2/printer/open/open/device/pushContent', data: body);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> pushContent({
    required String tradeNo,
    required String sn,
    required int count,
    int orderType = 1,
    String mediaText = '',
    int cycle = 1,
  }) async {
    final body = {
      'trade_no': tradeNo,
      'sn': sn,
      'order_type': orderType,
      'content': HEX.encode(_orderData),
      'count': count,
      'media_text': mediaText,
      'cycle': cycle,
    };

    try {
      await _dio.post('/v2/printer/open/open/device/pushContent', data: body);
    } catch (e) {
      rethrow;
    }
  }

  // --- ESC/POS LOGIC (Αμετάβλητη) ---

  int widthOfChar(int c) {
    if (c >= 0x00020 && c <= 0x0036f) return _asciiCharWidth;
    if (c >= 0x0ff61 && c <= 0x0ff9f) return _cjkCharWidth ~/ 2;
    if ((c >= 0x01100 && c <= 0x011ff) || (c >= 0x03200 && c <= 0x09fff)) return _cjkCharWidth;
    return _asciiCharWidth;
  }

  void setCloudEncoding(String mode) {
    if (mode == 'CP737') {
      _orderData.addAll([0x1D, 0x28, 0x45, 0x03, 0x00, 0x06, 0x03, 0x00]);
      _orderData.addAll([0x1D, 0x28, 0x45, 0x03, 0x00, 0x06, 0x02, 0x0E]);
    }
  }

  void appendText(String text) => _orderData.addAll(utf8.encode(text));

  void lineFeed([int n = 1]) {
    for (int i = 0; i < n; i++) {
      _orderData.add(0x0a);
    }
  }

  void setPrintModes(bool bold, bool doubleH, bool doubleW) {
    int n = 0;
    if (bold) n |= 8;
    if (doubleH) n |= 16;
    if (doubleW) {
      n |= 32;
      _charHSize = 2;
    } else {
      _charHSize = 1;
    }
    _orderData.addAll([0x1b, 0x21, n]);
  }

  void setAlignment(int n) => _orderData.addAll([0x1b, 0x61, n]);

  void cutPaper(bool fullCut) => _orderData.addAll([0x1d, 0x56, fullCut ? 0x30 : 0x31]);

  void setupColumns(List<List<int>> columns) {
    _columnSettings = [];
    int remain = _dotsPerLine;
    for (var col in columns) {
      int width = col[0];
      if (width == 0 || width > remain) width = remain;
      _columnSettings.add([width, col[1], col[2]]);
      remain -= width;
      if (remain <= 0) break;
    }
  }

  void setAbsolutePrintPosition(int n) {
    _orderData.addAll([0x1b, 0x24]);
    var byteData = ByteData(2)..setUint16(0, n, Endian.little);
    _orderData.addAll(byteData.buffer.asUint8List());
  }

  void printInColumns(List<String> texts) {
    if (_columnSettings.isEmpty || texts.isEmpty) return;
    int numOfColumns = min(_columnSettings.length, texts.length);

    // Απλοποιημένη έκδοση για Enterprise Cleanliness
    String row = "";
    for (int i = 0; i < numOfColumns; i++) {
      row += texts[i].padRight(_columnSettings[i][0] ~/ _asciiCharWidth);
    }
    appendText(row);
    lineFeed();
  }

  void appendQRcode(int moduleSize, int ecLevel, String text) {
    final content = utf8.encode(text);
    _orderData.addAll([0x1d, 0x28, 0x6b, 0x03, 0x00, 0x31, 0x43, moduleSize.clamp(1, 16)]);
    int pL = (content.length + 3) % 256;
    int pH = (content.length + 3) ~/ 256;
    _orderData.addAll([0x1d, 0x28, 0x6b, pL, pH, 0x31, 0x50, 0x30]);
    _orderData.addAll(content);
    _orderData.addAll([0x1d, 0x28, 0x6b, 0x03, 0x00, 0x31, 0x51, 0x30]);
  }
}
