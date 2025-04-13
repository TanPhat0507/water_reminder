import 'package:flutter/material.dart';
import 'package:water_reminder/src/root_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Water Reminder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  RootPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

