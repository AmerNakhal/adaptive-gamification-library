import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const AdaptiveMathApp());
}

class AdaptiveMathApp extends StatelessWidget {
  const AdaptiveMathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adaptive Math Quiz',
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
