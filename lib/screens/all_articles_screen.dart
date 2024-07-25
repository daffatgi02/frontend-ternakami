// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:ternakami/models/article.dart';
import 'package:ternakami/screens/article_detail_screen.dart';
import 'package:intl/intl.dart';

class AllArticlesScreen extends StatefulWidget {
  final List<Article> articles;

  const AllArticlesScreen({super.key, required this.articles});

  @override
  _AllArticlesScreenState createState() => _AllArticlesScreenState();
}

class _AllArticlesScreenState extends State<AllArticlesScreen> {
  late List<Article> sortedArticles;
  String dropdownValue = 'Latest';

  @override
  void initState() {
    super.initState();
    sortedArticles = List.from(widget.articles);
    _sortArticles();
  }

  void _sortArticles() {
    if (dropdownValue == 'Latest') {
      sortedArticles.sort((a, b) => b.publishedDate.compareTo(a.publishedDate));
    } else {
      sortedArticles.sort((a, b) => a.publishedDate.compareTo(b.publishedDate));
    }
  }

  String formatDate(String date) {
    final DateTime dateTime = DateTime.parse(date);
    return DateFormat('d MMM, yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
            const Text('Semua Artikel', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: dropdownValue,
              icon: const Icon(Icons.arrow_downward, color: Colors.black),
              elevation: 16,
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                  _sortArticles();
                });
              },
              items: <String>['Latest', 'Oldest']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child:
                      Text(value, style: const TextStyle(color: Colors.black)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: sortedArticles.length,
        itemBuilder: (context, index) {
          final article = sortedArticles[index];
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Card(
                color: Colors.white,
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8.0),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: SizedBox(
                      width: 100, // Ubah sesuai kebutuhan Anda
                      height: 300, // Ubah sesuai kebutuhan Anda
                      child: Image.network(
                        article.imgUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            article.formattedAuthor,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.verified,
                              color: Colors.blue, size: 16),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatDate(article.publishedDate),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ArticleDetailScreen(article: article),
                      ),
                    );
                  },
                )),
          );
        },
      ),
    );
  }
}
