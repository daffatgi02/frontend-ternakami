// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:ternakami/services/api_service.dart';
import 'package:ternakami/models/history.dart';
import 'package:ternakami/screens/history_screen.dart';
import 'package:ternakami/screens/history_detail_screen.dart'; // Import layar detail
import 'package:ternakami/screens/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';

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

  void _logout() {
    // Menghapus data token, fullname, dan email
    // Menavigasi kembali ke halaman login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );

    // Menampilkan dialog "Telah Logout"
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
            // Bagian yang tidak dapat di-scroll
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
                      backgroundColor:
                          Colors.red, // Mengatur warna latar belakang tombol
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            14.0), // Mengatur radius border
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 60,
                          vertical: 10), // Menambahkan padding kustom
                      elevation: 5, // Menambahkan elevasi untuk efek bayangan
                    ),
                    child: Text(
                      'Keluar',
                      style: GoogleFonts.poppins(
                        color: Colors.white, // Mengatur warna teks
                        fontSize: 16, // Mengatur ukuran font
                        fontWeight: FontWeight.w500, // Mengatur ketebalan font
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
                          side: const BorderSide(
                              color: Colors.blue,
                              width: 1.0), // Menambahkan ukuran outline
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                20), // Membuat border menjadi bulat
                          ),
                          minimumSize: const Size(50,
                              27), // Menambahkan ukuran tombol (width, height)
                        ),
                        child: Text(
                          'Lihat Riwayat Lainnya',
                          style: GoogleFonts.poppins(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                            fontSize: 12, // Menambahkan ukuran font
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
