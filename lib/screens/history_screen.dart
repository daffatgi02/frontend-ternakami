// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart'; // Import Cupertino package
import 'package:ternakami/models/history.dart';
import 'package:ternakami/services/api_service.dart';
import 'package:ternakami/screens/history_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';

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

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) => FilterSheet(
        selectedFilter: _selectedFilter,
        onFilterChanged: (filter) {
          setState(() {
            _selectedFilter = filter;
            _filterHistory();
          });
        },
      ),
    );
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
                      onFilterIconPressed: _showFilterModal,
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
                                  child: OrderCard(
                                    date: history.formattedCreatedAt,
                                    imageUrl: history.imageUrl,
                                    title: history.animalName,
                                    subtitle: history.predictionClass,
                                    description: 'Selesai',
                                    price: 'Lihat Detail',
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
  final VoidCallback onFilterIconPressed;

  SliverSearchAppBar(
      this._searchController, this._selectedFilter, this.onFilterChanged,
      {required this.onFilterIconPressed});

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
                    IconButton(
                      icon: Icon(
                        _selectedFilter == 'All'
                            ? Icons.filter_alt_outlined
                            : Icons.filter_alt_rounded,
                        color: Colors.grey,
                      ),
                      onPressed: onFilterIconPressed,
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

class OrderCard extends StatelessWidget {
  final String date;
  final String imageUrl;
  final String title;
  final String subtitle;
  final String description;
  final String price;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.date,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.price,
    required this.onTap,
  });

  String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    final DateFormat formatter = DateFormat('dd MMM, HH:mm');
    return formatter.format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(5.0),
      shadowColor: Colors.black87,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Column(
              children: [
                Text(
                  _formatDate(date),
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color.fromARGB(255, 109, 105, 105),
                      fontWeight: FontWeight.w500),
                ),
                Container(
                  width: 107,
                  height: 97,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500),
                  ),
                  if (description.isNotEmpty)
                    Text(
                      description,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w300),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 50),
                if (price.isNotEmpty)
                  Text(
                    price,
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w400),
                  ),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding:
                        const EdgeInsets.all(4), // Mengurangi ukuran padding
                    minimumSize: const Size(
                        55, 32), // Menambahkan ukuran minimum untuk button
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 16, // Mengurangi ukuran ikon
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FilterSheet extends StatefulWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const FilterSheet({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  _FilterSheetState createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late String _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.selectedFilter;
  }

  void _handleFilterChange(String value) {
    setState(() {
      _selectedFilter = value;
    });
    widget.onFilterChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.all(Radius.circular(24)), // Ensures no rounded corners
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Berdasarkan Kondisi',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  if (_selectedFilter != 'All') {
                    _handleFilterChange('All'); // Show all history on close
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          ListTile(
            title: Text(
              'Mata Terjangkit Pinkeye',
              style: GoogleFonts.poppins(),
            ),
            trailing: Radio<String>(
              value: 'Pinkeye',
              groupValue: _selectedFilter,
              onChanged: (value) {
                if (value != null && value != _selectedFilter) {
                  _handleFilterChange(value);
                }
              },
              activeColor: Colors.blue, // Blue for the selected circle
            ),
          ),
          ListTile(
            title: Text(
              'Mata Sehat',
              style: GoogleFonts.poppins(),
            ),
            trailing: Radio<String>(
              value: 'Sehat',
              groupValue: _selectedFilter,
              onChanged: (value) {
                if (value != null && value != _selectedFilter) {
                  _handleFilterChange(value);
                }
              },
              activeColor: Colors.blue, // Blue for the selected circle
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (_selectedFilter != 'All') {
                    _handleFilterChange('All');
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor:
                      Colors.black, // Black text for the reset button
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.grey),
                ),
                child: Text(
                  'Reset',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.blue, // Blue background for the apply button
                  foregroundColor:
                      Colors.white, // White text for the apply button
                ),
                child: Text(
                  'Terapkan',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ],
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
