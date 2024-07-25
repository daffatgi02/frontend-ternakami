// lib/services/article_service.dart
import 'package:dio/dio.dart';
import 'package:ternakami/models/article.dart';

class ArticleService {
  final Dio _dio = Dio();

  Future<List<Article>> fetchArticles() async {
    List<Article> articles = [];
    for (int i = 1; i <= 5; i++) {
      final response = await _dio.get(
          'https://project-backendternakami.et.r.appspot.com/api/articles/$i');
      if (response.statusCode == 200) {
        articles.add(Article.fromJson(response.data));
      }
    }
    return articles;
  }
}
