import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class IdCardService {
  IdCardService._();

  static const _prefsKey = 'id_card_service.data';

  static String? _imagePath;
  static DateTime? _expiryDate;

  static String? get imagePath => _imagePath;
  static DateTime? get expiryDate => _expiryDate;

  static bool get isExpired {
    final expiry = _expiryDate;
    if (expiry == null) return false;
    return DateTime.now().isAfter(expiry);
  }

  static bool get hasIdCard =>
      _imagePath != null && _imagePath!.trim().isNotEmpty;

  static Future<void> restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      _imagePath = json['image_path'] as String?;
      final expiryMs = json['expiry_ms'] as int?;
      _expiryDate =
          expiryMs != null ? DateTime.fromMillisecondsSinceEpoch(expiryMs) : null;
    } catch (_) {}
  }

  static Future<void> save({
    required String imagePath,
    required DateTime expiryDate,
  }) async {
    _imagePath = imagePath;
    _expiryDate = expiryDate;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsKey,
        jsonEncode({
          'image_path': imagePath,
          'expiry_ms': expiryDate.millisecondsSinceEpoch,
        }),
      );
    } catch (_) {}
  }

  static Future<void> clear() async {
    _imagePath = null;
    _expiryDate = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
    } catch (_) {}
  }
}
