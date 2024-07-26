// ignore_for_file: library_private_types_in_public_api, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:ternakami/models/article.dart';
import 'package:ternakami/screens/article_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_bar_with_search_switch/app_bar_with_search_switch.dart';

class AllArticlesScreen extends StatefulWidget {
  final List<Article> articles;

  const AllArticlesScreen({super.key, required this.articles});

  @override
  _AllArticlesScreenState createState() => _AllArticlesScreenState();
}

class _AllArticlesScreenState extends State<AllArticlesScreen> {
  late List<Article> filteredArticles;
  final ValueNotifier<String> searchText = ValueNotifier<String>('');

  @override
  void initState() {
    super.initState();
    filteredArticles = List.from(widget.articles);
  }

  String formatDate(String date) {
    final DateTime dateTime = DateTime.parse(date);
    return DateFormat('d MMM, yyyy').format(dateTime);
  }

  void _filterArticles(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredArticles = List.from(widget.articles);
      } else {
        filteredArticles = widget.articles
            .where((article) =>
                article.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWithSearchSwitch(
        onChanged: (text) {
          searchText.value = text;
          _filterArticles(text);
        },
        theme: AppBarWithSearchSwitchTheme(
          backgroundColor: Colors.blue,
          textStyle: const TextStyle(color: Colors.white),
          inputDecorationTheme: const InputDecorationTheme(
            hintStyle: TextStyle(color: Colors.white70),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        appBarBuilder: (context) {
          return AppBar(
            title: Text(
              'Semua Artikel',
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(color: Colors.white),
              ),
            ),
            backgroundColor: Colors.blue,
            actions: const [
              AppBarSearchButton(),
            ],
          );
        },
      ),
      body: ValueListenableBuilder<String>(
        valueListenable: searchText,
        builder: (context, value, child) {
          return ListView.builder(
            itemCount: filteredArticles.length,
            itemBuilder: (context, index) {
              final article = filteredArticles[index];
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
                        width: 100,
                        height: 300,
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
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

AppBarWithSearchSwitchTheme(
    {required MaterialColor backgroundColor,
    required TextStyle textStyle,
    required InputDecorationTheme inputDecorationTheme,
    required IconThemeData iconTheme}) {}
