import 'package:intl/intl.dart';

class Article {
  final int id;
  final String title;
  final String content;
  final String author;
  final String publishedDate;
  final String imgUrl;

  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.publishedDate,
    required this.imgUrl,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      author: json['author'],
      publishedDate: json['published_date'],
      imgUrl: json['img_url'],
    );
  }

  String get formattedDate {
    final DateTime dateTime = DateTime.parse(publishedDate);
    return DateFormat('d MMM, yyyy').format(dateTime);
  }

  String get formattedAuthor {
    final List<String> names = author.split(' ');
    return names.length > 1 ? '${names[0]} ${names[1]}' : names[0];
  }
}
