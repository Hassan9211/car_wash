import 'package:flutter/services.dart';

class AppMapsConfigService {
  AppMapsConfigService._();

  static const MethodChannel _channel = MethodChannel(
    'com.example.car_wash/maps_config',
  );

  static Future<bool> hasUsableGoogleMapsApiKey() async {
    try {
      final isConfigured = await _channel.invokeMethod<bool>(
        'hasUsableGoogleMapsApiKey',
      );
      return isConfigured ?? false;
    } catch (_) {
      // If native inspection is unavailable, keep the map path enabled.
      return true;
    }
  }
}
