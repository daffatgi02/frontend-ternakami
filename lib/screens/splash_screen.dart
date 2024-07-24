import 'package:flutter/material.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:ternakami/screens/onboarding_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

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
      onAnimationEnd: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      },
    );
  }
}
