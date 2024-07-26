import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart'; // For lookupMimeType
import 'package:http_parser/http_parser.dart'; // Add this line
import 'package:ternakami/models/user.dart';
import 'package:ternakami/models/history.dart';
import 'package:ternakami/utils/constants.dart';
import 'package:logging/logging.dart';

class ApiService {
  final Dio _dio = Dio();
  final Logger _logger = Logger('ApiService');

  ApiService() {
    _setupLogging();
  }

  void _setupLogging() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  Future<User?> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/auth/login',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: jsonEncode({'email': email, 'password': password}),
      );
      _logger.fine('Login response status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = response.data;
        return User.fromJson(data['loginResult']);
      }
      return null;
    } on DioException catch (e) {
      _logger.severe('Login error: ${e.response?.statusCode} ${e.message}');
      return null;
    }
  }

  Future<bool> register(String email, String password, String fullname) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/auth/register',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: jsonEncode(
            {'email': email, 'password': password, 'fullname': fullname}),
      );

      return response.statusCode == 201;
    } on DioException catch (e) {
      _logger.severe('Register error: ${e.response?.statusCode} ${e.message}');
      return false;
    }
  }

  Future<String?> getHomePageData(String token) async {
    try {
      final response = await _dio.get(
        '$baseUrl/api/homepage',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data['message'];
      }
      return null;
    } on DioException catch (e) {
      _logger.severe(
          'Get Home Page Data error: ${e.response?.statusCode} ${e.message}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> predict(
      String token, File image, String type, String animalName) async {
    try {
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(image.path,
            contentType: MediaType.parse(
                lookupMimeType(image.path) ?? 'application/octet-stream')),
        'type': type,
        'Animal_Name': animalName,
      });

      final response = await _dio.post(
        '$baseUrl/api/predict',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      _logger.fine('Prediction request sent, awaiting response...');

      if (response.statusCode == 200) {
        _logger.fine('Prediction request successful, processing response...');
        return response.data;
      }
      _logger.severe(
          'Prediction request failed with status code: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      _logger
          .severe('Prediction error: ${e.response?.statusCode} ${e.message}');
      return null;
    }
  }

  Future<List<History>?> getHistory(String token) async {
    try {
      final response = await _dio.get(
        '$baseUrl/api/historyPredict',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is List) {
          return responseData.map((data) => History.fromJson(data)).toList();
        } else if (responseData is Map &&
            responseData['message'] == 'Belum ada riwayat predict') {
          return [];
        } else {
          throw Exception('Unexpected response format');
        }
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Error fetching history');
      }
    } on DioException catch (e) {
      _logger
          .severe('Get History error: ${e.response?.statusCode} ${e.message}');
      throw Exception('Error fetching history');
    }
  }
}
