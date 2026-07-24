import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const EncantarioApp());
}

class EncantarioApp extends StatelessWidget {
  const EncantarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Encantario - Capítulo Uno',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
