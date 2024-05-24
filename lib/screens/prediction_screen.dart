import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ternakami/services/api_service.dart'; // Importing ApiService

class PredictionScreen extends StatefulWidget {
  final String token;

  const PredictionScreen({Key? key, required this.token}) : super(key: key);

  @override
  _PredictionScreenState createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  String? _selectedType;
  final List<String> _types = ['sapi', 'kambing'];
  final TextEditingController _animalNameController = TextEditingController();
  final ApiService _apiService =
      ApiService(); // Creating instance of ApiService

  Future getImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> predict() async {
    if (_image == null ||
        _selectedType == null ||
        _animalNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final bytes = await _image!.readAsBytes();
    final Map<String, dynamic>? predictionResult = await _apiService.predict(
      widget.token,
      _image!,
      _selectedType!,
      _animalNameController.text,
    );

    if (predictionResult != null &&
        predictionResult.containsKey('label_prediksi')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              HasilPrediksiScreen(predictionResult: predictionResult),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to make prediction")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animal Eye Prediction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: getImage,
              child: const Text('Select Image'),
            ),
            const SizedBox(height: 20),
            _image != null
                ? Image.file(_image!, height: 200)
                : const SizedBox(
                    height: 200,
                    child: Center(child: Text('No Image Selected')),
                  ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedType,
              onChanged: (newValue) {
                setState(() {
                  _selectedType = newValue;
                });
              },
              items: _types.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _animalNameController,
              decoration: const InputDecoration(labelText: 'Animal Name'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: predict,
              child: const Text('Predict'),
            ),
          ],
        ),
      ),
    );
  }
}

class HasilPrediksiScreen extends StatelessWidget {
  final Map<String, dynamic> predictionResult;

  const HasilPrediksiScreen({Key? key, required this.predictionResult})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prediction Result')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hasil Prediksi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              predictionResult['label_prediksi'] ?? 'Unknown',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Nama Hewan: ${predictionResult['Animal_Name']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Tersimpan Kedalam History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
