import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';

class HasilPrediksiScreen extends StatelessWidget {
  final String animalName;
  final double confidence;
  final String labelPrediksi;
  final String imageUrl;

  const HasilPrediksiScreen({
    super.key,
    required this.animalName,
    required this.confidence,
    required this.labelPrediksi,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Mendapatkan ukuran layar
    final screenWidth = MediaQuery.of(context).size.width;

    // Mengatur padding dan font size berdasarkan lebar layar
    final buttonPadding = screenWidth * 0.04; // Padding 4% dari lebar layar
    final buttonFontSize =
        screenWidth * 0.045; // Font size 4.5% dari lebar layar
    final buttonHeight =
        screenWidth * 0.12; // Tinggi button 12% dari lebar layar

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Hasil Prediksi',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                showImageViewer(
                  context,
                  Image.network(imageUrl).image,
                  swipeDismissible: true,
                  doubleTapZoomable: true,
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        color: Colors.black.withOpacity(0.5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nama: $animalName',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              labelPrediksi,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(confidence * 100).toStringAsFixed(2)}%',
                              style: GoogleFonts.poppins(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(
                        Icons.zoom_in,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32), // Tambahkan jarak di atas tombol
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: buttonPadding),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                backgroundColor: Colors.blue,
                minimumSize: Size(
                    double.infinity, buttonHeight), // Mengatur tinggi button
              ),
              child: Text(
                'Kembali ke Home',
                style: GoogleFonts.poppins(
                  fontSize: buttonFontSize,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16), // Tambahkan jarak di bawah tombol
          ],
        ),
      ),
    );
  }
}
