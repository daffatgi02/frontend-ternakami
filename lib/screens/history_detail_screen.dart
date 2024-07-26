import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:ternakami/models/history.dart';

class HistoryDetailScreen extends StatelessWidget {
  final History history;

  HistoryDetailScreen({super.key, required this.history});

  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonPadding = screenWidth * 0.04;
    final buttonFontSize = screenWidth * 0.045;
    final buttonHeight = screenWidth * 0.12;

    List<String> tipsTrikSlides;
    if (history.predictionClass == 'Mata Terjangkit PinkEye') {
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            expandedHeight: 150.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  ClipPath(
                    clipper: BackgroundWaveClipper(),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF2196F3), Color(0xFF2196F3)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    top: 39,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Detail Riwayat',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Image.asset(
                          'assets/gambar/logo.png',
                          width: 70,
                          height: 70,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      showImageViewer(
                        context,
                        Image.network(history.imageUrl).image,
                        swipeDismissible: true,
                        doubleTapZoomable: true,
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: history.imageUrl,
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator()),
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
                                    'Nama: ${history.animalName}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    history.predictionClass,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(history.predictionProbability * 100).toStringAsFixed(2)}%',
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
                      'Kembali',
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
          ),
        ],
      ),
    );
  }
}

class BackgroundWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    final p0 = size.height * 0.75;
    path.lineTo(0.0, p0);

    final controlPoint = Offset(size.width * 0.4, size.height);
    final endPoint = Offset(size.width, size.height / 2);
    path.quadraticBezierTo(
        controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);

    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(BackgroundWaveClipper oldClipper) => false;
}
