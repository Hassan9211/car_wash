import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationPreferencesService {
  NotificationPreferencesService._();

  static Future<void> save({
    required bool pushEnabled,
    required bool mailEnabled,
  }) async {
    final uid = AuthSession.currentUserId;
    if (uid == null || uid.isEmpty) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({
        'preferences': {
          'push_notifications': pushEnabled,
          'mail_notifications': mailEnabled,
        },
        'updated_at': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  static Future<Map<String, bool>> restore() async {
    final uid = AuthSession.currentUserId;
    if (uid == null || uid.isEmpty) {
      return {'push': true, 'mail': true};
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (!doc.exists) return {'push': true, 'mail': true};
      final prefs = doc.data()?['preferences'] as Map<String, dynamic>?;
      return {
        'push': (prefs?['push_notifications'] as bool?) ?? true,
        'mail': (prefs?['mail_notifications'] as bool?) ?? true,
      };
    } catch (_) {
      return {'push': true, 'mail': true};
    }
  }
}
