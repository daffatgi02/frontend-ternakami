import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TentangKamiScreen extends StatelessWidget {
  const TentangKamiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Tentang Kami', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/gambar/logo.png'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Ternakami',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Halo!'),
            _buildSectionContent(
              'Selamat datang di Ternakami, aplikasi terpercaya untuk memprediksi penyakit pink eye pada kambing melalui scan mata. Misi kami adalah membantu peternak menjaga kesehatan ternak mereka dengan teknologi canggih.',
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Visi Kami'),
            _buildSectionContent(
              'Kami bertujuan untuk merevolusi manajemen kesehatan ternak dengan alat prediksi penyakit yang mudah digunakan dan akurat.',
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Apa yang Kami Lakukan'),
            _buildSectionContent(
              'Dengan Ternakami, cukup scan mata kambing Anda, dan aplikasi kami akan memberikan umpan balik instan tentang potensi masalah pink eye.',
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Komitmen Kami'),
            _buildSectionContent(
              'Kami berdedikasi untuk mendukung peternak dengan menawarkan alat yang andal dan mudah digunakan untuk deteksi dini penyakit pink eye.',
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Hubungi Kami'),
            _buildContactInfo('Daffa (Frontend)', 'daffatgi02@gmail.com'),
            _buildContactInfo(
                'Galang (Backend)', 'galang.rambu.ramadhan.46@gmail.com'),
            _buildContactInfo('Rama (Machine Learning)', 'rama.ae32@gmail.com'),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildContactInfo(String name, String email) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          const Icon(Icons.email, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$name di $email',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
