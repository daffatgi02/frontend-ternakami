import 'package:flutter/material.dart';
import 'package:ternakami/models/article.dart';
import 'package:ternakami/services/article_service.dart';
import 'package:ternakami/screens/article_detail_screen.dart';
import 'package:ternakami/screens/prediction_screen.dart';
import 'package:ternakami/screens/profile_screen.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:ternakami/screens/all_articles_screen.dart'; // Import the new screen

class HomeScreen extends StatefulWidget {
  final String token;
  final String fullname;
  final int userid;
  final String email;

  const HomeScreen({
    super.key,
    required this.token,
    required this.fullname,
    required this.userid,
    required this.email,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;
  late Future<List<Article>> _articles;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _articles = ArticleService().fetchArticles();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: [
            _buildHomeContent(),
            ProfileScreen(
              token: widget.token,
              fullname: widget.fullname,
              email: widget.email,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: CurvedNavigationBar(
          backgroundColor: Colors.transparent,
          color: Colors.blue,
          height: 60,
          items: const [
            Icon(Icons.home, size: 30, color: Colors.white),
            Icon(Icons.person, size: 30, color: Colors.white),
          ],
          index: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return FutureBuilder<List<Article>>(
      future: _articles,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No articles found'));
        }

        final articles = snapshot.data!;
        final articlesToShow = articles.take(5).toList();

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Holla, ${widget.fullname}!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Chek Kambing Kamu Sekarang',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => navigateToPrediction(context),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Prediksi Kambingmu!'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32.0,
                        vertical: 12.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildInterestingArticlesSection(articlesToShow),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInterestingArticlesSection(List<Article> articles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Artikel Menarik',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllArticlesScreen(articles: articles),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                    color: Colors.blue,
                    width: 1.0), // Menambahkan ukuran outline
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: const Size(
                    50, 30), // Menambahkan ukuran tombol (width, height)
              ),
              child: const Text(
                'Lihat Semua',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 12, // Menambahkan fontSize
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: articles
                .map((article) => _ArticleCard(article: article))
                .toList(),
          ),
        ),
      ],
    );
  }

  void navigateToPrediction(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PredictionScreen(token: widget.token),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final Article article;

  const _ArticleCard({
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(article: article),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(right: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: SizedBox(
          width: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
                child: Image.network(
                  article.imgUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 190,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  article.title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
