// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:ternakami/screens/prediction_screen.dart';
import 'package:ternakami/screens/history_screen.dart';
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
      appBar: AppBar(title: const Text('Ternakami')),
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
            Text('Halo ${widget.fullname}!',
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => navigateToPrediction(context),
              child: const Text('Predict Animal Eye'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Artikel Ternak Terbaru',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Card(
              child: ListTile(
                title: Text('Artikel 1'),
                subtitle: Text('Deskripsi artikel 1...'),
              ),
            ),
            const Card(
              child: ListTile(
                title: Text('Artikel 2'),
                subtitle: Text('Deskripsi artikel 2...'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void navigateToPrediction(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PredictionScreen(token: widget.token)),
    );
  }

  void navigateToHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => HistoryScreen(token: widget.token)),
    );
  }
}
