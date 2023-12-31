//login_screen.dart
import 'package:flutter/material.dart';
import '../api/auth_api.dart';
import 'homepage_screen.dart';
import './register_screen.dart';

class LoginScreen extends StatelessWidget {
  final AuthApi authApi = AuthApi();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding:
            const EdgeInsets.all(16.0), // Add padding for aesthetic spacing
        child: Column(
          mainAxisAlignment: MainAxisAlignment
              .center, // Center the column for better aesthetics
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 8), // Add space between the text fields
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(
                height: 24), // Add space between the button and text fields
            ElevatedButton(
              onPressed: () {
                _handleLogin(context);
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 12), // Space before the text button
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: const Text('Don\'t have an account? Register'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogin(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Please enter both email and password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final user = await authApi.login(email, password);
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomepageScreen(user: user)),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Login Failed: Invalid email or password'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
