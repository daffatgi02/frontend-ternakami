import 'package:flutter/material.dart';
import 'package:ternakami/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    _animationController.forward(from: 0.0);
  }

  void _onSkip() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _onNext() {
    if (_pageController.page == 2) {
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
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: [
              _buildPageContent(
                title: 'Welcome',
                body:
                    'Welcome to our application. This is the first page of onboarding.',
                imagePath: 'assets/gambar/onboarding1.png',
              ),
              _buildPageContent(
                title: 'Features',
                body: 'Here are some of the features of our application.',
                imagePath: 'assets/gambar/onboarding2.png',
              ),
              _buildPageContent(
                title: 'Get Started',
                body: 'Let\'s get started!',
                imagePath: 'assets/gambar/onboarding3.png',
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: TextButton(
              onPressed: _onSkip,
              child: const Text('Skip'),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: TextButton(
              onPressed: _onNext,
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }
}
