import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  GoogleAuthService._();

  static final _googleSignIn = GoogleSignIn();

  /// Signs in with Google and returns the Firebase [User] on success.
  /// Returns null if the user cancelled or an error occurred.
  static Future<User?> signIn() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // user cancelled

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    final user = userCredential.user;
    if (user != null) {
      AuthSession.setCurrentUser(
        email: user.email ?? '',
        userId: user.uid,
        name: user.displayName,
      );
      AuthSession.setAuthenticated(true);
    }

    return user;
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
  }
}
