//homepage_screen.dart
import 'package:flutter/material.dart';
import '../models/user.dart';

class HomepageScreen extends StatelessWidget {
  final User user;

  const HomepageScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Homepage')),
      body: Center(
        child: Text('Welcome, ${user.fullname}'),
      ),
    );
  }
}
