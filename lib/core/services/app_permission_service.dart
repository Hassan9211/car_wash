import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum AppPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
}

class AppPermissionService {
  AppPermissionService._();

  static const MethodChannel _channel = MethodChannel(
    'com.example.car_wash/permissions',
  );

  static Future<AppPermissionStatus> requestGalleryPermission() {
    return _requestPermission('requestGalleryPermission');
  }

  static Future<AppPermissionStatus> requestCameraPermission() {
    return _requestPermission('requestCameraPermission');
  }

  static Future<AppPermissionStatus> requestLocationPermission() {
    return _requestPermission('requestLocationPermission');
  }

  static Future<void> openAppSettings() async {
    if (!_usesNativePermissionBridge) {
      return;
    }

    try {
      await _channel.invokeMethod<void>('openAppSettings');
    } on MissingPluginException {
      // Ignore if the native bridge is unavailable on this platform.
    } on PlatformException {
      // Ignore settings errors and let the UI keep guiding the user.
    }
  }

  static Future<AppPermissionStatus> _requestPermission(String method) async {
    if (!_usesNativePermissionBridge) {
      return AppPermissionStatus.granted;
    }

    try {
      final status = await _channel.invokeMethod<String>(method);
      return _parseStatus(status);
    } on MissingPluginException {
      return AppPermissionStatus.granted;
    } on PlatformException {
      return AppPermissionStatus.denied;
    }
  }

  static AppPermissionStatus _parseStatus(String? status) {
    switch (status) {
      case 'granted':
        return AppPermissionStatus.granted;
      case 'permanentlyDenied':
        return AppPermissionStatus.permanentlyDenied;
      case 'denied':
      default:
        return AppPermissionStatus.denied;
    }
  }

  static bool get _usesNativePermissionBridge {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  }
}
