import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Africasystems RFID Reader',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(title: 'Africasystems RFID Reader'),
    );
  }
}