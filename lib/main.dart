import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MedisimbioApp());
}

class MedisimbioApp extends StatelessWidget {
  const MedisimbioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medisimbio',

      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B7A6E),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FCFA),
      ),

      // First screen
      home: const SplashScreen(),
    );
  }
}
