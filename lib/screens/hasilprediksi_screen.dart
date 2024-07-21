import 'package:flutter/material.dart';

class HasilPrediksiScreen extends StatelessWidget {
  final Map<String, dynamic> predictionResult;

  const HasilPrediksiScreen({Key? key, required this.predictionResult})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prediction Result')),
      body: Center(
        child: Text('Prediction: ${predictionResult['label_prediksi']}'),
      ),
    );
  }
}
