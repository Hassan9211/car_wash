import 'package:car_wash/app.dart';
import 'package:car_wash/core/services/app_notification_service.dart';
import 'package:car_wash/core/services/id_card_service.dart';
import 'package:car_wash/core/services/stripe_service.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  StripeService.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Enable Firestore offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  await AppNotificationService.initialize();
  await AuthSession.restore();
  await IdCardService.restore();
  runApp(const MyApp());
}
