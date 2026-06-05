import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:order/features/settings/domain/repositories/settings_repository.dart';

class SunmiInterceptor extends Interceptor {
  final SettingsRepository settingsRepo;
  SunmiInterceptor(this.settingsRepo);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final keys = await settingsRepo.getCloudKeys();
    
    final String appId = keys['appId'] ?? '';
    final String appKey = keys['appKey'] ?? '';
    final String timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    final String nonce = Random().nextInt(1000000).toString().padLeft(6, '0');
    
    // Μετατροπή του body σε String για την υπογραφή
    String bodyData = "";
    if (options.data != null) {
      bodyData = jsonEncode(options.data);
    }

    // Υπολογισμός Signature (SHA256)
    final msg = bodyData + appId + timestamp + nonce;
    final hmacSha256 = crypto.Hmac(crypto.sha256, utf8.encode(appKey));
    final sign = hmacSha256.convert(utf8.encode(msg)).toString();

    // Αυτόματη προσθήκη Headers σε ΚΑΘΕ κλήση
    options.headers.addAll({
      'Sunmi-Appid': appId,
      'Sunmi-Timestamp': timestamp,
      'Sunmi-Nonce': nonce,
      'Sunmi-Sign': sign,
      'Source': 'openapi',
      'Content-Type': 'application/json',
    });

    return handler.next(options);
  }
}
