// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:logging/logging.dart';
import 'package:ternakami/screens/onboarding_screen.dart';
import 'package:ternakami/screens/login_screen.dart';
import 'package:ternakami/screens/home_screen.dart';
import 'package:ternakami/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  Future<bool> hasSeenOnboarding() async {
    final logger = Logger('SplashScreen');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
    logger.info('Has seen onboarding: $seenOnboarding');
    return seenOnboarding;
  }

  Future<bool> validateToken() async {
    final logger = Logger('SplashScreen');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      logger.warning('Token not found');
      return false;
    }
    logger.info('Found token: $token');
    ApiService apiService = ApiService();
    bool isValid = await apiService.validateToken(token);
    logger.info('Token is valid: $isValid');
    return isValid;
  }

  Route createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlutterSplashScreen.fadeIn(
      backgroundColor: Colors.blue,
      onInit: () {},
      onEnd: () {},
      childWidget: SizedBox(
        height: 250,
        width: 250,
        child: Image.asset("assets/gambar/logo.png"),
      ),
      onAnimationEnd: () async {
        final logger = Logger('SplashScreen');
        logger.info('Splash screen animation ended');

        bool seenOnboarding = await hasSeenOnboarding();
        bool tokenValid = await validateToken();

        if (!seenOnboarding) {
          logger.info('Navigating to OnboardingScreen');
          Navigator.of(context)
              .pushReplacement(createRoute(const OnboardingScreen()));
        } else if (tokenValid) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String fullname = prefs.getString('fullname') ?? '';
          int userid = prefs.getInt('userid') ?? 0;
          String email = prefs.getString('email') ?? '';
          String token = prefs.getString('token') ?? '';

          logger.info('Navigating to HomeScreen');
          Navigator.of(context).pushReplacement(
            createRoute(HomeScreen(
              token: token,
              fullname: fullname,
              userid: userid,
              email: email,
            )),
          );
        } else {
          logger.info('Navigating to LoginScreen');
          Navigator.of(context)
              .pushReplacement(createRoute(const LoginScreen()));
        }
      },
    );
  }
}
