import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HasilPrediksiScreen extends StatelessWidget {
  final String animalName;
  final double confidence;
  final String labelPrediksi;
  final String imageUrl;

  HasilPrediksiScreen({
    super.key,
    required this.animalName,
    required this.confidence,
    required this.labelPrediksi,
    required this.imageUrl,
  });

  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonPadding = screenWidth * 0.04;
    final buttonFontSize = screenWidth * 0.045;
    final buttonHeight = screenWidth * 0.12;

    List<String> tipsTrikSlides;
    if (labelPrediksi == 'Mata Terjangkit PinkEye') {
      tipsTrikSlides = [
        'Tips & Trik: Jika hewan mengalami pinkeye, segera bersihkan mata dengan air hangat dan hubungi dokter hewan.',
        'Tips & Trik: Pastikan untuk selalu menjaga kebersihan lingkungan sekitar agar hewan-hewan tetap sehat dan terhindar dari penyakit.'
      ];
    } else {
      tipsTrikSlides = [
        'Tips & Trik: Pastikan untuk selalu menjaga kebersihan lingkungan sekitar agar hewan-hewan tetap sehat dan terhindar dari penyakit.',
        'Tips & Trik: Jika hewan mengalami pinkeye, segera bersihkan mata dengan air hangat dan hubungi dokter hewan.'
      ];
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenImageViewer(
                      imageUrls: [imageUrl],
                    ),
                  ),
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
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: const BorderSide(color: Colors.white),
              ),
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.5),
              child: Column(
                children: [
                  SizedBox(
                    height: 150,
                    child: PageView(
                      controller: _pageController,
                      children: tipsTrikSlides.map((text) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            text,
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: tipsTrikSlides.length,
                    effect: const WormEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      activeDotColor: Colors.blue,
                      dotColor: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            const SizedBox(height: 32),
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
                minimumSize: Size(double.infinity, buttonHeight),
              ),
              child: Text(
                'Prediksi Ulang',
                style: GoogleFonts.poppins(
                  fontSize: buttonFontSize,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class FullScreenImageViewer extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenImageViewer(
      {super.key, required this.imageUrls, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            itemCount: imageUrls.length,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(imageUrls[index]),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
                heroAttributes: PhotoViewHeroAttributes(tag: imageUrls[index]),
              );
            },
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            pageController: PageController(initialPage: initialIndex),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
