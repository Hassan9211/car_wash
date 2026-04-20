import 'dart:io';

import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class IdCardService {
  IdCardService._();

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

  /// Restores ID card data from Firestore.
  static Future<void> restore() async {
    final uid = AuthSession.currentUserId;
    if (uid == null || uid.isEmpty) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('id_card')
          .doc('data')
          .get();
      if (!doc.exists) return;
      final data = doc.data()!;
      _imagePath = data['image_url'] as String?;
      final expiryStr = data['expiry_date'] as String?;
      _expiryDate = expiryStr != null ? DateTime.tryParse(expiryStr) : null;
    } catch (_) {}
  }

  /// Uploads ID card image to Firebase Storage and saves metadata to Firestore.
  static Future<void> save({
    required String imagePath,
    required DateTime expiryDate,
  }) async {
    _expiryDate = expiryDate;

    final uid = AuthSession.currentUserId;
    String imageUrl = imagePath;

    // Upload to Firebase Storage if it's a local file
    if (uid != null && uid.isNotEmpty && !imagePath.startsWith('http')) {
      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('id_cards/$uid/id_card.jpg');
        await ref.putFile(File(imagePath));
        imageUrl = await ref.getDownloadURL();
      } catch (_) {
        imageUrl = imagePath; // fallback to local path
      }
    }

    _imagePath = imageUrl;

    // Save to Firestore
    if (uid != null && uid.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('id_card')
            .doc('data')
            .set({
          'image_url': imageUrl,
          'expiry_date': expiryDate.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (_) {}
    }
  }

  static Future<void> clear() async {
    _imagePath = null;
    _expiryDate = null;
    final uid = AuthSession.currentUserId;
    if (uid != null && uid.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('id_card')
            .doc('data')
            .delete();
      } catch (_) {}
    }
  }
}
