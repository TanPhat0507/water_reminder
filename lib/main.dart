import 'package:firebase_core/firebase_core.dart';
import 'package:water_reminder/src/pages/login/login_page.dart';
import 'package:water_reminder/src/pages/main/home_page.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:water_reminder/src/pages/root_page.dart';
import 'package:water_reminder/src/pages/main/setting_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Water Reminder',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.blue,
      ),
      home: SettingsScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
