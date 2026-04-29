import 'package:car_wash/app.dart';
import 'package:car_wash/core/services/app_notification_service.dart';
import 'package:car_wash/core/services/id_card_service.dart';
import 'package:car_wash/core/services/stripe_service.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppInitializer());
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _initialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await dotenv.load(fileName: '.env');
      StripeService.initialize();

      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      await AppNotificationService.initialize();
      await AuthSession.restore();
      await IdCardService.restore();

      if (!mounted) return;
      setState(() => _initialized = true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _hasError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Failed to start app. Restart and try again.'),
          ),
        ),
      );
    }

    if (!_initialized) {
      return const MaterialApp(
        home: Scaffold(
          backgroundColor: Color(0xFF031008),
          body: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    return const MyApp();
  }
}
