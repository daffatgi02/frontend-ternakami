import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ternakami/services/api_service.dart';
import 'package:flutter/services.dart';
import 'hasilprediksi_screen.dart';

class PredictionScreen extends StatefulWidget {
  final String token;

  const PredictionScreen({Key? key, required this.token}) : super(key: key);

  @override
  _PredictionScreenState createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isRearCameraSelected = true;
  bool _flashEnabled = false;
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  String? _selectedType;
  final List<String> _types = ['sapi', 'kambing'];
  final TextEditingController _animalNameController = TextEditingController();
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(
      _isRearCameraSelected ? _cameras!.first : _cameras!.last,
      ResolutionPreset.high,
    );
    await _cameraController!.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      _flashEnabled = !_flashEnabled;
      await _cameraController!.setFlashMode(
        _flashEnabled ? FlashMode.torch : FlashMode.off,
      );
      setState(() {});
    }
  }

  Future<void> _flipCamera() async {
    _isRearCameraSelected = !_isRearCameraSelected;
    await _initializeCamera();
  }

  Future<void> _captureImage() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      final XFile image = await _cameraController!.takePicture();
      setState(() {
        _image = image;
        _showImagePreview();
      });
    }
  }

  Future<void> _selectImageFromGallery() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile;
      _showImagePreview();
    });
  }

  void _showImagePreview() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _image != null
                  ? Image.file(File(_image!.path), height: 200)
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
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(
                      r'[a-zA-Z0-9\s]')), // Allow letters, numbers, and spaces only
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _captureImage();
                    },
                    child: const Text('Retake Photo'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _predict();
                    },
                    child: const Text('Continue'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _predict() async {
    if (_image == null ||
        _selectedType == null ||
        _animalNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final Map<String, dynamic>? predictionResult = await _apiService.predict(
      widget.token,
      File(_image!.path),
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
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: _cameraController == null ||
                    !_cameraController!.value.isInitialized
                ? Center(child: CircularProgressIndicator())
                : CameraPreview(_cameraController!),
          ),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(
            top: 40,
            right: 10,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _flashEnabled ? Icons.flash_on : Icons.flash_off,
                    color: Colors.white,
                  ),
                  onPressed: _toggleFlash,
                ),
                IconButton(
                  icon: Icon(Icons.switch_camera, color: Colors.white),
                  onPressed: _flipCamera,
                ),
                IconButton(
                  icon: Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {
                    // Add more options functionality here
                  },
                ),
              ],
            ),
          ),
          Center(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
              ),
              width: 200,
              height: 200,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: _captureImage,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.camera_alt, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Sesuaikan posisi mata kambing agar memenuhi Frame',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _selectImageFromGallery,
                    child: const Text('Upload Gambar'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      onPrimary: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
