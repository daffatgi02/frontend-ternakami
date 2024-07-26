// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ternakami/screens/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ternakami/screens/tentang_kami_screen.dart';
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
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove('token');
    await prefs.remove('fullname');
    await prefs.remove('email');
    await prefs.remove('userid');

    print('Token berhasil dihapus.');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Anda telah keluar'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showFullImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.7,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: const DecorationImage(
                      image: AssetImage('assets/gambar/profil.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(String title, {VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: const Color.fromARGB(255, 144, 144, 144),
            width: 1), // Border hitam tipis
        borderRadius:
            BorderRadius.circular(10), // Opsional: menambahkan radius border
      ),
      child: ListTile(
        title: Text(
          title,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _menuLogout(String title, {VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.redAccent, // Background merah
        border: Border.all(
            color: const Color.fromARGB(255, 255, 255, 255),
            width: 1), // Border hitam tipis
        borderRadius: BorderRadius.circular(10), // Radius border
      ),
      child: ListTile(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white, // Text putih
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 16, color: Colors.white), // Icon putih
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _showFullImage(context),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage('assets/gambar/profil.png'),
                        ),
                      ),
                    ),
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
                ],
              ),
            ),
            const Divider(thickness: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    'Akun',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  _buildMenuItem('Profil Saya'),
                  const SizedBox(height: 8),
                  _buildMenuItem('Riwayat Prediksi', onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) =>
                              HistoryScreen(token: widget.token)),
                    );
                  }),
                  const SizedBox(height: 8),
                  _buildMenuItem('Tentang Kami', onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => const TentangKamiScreen()),
                    );
                  }),
                  const SizedBox(height: 8),
                  _menuLogout('Keluar', onTap: _logout),
                  const SizedBox(height: 20),
                  Text(
                    'Survey Aplikasi',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: Colors.blue.shade100,
                    child: ListTile(
                      title: Text(
                        'Ikuti survei singkat ini untuk membantu aplikasi kami!',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      trailing:
                          const Icon(Icons.arrow_right, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
