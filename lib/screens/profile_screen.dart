// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:ternakami/services/api_service.dart';
import 'package:ternakami/models/history.dart';
import 'package:ternakami/screens/history_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String token;
  final String fullname;
  final String email;

  const ProfileScreen({
    super.key,
    required this.token,
    required this.fullname,
    required this.email,
  });

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<List<History>?> _latestPredictions;

  @override
  void initState() {
    super.initState();
    _latestPredictions = ApiService().getHistory(widget.token).then((history) {
      if (history != null) {
        history.sort(
            (a, b) => b.formattedCreatedAt.compareTo(a.formattedCreatedAt));
      }
      return history;
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _latestPredictions =
          ApiService().getHistory(widget.token).then((history) {
        if (history != null) {
          history.sort(
              (a, b) => b.formattedCreatedAt.compareTo(a.formattedCreatedAt));
        }
        return history;
      });
    });
  }

  void _navigateToHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryScreen(token: widget.token),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/gambar/logo.png'),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.fullname,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.email,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
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
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(25.0),
                                child: Image.network(prediction.imageUrl,
                                    width: 50, height: 50, fit: BoxFit.cover),
                              ),
                              title: RichText(
                                text: TextSpan(
                                  text: 'Nama: ',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                  children: [
                                    TextSpan(
                                      text: prediction.animalName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              subtitle: RichText(
                                text: TextSpan(
                                  text: 'Kondisi: ',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                  children: [
                                    TextSpan(
                                      text: prediction.predictionClass,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 10),
                        Center(
                          child: ElevatedButton(
                            onPressed: () => _navigateToHistory(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Lihat Selengkapnya',
                                    style: TextStyle(color: Colors.white)),
                                SizedBox(width: 5),
                                Icon(Icons.arrow_forward, color: Colors.white),
                              ],
                            ),
                          ),
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
    );
  }
}
