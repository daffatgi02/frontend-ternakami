import 'package:flutter/material.dart';
import 'package:ternakami/models/history.dart';
import 'package:ternakami/services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  final String token;

  const HistoryScreen({Key? key, required this.token}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<History> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
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
        // Urutkan riwayat berdasarkan waktu yang terbaru
        _history = history;
        _history.sort(
            (a, b) => b.formattedCreatedAt.compareTo(a.formattedCreatedAt));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prediction History')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? const Center(child: Text('No prediction history found.'))
              : ListView.builder(
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final history = _history[index];
                    return ListTile(
                      title: Text(history.predictionClass),
                      subtitle: Text('Animal: ${history.animalName}'),
                      trailing: Text(history.formattedCreatedAt),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Menampilkan gambar dari image_url dengan menggunakan widget Image.network
                                Image.network(
                                  history.imageUrl,
                                  fit: BoxFit.fitWidth, // Atur sesuai kebutuhan
                                ),
                                SizedBox(height: 8),
                                Text('Nama Hewan: ${history.animalName}'),
                                Text('Prediksi: ${history.predictionClass}'),
                                Text(
                                    'Tanggal Prediksi: ${history.formattedCreatedAt}'),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
