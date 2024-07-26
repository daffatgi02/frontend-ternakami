// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:ternakami/services/api_service.dart';
import 'package:ternakami/models/history.dart';
import 'package:ternakami/screens/history_screen.dart';
import 'package:ternakami/screens/history_detail_screen.dart'; // Import layar detail
import 'package:ternakami/screens/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Print the token and other details before removing
    String? token = prefs.getString('token');
    String? fullname = prefs.getString('fullname');
    String? email = prefs.getString('email');
    int? userid = prefs.getInt('userid');

    print('Token yang akan dihapus: $token');
    print('Fullname yang akan dihapus: $fullname');
    print('Email yang akan dihapus: $email');
    print('UserID yang akan dihapus: $userid');

    await prefs.clear();

    print('Token berhasil dihapus.');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Telah Logout'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _navigateToDetail(BuildContext context, History history) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryDetailScreen(history: history),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/gambar/logo.png'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.fullname,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.email,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 60, vertical: 10),
                      elevation: 5,
                    ),
                    child: Text(
                      'Keluar',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Prediksi Terakhir',
                          style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black)),
                      OutlinedButton(
                        onPressed: () => _navigateToHistory(context),
                        style: OutlinedButton.styleFrom(
                          side:
                              const BorderSide(color: Colors.blue, width: 1.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          minimumSize: const Size(50, 27),
                        ),
                        child: Text(
                          'Lihat Riwayat Lainnya',
                          style: GoogleFonts.poppins(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 2.0,
                  bottom: 5.0,
                ),
                child: FutureBuilder<List<History>?>(
                  future: _latestPredictions,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text('Tidak Ada Riwayat Prediksi.',
                              style: GoogleFonts.poppins(color: Colors.black)));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                          child: Text('Tidak Ada Riwayat Prediksi.',
                              style: GoogleFonts.poppins(color: Colors.black)));
                    } else {
                      final latestPredictions = snapshot.data!.take(5).toList();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...latestPredictions.map((prediction) {
                            return Card(
                              color: Colors.white,
                              child: InkWell(
                                onTap: () =>
                                    _navigateToDetail(context, prediction),
                                child: ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(25.0),
                                    child: Image.network(prediction.imageUrl,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover),
                                  ),
                                  title: RichText(
                                    text: TextSpan(
                                      text: 'Nama: ',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                      children: [
                                        TextSpan(
                                          text: prediction.animalName,
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                  subtitle: RichText(
                                    text: TextSpan(
                                      text: 'Kondisi: ',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                      children: [
                                        TextSpan(
                                          text: prediction.predictionClass,
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
