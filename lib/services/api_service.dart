import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:ternakami/models/user.dart';
import 'package:ternakami/models/history.dart';
import 'package:ternakami/utils/constants.dart';

class ApiService {
  Future<User?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$BASE_URL/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    print('DEBUG: Login response status code: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data['loginResult']);
    } else if (response.statusCode == 400) {
      // Wrong Password or Account not found
      return null;
    } else {
      // Handle other errors
      return null;
    }
  }

  Future<bool> register(String email, String password, String fullname) async {
    final response = await http.post(
      Uri.parse('$BASE_URL/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'email': email, 'password': password, 'fullname': fullname}),
    );

    if (response.statusCode == 201) {
      return true;
    } else if (response.statusCode == 400) {
      // Email already taken or other validation error
      return false;
    } else {
      // Handle other errors
      return false;
    }
  }

  Future<String?> getHomePageData(String token) async {
    final response = await http.get(
      Uri.parse('$BASE_URL/api/homepage'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['message'];
    } else if (response.statusCode == 401) {
      // Failed to authenticate token
      return null;
    } else {
      // Handle other errors
      return null;
    }
  }

  Future<Map<String, dynamic>?> predict(
      String token, File image, String type, String animalName) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$BASE_URL/api/predict'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        image.path,
        contentType: MediaType('image', 'jpeg'), // Using MediaType
      ),
    );
    request.fields['type'] = type;
    request.fields['Animal_Name'] = animalName;

    print('DEBUG: Sending prediction request...');
    var response = await request.send();

    print('DEBUG: Prediction request sent, awaiting response...');

    if (response.statusCode == 200) {
      print('DEBUG: Prediction request successful, processing response...');
      var responseData = await response.stream.bytesToString();
      print('DEBUG: Response data: $responseData');
      return jsonDecode(responseData);
    } else if (response.statusCode == 400) {
      print('DEBUG: Prediction request failed with status code 400');
      // No image, type, or Animal_Name specified
      return null;
    } else if (response.statusCode == 401) {
      print('DEBUG: Prediction request failed with status code 401');
      // No token provided or Failed to authenticate token
      return null;
    } else if (response.statusCode == 500) {
      print('DEBUG: Prediction request failed with status code 500');
      // Error uploading image, Error saving prediction, or Error during prediction
      return null;
    } else {
      print(
          'DEBUG: Prediction request failed with unknown status code: ${response.statusCode}');
      // Handle other errors
      return null;
    }
  }

  Future<List<History>?> getHistory(String token) async {
    final response = await http.get(
      Uri.parse('$BASE_URL/api/historyPredict'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      return responseData.map((data) => History.fromJson(data)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Error fetching history');
    }
  }
}
