import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:ternakami/screens/login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final screenWidth = mediaQueryData.size.width;
    final screenHeight = mediaQueryData.size.height;

    return Scaffold(
      body: IntroductionScreen(
        pages: [
          PageViewModel(
            title: "Selamat Datang!",
            body:
                "Aplikasi Pendeteksi Penyakit Mata Pink Eye pada Hewan Kambing!",
            image: Center(
              child: Image.asset(
                'assets/gambar/logo.png',
                height: screenHeight * 0.3,
              ),
            ),
            decoration: PageDecoration(
              pageColor: Colors.white,
              titleTextStyle: TextStyle(
                color: Colors.black,
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
              ),
              bodyTextStyle: TextStyle(
                color: Colors.black,
                fontSize: screenWidth * 0.04,
              ),
              imagePadding: EdgeInsets.all(screenWidth * 0.05),
            ),
          ),
          PageViewModel(
            title: "Fitur",
            body:
                "Prediksi mata kambing dengan fitur Scan, lihat riwayat prediksi, dan baca artikel tentang pink eye.",
            image: Center(
              child: Image.asset(
                'assets/gambar/onboarding2.png',
                height: screenHeight * 0.3,
              ),
            ),
            decoration: PageDecoration(
              pageColor: Colors.white,
              titleTextStyle: TextStyle(
                color: Colors.black,
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
              ),
              bodyTextStyle: TextStyle(
                color: Colors.black,
                fontSize: screenWidth * 0.04,
              ),
              imagePadding: EdgeInsets.all(screenWidth * 0.05),
            ),
          ),
          PageViewModel(
            title: "Ayo Mulai!",
            body: "Mari jelajahi aplikasi ini!",
            image: Center(
              child: Image.asset(
                'assets/gambar/logo.png',
                height: screenHeight * 0.3,
              ),
            ),
            decoration: PageDecoration(
              pageColor: Colors.white,
              titleTextStyle: TextStyle(
                color: Colors.black,
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
              ),
              bodyTextStyle: TextStyle(
                color: Colors.black,
                fontSize: screenWidth * 0.04,
              ),
              imagePadding: EdgeInsets.all(screenWidth * 0.05),
            ),
          ),
        ],
        onDone: () {
          // Navigate to the login screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        },
        showSkipButton: true,
        skip: const Text("Skip", style: TextStyle(color: Colors.blue)),
        next: const Icon(Icons.arrow_forward, color: Colors.blue),
        done: const Text("Done",
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue)),
        dotsDecorator: DotsDecorator(
          size: Size.square(screenWidth * 0.025),
          activeSize: Size(screenWidth * 0.05, screenWidth * 0.025),
          activeColor: Theme.of(context).colorScheme.secondary,
          color: Colors.blue,
          spacing: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.05),
          ),
        ),
      ),
    );
  }
}
