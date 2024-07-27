// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ternakami/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart'; // Import Cupertino package

void main() => runApp(const OnboardingApp());

class OnboardingApp extends StatelessWidget {
  const OnboardingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: OnboardingScreen(),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  Future<void> completeOnboarding(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final screenWidth = mediaQueryData.size.width;
    final screenHeight = mediaQueryData.size.height;

    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPageIndex = index;
              });
            },
            children: [
              buildPage(
                screenWidth,
                screenHeight,
                "Selamat Datang!",
                "Aplikasi Pendeteksi Penyakit Mata Pink Eye pada Hewan Kambing!",
                'assets/gambar/onboarding1.png',
              ),
              buildPage(
                screenWidth,
                screenHeight,
                "Fitur",
                "Prediksi mata kambing dengan fitur Scan, lihat riwayat prediksi, dan baca artikel tentang pink eye.",
                'assets/gambar/onboarding2.png',
              ),
              buildPage(
                screenWidth,
                screenHeight,
                "Ayo Mulai!",
                "Mari jelajahi aplikasi ini!",
                'assets/gambar/onboarding3.png',
              ),
            ],
          ),
          Positioned(
            bottom: 100, // Menyesuaikan posisi ke atas
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPageIndex == index ? 12 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color:
                        _currentPageIndex == index ? Colors.blue : Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
          if (_currentPageIndex < 2)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      _pageController.animateToPage(
                        2,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    },
                    child: const Text(
                      "Lewati",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    },
                    child: const Text(
                      "Lanjutkan",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          if (_currentPageIndex == 2)
            Positioned(
              bottom: 20,
              right: 20,
              child: TextButton(
                onPressed: () => completeOnboarding(context),
                child: const Text(
                  "Selesai",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildPage(
    double screenWidth,
    double screenHeight,
    String title,
    String body,
    String imagePath,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: screenHeight * 0.3,
          ),
          SizedBox(height: screenHeight * 0.05),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.blue,
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            body,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: const Color.fromARGB(255, 152, 150, 150),
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
