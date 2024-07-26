// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Import Cupertino package
import 'package:ternakami/models/history.dart';
import 'package:ternakami/services/api_service.dart';
import 'package:ternakami/screens/history_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  final String token;

  const HistoryScreen({super.key, required this.token});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<History> _history = [];
  List<History> _filteredHistory = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _fetchHistory();
    _searchController.addListener(_filterHistory);
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
    });

    final apiService = ApiService();
    final history = await apiService.getHistory(widget.token);

    setState(() {
      _isLoading = false;
      if (history != null) {
        _history = history;
        _history.sort(
            (a, b) => b.formattedCreatedAt.compareTo(a.formattedCreatedAt));
        _filteredHistory = _history;
      }
    });
  }

  void _filterHistory() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredHistory = _history.where((history) {
        final matchesQuery = history.animalName.toLowerCase().contains(query);
        final matchesFilter = _selectedFilter == 'All' ||
            (_selectedFilter == 'Pinkeye' &&
                history.predictionClass == 'Mata Terjangkit PinkEye') ||
            (_selectedFilter == 'Sehat' &&
                history.predictionClass == 'Mata Terlihat Sehat');
        return matchesQuery && matchesFilter;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchHistory,
              child: CustomScrollView(
                slivers: [
                  SliverPersistentHeader(
                    delegate: SliverSearchAppBar(
                      _searchController,
                      _selectedFilter,
                      (filter) {
                        setState(() {
                          _selectedFilter = filter;
                          _filterHistory();
                        });
                      },
                    ),
                    pinned: true,
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(8.0),
                    sliver: _filteredHistory.isEmpty
                        ? const SliverFillRemaining(
                            child: Center(
                              child: Text('Tidak ditemukan riwayat prediksi.',
                                  style: TextStyle(color: Colors.black)),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                                final history = _filteredHistory[index];
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2.0),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    color: Colors.white,
                                    elevation: 4,
                                    shadowColor: Colors.black54,
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.all(16.0),
                                      leading: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.network(
                                          history.imageUrl,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      title: RichText(
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: 'Nama: ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            TextSpan(
                                              text: history.animalName,
                                              style: const TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      subtitle: RichText(
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: 'Hasil: ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            TextSpan(
                                              text: history.predictionClass,
                                              style: const TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      trailing: const Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.grey),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                            // Use CupertinoPageRoute
                                            builder: (context) =>
                                                HistoryDetailScreen(
                                                    history: history),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                              childCount: _filteredHistory.length,
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}

class SliverSearchAppBar extends SliverPersistentHeaderDelegate {
  final TextEditingController _searchController;
  final String _selectedFilter;
  final ValueChanged<String> onFilterChanged;

  SliverSearchAppBar(
      this._searchController, this._selectedFilter, this.onFilterChanged);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: Stack(
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
                      'Riwayat Prediksi',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Cari Hewan mu disini!',
                      style: TextStyle(
                        fontSize: 16,
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
          Positioned(
            left: 0,
            right: 0,
            top: 120,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          hintText: 'Cari nama peliharaan...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        _selectedFilter == 'All'
                            ? Icons.filter_alt_outlined
                            : Icons.filter_alt_rounded,
                        color: Colors.grey,
                      ),
                      onSelected: onFilterChanged,
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'All',
                          child: Text('Semua'),
                        ),
                        const PopupMenuItem(
                          value: 'Pinkeye',
                          child: Text('Pinkeye'),
                        ),
                        const PopupMenuItem(
                          value: 'Sehat',
                          child: Text('Sehat'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 200;

  @override
  double get minExtent => 177;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      oldDelegate.maxExtent != maxExtent || oldDelegate.minExtent != minExtent;
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
