import 'package:flutter/material.dart';
import 'package:ternakami/screens/login_screen.dart';
import 'package:ternakami/screens/onboarding_screen.dart';
import 'package:ternakami/screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Future<bool> hasSeenOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
    print('Has seen onboarding: $seenOnboarding');
    return seenOnboarding;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blue,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.blue,
          textTheme: ButtonTextTheme.primary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue, // foreground (text) color
          ),
        ),
      ),
      home: FutureBuilder<bool>(
        future: hasSeenOnboarding(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          } else {
            if (snapshot.data == true) {
              return const LoginScreen();
            } else {
              return const OnboardingScreen();
            }
          }
        },
      ),
    );
  }
}
