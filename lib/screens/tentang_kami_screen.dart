import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TentangKamiScreen extends StatelessWidget {
  const TentangKamiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Kami'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
            const SizedBox(height: 10),
            Text(
              'Kami adalah aplikasi terbaik untuk peternakan Anda. Kami membantu Anda mengelola peternakan dengan cara yang lebih efisien dan efektif. '
              'Bergabunglah dengan kami dan rasakan kemudahan dalam mengelola peternakan Anda.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
