// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:ternakami/screens/prediction_screen.dart';
import 'package:ternakami/screens/history_screen.dart';
import 'package:ternakami/screens/profile_screen.dart'; // Import ProfileScreen
import 'package:ternakami/services/api_service.dart';
import 'package:ternakami/models/history.dart';

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
  late Future<List<History>?> _latestPredictions;

  @override
  void initState() {
    super.initState();
    _latestPredictions = ApiService().getHistory(widget.token);
  }

  Future<void> _refreshData() async {
    setState(() {
      _latestPredictions = ApiService().getHistory(widget.token);
    });
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

  void navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ProfileScreen(
                fullname: widget.fullname,
                email: widget.email,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ternakami')),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                FutureBuilder<List<History>?>(
                  future: _latestPredictions,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(
                          child: Text('Error fetching predictions.',
                              style: TextStyle(color: Colors.red)));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('Tidak Ada Riwayat Prediksi.',
                              style: TextStyle(color: Colors.black)));
                    } else {
                      final latestPredictions = snapshot.data!.take(3).toList();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Riwayat Prediksi',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          const SizedBox(height: 10),
                          ...latestPredictions.map((prediction) {
                            return Card(
                              color: Colors.white,
                              child: ListTile(
                                leading: Image.network(prediction.imageUrl,
                                    width: 50, height: 50),
                                title: Text(prediction.animalName,
                                    style: const TextStyle(color: Colors.black)),
                                subtitle: Text(
                                    'Class: ${prediction.predictionClass}, Probability: ${prediction.predictionProbability}',
                                    style: const TextStyle(color: Colors.black)),
                              ),
                            );
                          }),
                          TextButton(
                            onPressed: () => navigateToHistory(context),
                            child: const Text('Lihat Selengkapnya',
                                style: TextStyle(color: Colors.black)),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 0) {
            // Stay on Home
          } else if (index == 1) {
            navigateToProfile(context);
          }
        },
      ),
    );
  }
}
