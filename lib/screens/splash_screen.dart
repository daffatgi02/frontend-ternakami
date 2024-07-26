// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:ternakami/screens/onboarding_screen.dart';
import 'package:ternakami/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart'; // Import Cupertino package

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  Future<bool> hasSeenOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
    print('Has seen onboarding (SplashScreen): $seenOnboarding');
    return seenOnboarding;
  }

  @override
  Widget build(BuildContext context) {
    return FlutterSplashScreen.fadeIn(
      backgroundColor: Colors.white,
      onInit: () {},
      onEnd: () {},
      childWidget: SizedBox(
        height: 200,
        width: 200,
        child: Image.asset("assets/gambar/logo.png"),
      ),
      onAnimationEnd: () async {
        bool seenOnboarding = await hasSeenOnboarding();
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (context) =>
                seenOnboarding ? const LoginScreen() : const OnboardingScreen(),
          ),
        );
      },
    );
  }
}
