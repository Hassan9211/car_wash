import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Syncs user profile data to/from Firestore `users` collection.
class UserProfileService {
  UserProfileService._();

  static const _collection = 'users';

  /// Saves current AuthSession data to Firestore.
  static Future<void> saveProfile() async {
    final uid = AuthSession.currentUserId;
    if (uid == null || uid.isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection(_collection).doc(uid).set({
        'name': AuthSession.displayName,
        'email': AuthSession.displayEmail,
        'phone_number': AuthSession.displayPhoneNumber,
        'location_label': AuthSession.displayLocationLabel,
        'latitude': AuthSession.currentLatitude,
        'longitude': AuthSession.currentLongitude,
        'role': AuthSession.currentRole?.name,
        'updated_at': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  /// Restores user profile from Firestore into AuthSession.
  static Future<void> restoreProfile(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(_collection)
          .doc(uid)
          .get();

      if (!doc.exists) return;
      final data = doc.data()!;

      final name = (data['name'] as String?)?.trim();
      final phone = (data['phone_number'] as String?)?.trim();
      final location = (data['location_label'] as String?)?.trim();
      final lat = (data['latitude'] as num?)?.toDouble();
      final lng = (data['longitude'] as num?)?.toDouble();

      if (name != null && name.isNotEmpty) AuthSession.setCurrentName(name);
      if (phone != null && phone.isNotEmpty) {
        AuthSession.setCurrentUser(
          email: AuthSession.displayEmail,
          userId: uid,
          name: name,
          phoneNumber: phone,
        );
      }
      if (location != null && location.isNotEmpty && lat != null && lng != null) {
        AuthSession.updateCurrentLocation(
          latitude: lat,
          longitude: lng,
          label: location,
        );
      }
    } catch (_) {}
  }
}
