import 'package:car_wash/app.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthSession.restore();
  runApp(const MyApp());
}
