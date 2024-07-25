// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:ternakami/screens/prediction_screen.dart';
import 'package:ternakami/screens/profile_screen.dart';

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
  final List<String> _titles = ['Ternakami', 'Ternakami'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _titles[_selectedIndex],
            key: ValueKey<String>(_titles[_selectedIndex]),
            style: const TextStyle(color: Colors.black),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: PageView(
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildHomeContent() {
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
            _buildInterestingArticlesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestingArticlesSection() {
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
            TextButton(
              onPressed: () {},
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _ArticleCard(
                imageUrl: 'https://via.placeholder.com/150',
                title: 'Artikel 1',
                description: 'Deskripsi artikel 1...',
              ),
              SizedBox(width: 10),
              _ArticleCard(
                imageUrl: 'https://via.placeholder.com/150',
                title: 'Artikel 2',
                description: 'Deskripsi artikel 2...',
              ),
              SizedBox(width: 10),
              _ArticleCard(
                imageUrl: 'https://via.placeholder.com/150',
                title: 'Artikel 3',
                description: 'Deskripsi artikel 3...',
              ),
            ],
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
  final String imageUrl;
  final String title;
  final String description;

  const _ArticleCard({
    required this.imageUrl,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 150,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
