import 'package:flutter/material.dart';
import 'package:ternakami/screens/prediction_screen.dart';
import 'package:ternakami/screens/history_screen.dart';

class HomeScreen extends StatelessWidget {
  final String token;

  const HomeScreen({Key? key, required this.token}) : super(key: key);

  void navigateToPrediction(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PredictionScreen(token: token)),
    );
  }

  void navigateToHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HistoryScreen(token: token)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => navigateToPrediction(context),
              child: const Text('Predict Animal Eye'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => navigateToHistory(context),
              child: const Text('My History'),
            ),
          ],
        ),
      ),
    );
  }
}
