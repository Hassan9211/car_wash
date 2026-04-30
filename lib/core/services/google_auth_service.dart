import 'package:car_wash/core/services/user_profile_service.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:car_wash/features/authentication/model/app_user_role.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  GoogleAuthService._();

  static final _googleSignIn = GoogleSignIn();

  /// Shows account picker every time and signs in with Google.
  /// Returns the Firebase [User] on success, null if cancelled.
  static Future<User?> signIn() async {
    try {
      // Sign out first so account chooser always appears
      await _googleSignIn.signOut();

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // user cancelled

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      final user = userCredential.user;
      if (user != null) {
        AuthSession.setCurrentUser(
          email: user.email ?? '',
          userId: user.uid,
          name: user.displayName,
        );
        AuthSession.setAuthenticated(true);

        // Restore any saved profile data from Firestore (with timeout)
        try {
          await UserProfileService.restoreProfile(user.uid)
              .timeout(const Duration(seconds: 5));
        } catch (_) {}

        // If role not set, default to customer
        if (AuthSession.currentRole == null ||
            AuthSession.currentRole == AppUserRole.guest) {
          AuthSession.setCurrentRole(AppUserRole.customer);
        }

        // Check if provider setup is already done in Firestore
        if (AuthSession.currentRole == AppUserRole.serviceProvider &&
            !AuthSession.isProviderSetupCompleted) {
          try {
            final doc = await FirebaseFirestore.instance
                .collection('providers')
                .doc(user.uid)
                .get()
                .timeout(const Duration(seconds: 5));
            if (doc.exists) {
              AuthSession.setProviderSetupCompleted(true);
            }
          } catch (_) {}
        }

        // Save/update profile in Firestore (with timeout)
        try {
          await UserProfileService.saveProfile()
              .timeout(const Duration(seconds: 5));
        } catch (_) {}
      }

      return user;
    } catch (error, stackTrace) {
      debugPrint('GoogleAuthService.signIn failure: $error');
      debugPrint('$stackTrace');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
  }
}
