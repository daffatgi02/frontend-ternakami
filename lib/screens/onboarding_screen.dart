// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ternakami/screens/login_screen.dart';

// Model for OnBoard data
class OnBoard {
  final String image;
  final String title;
  final String description;

  OnBoard(
      {required this.image, required this.title, required this.description});
}

// message data for onboarding
final List<OnBoard> messageData = [
  OnBoard(
    image: 'assets/gambar/onboarding1.png',
    title: "Selamat Datang di Aplikasi Ternakami",
    description:
        "Aplikasi Pendeteksi Penyakit Mata Pink Eye pada Hewan Kambing!",
  ),
  OnBoard(
    image: 'assets/gambar/onboarding2.png',
    title: "Fitur",
    description:
        "Gunakan aplikasi ini untuk memprediksi mata kambing dengan fitur Scan, melihat riwayat prediksi kambing, dan membaca artikel tentang pink eye.",
  ),
  OnBoard(
    image: 'assets/gambar/onboarding3.png',
    title: "Ayo Mulai!",
    description: "",
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      currentPage = page;
    });
    _animationController.forward(from: 0.0);
  }

  void _onSkip() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _onNext() {
    if (_pageController.page == messageData.length - 1) {
      _onSkip();
    } else {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  Widget _buildPageContent(
      {required String title,
      required String body,
      required String imagePath}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Image.asset(imagePath),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          body,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: messageData.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              return _buildPageContent(
                title: messageData[index].title,
                body: messageData[index].description,
                imagePath: messageData[index].image,
              );
            },
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: TextButton(
              onPressed: _onSkip,
              child: const Text('Skip', style: TextStyle(color: Colors.blue)),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: TextButton(
              onPressed: _onNext,
              child: const Text('Next', style: TextStyle(color: Colors.blue)),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                messageData.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 5,
                  width: currentPage == index ? 15 : 5,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: currentPage == index ? Colors.blue : Colors.grey,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
