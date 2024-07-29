// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ternakami/screens/register_screen.dart';
import 'package:ternakami/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'package:logging/logging.dart';
import 'package:flutter/cupertino.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ApiService apiService = ApiService();
  bool rememberMe = false;
  bool _obscurePassword = true;

  final _formKey = GlobalKey<FormState>();
  final _logger = Logger('LoginScreen');
  String? emailError;
  String? passwordError;

  @override
  void initState() {
    super.initState();
    _checkRememberedUser();
  }

  void login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = emailController.text;
      final password = passwordController.text;

      final result = await apiService.login(email, password);
      if (result != null) {
        if (rememberMe) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', result.token);
          await prefs.setString('fullname', result.fullname);
          await prefs.setInt('userid', result.userid);
          await prefs.setString('email', result.email);
          _logger.info('Token berhasil disimpan: ${result.token}');
        }

        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
              builder: (context) => HomeScreen(
                    token: result.token,
                    fullname: result.fullname,
                    userid: result.userid,
                    email: result.email,
                  )),
        );
      } else {
        setState(() {
          emailError = 'Email Salah atau Akun tidak ditemukan!';
          passwordError = 'Kata Sandi Salah atau Akun tidak ditemukan!';
        });
      }
    }
  }

  void _checkRememberedUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? fullname = prefs.getString('fullname');
    int? userid = prefs.getInt('userid');
    String? email = prefs.getString('email');

    if (token != null && fullname != null && userid != null && email != null) {
      _logger.info('Token ditemukan di penyimpanan: $token');
      final isValid = await apiService.validateToken(token);
      if (isValid) {
        _logger.info('Token valid');
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => HomeScreen(
              token: token,
              fullname: fullname,
              userid: userid,
              email: email,
            ),
          ),
        );
      } else {
        _logger.warning('Token tidak valid');
        prefs.clear();
      }
    }
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool isValidPassword(String password) {
    return password.length >= 6;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/gambar/bg.png"),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: const Center(),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Masuk ke Akun Anda',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: GoogleFonts.poppins(),
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        errorText: emailError, // Display error text if present
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email harus diisi';
                        }
                        if (!isValidEmail(value)) {
                          return 'Format email tidak valid';
                        }
                        return null; // Reset error message if input is correct
                      },
                      onChanged: (value) {
                        setState(() {
                          emailError = null;
                        });
                      },
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: GoogleFonts.poppins(),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        errorText:
                            passwordError, // Display error text if present
                      ),
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kata Sandi harus diisi';
                        }
                        if (!isValidPassword(value)) {
                          return 'Kata Sandi harus minimal 6 karakter';
                        }
                        return null; // Reset error message if input is correct
                      },
                      onChanged: (value) {
                        setState(() {
                          passwordError = null;
                        });
                      },
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: rememberMe,
                              onChanged: (bool? value) {
                                setState(() {
                                  rememberMe = value ?? false;
                                });
                              },
                            ),
                            Text(
                              'Ingat Saya',
                              style: GoogleFonts.poppins(),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            // Implement forgot password functionality
                          },
                          child: Text(
                            'Lupa Password?',
                            style: GoogleFonts.poppins(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Masuk',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.white, // Menambahkan warna putih
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: Text(
                        'Belum punya akun? Daftar di sini',
                        style: GoogleFonts.poppins(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
