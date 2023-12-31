import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class AuthApi {
  final String _baseUrl = 'http://localhost:3000/api/auth';

  Future<User?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['error'] == false) {
        return User.fromJson(data['loginResult']);
      }
    }
    return null;
  }
}
