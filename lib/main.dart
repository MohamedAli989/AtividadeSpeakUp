// lib/main.dart
import 'package:flutter/material.dart';
import 'package:pprincipal/screens/splash_screen.dart'; // Mude 'pprincipal' para o nome do seu projeto

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpeakUp App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // O ponto de entrada do app agora é a nossa SplashScreen
      home: const SplashScreen(),
    );
  }
}
