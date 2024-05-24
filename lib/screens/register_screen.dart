import 'package:flutter/material.dart';
import 'package:ternakami/services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullnameController = TextEditingController();
  final ApiService apiService = ApiService();

  void register() async {
    final email = emailController.text;
    final password = passwordController.text;
    final fullname = fullnameController.text;

    final result = await apiService.register(email, password, fullname);
    if (result) {
      // Registration success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Successful Account Registration. Please Log In")),
      );
      Navigator.pop(context);
    } else {
      // Handle registration error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email already taken or other error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: fullnameController,
              decoration: const InputDecoration(labelText: 'Fullname'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: register,
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
