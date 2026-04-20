import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  FirebaseStorageService._();

  /// Uploads avatar image and returns download URL.
  static Future<String?> uploadAvatar(String uid, String localPath) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('avatars/$uid/avatar.jpg');
      await ref.putFile(File(localPath));
      return await ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }

  /// Uploads a work photo and returns download URL.
  static Future<String?> uploadWorkPhoto(
      String orderId, String localPath, int index) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('work_photos/$orderId/photo_$index.jpg');
      await ref.putFile(File(localPath));
      return await ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }

  /// Uploads multiple work photos and returns list of download URLs.
  static Future<List<String>> uploadWorkPhotos(
      String orderId, List<String> localPaths) async {
    final urls = <String>[];
    for (var i = 0; i < localPaths.length; i++) {
      final url = await uploadWorkPhoto(orderId, localPaths[i], i);
      urls.add(url ?? localPaths[i]); // fallback to local path
    }
    return urls;
  }
}
