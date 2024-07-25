// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ternakami/services/api_service.dart';
import 'package:flutter/services.dart';
import 'package:crop/crop.dart';
import 'package:path_provider/path_provider.dart';
import 'hasilprediksi_screen.dart';

class PredictionScreen extends StatefulWidget {
  final String token;

  const PredictionScreen({super.key, required this.token});

  @override
  _PredictionScreenState createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isRearCameraSelected = true;
  bool _flashEnabled = false;
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  String? _selectedType;
  final List<String> _types = ['kambing'];
  final TextEditingController _animalNameController = TextEditingController();
  final ApiService _apiService = ApiService();

  final CropController _cropController = CropController();
  final BoxShape _shape = BoxShape.rectangle;

  late AnimationController _scanController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _scanController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _scanAnimation = Tween<double>(begin: 0, end: 280).animate(_scanController);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _scanController.dispose();
    super.dispose();
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
      });
      if (_image != null) {
        _showImagePreview();
      }
    }
  }

  Future<void> _selectImageFromGallery() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile;
    });
    if (_image != null) {
      _showImagePreview();
    }
  }

  void _showImagePreview() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: SingleChildScrollView(
                // Wrapping the Column with SingleChildScrollView
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _image != null
                        ? Image.file(File(_image!.path), height: 200)
                        : const SizedBox(
                            height: 200,
                            child: Center(child: Text('No Image Selected')),
                          ),
                    const SizedBox(height: 20),
                    _image != null
                        ? ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _showCropScreen();
                            },
                            child: const Text('Crop Image'),
                          )
                        : Container(),
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
                      decoration:
                          const InputDecoration(labelText: 'Tipe Hewan'),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _animalNameController,
                      decoration:
                          const InputDecoration(labelText: 'Nama Peliharaan'),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9\s]')),
                      ],
                      onChanged: (text) {
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Foto Ulang'),
                        ),
                        ElevatedButton(
                          onPressed: _selectedType != null &&
                                  _animalNameController.text.isNotEmpty
                              ? () {
                                  Navigator.of(context).pop();
                                  _predict();
                                }
                              : null,
                          child: const Text('Lanjutkan'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCropScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Crop Image'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: _cropImage,
              ),
            ],
          ),
          body: Crop(
            controller: _cropController,
            shape: _shape,
            foreground: IgnorePointer(
              child: Container(
                alignment: Alignment.bottomRight,
              ),
            ),
            child: Image.file(File(_image!.path), fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  Future<void> _cropImage() async {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final cropped = await _cropController.crop(pixelRatio: pixelRatio);

    if (cropped != null) {
      final byteData = await cropped.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final buffer = byteData.buffer.asUint8List();

        // Dapatkan direktori sementara
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/cropped_image.png';

        // Simpan gambar hasil pemotongan ke file sementara
        final file = File(filePath);
        await file.writeAsBytes(buffer);

        setState(() {
          _image = XFile(filePath);
        });

        Navigator.of(context).pop();
        _showImagePreview();
      }
    }
  }

  Future<void> _predict() async {
    if (_image == null ||
        _selectedType == null ||
        _animalNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tolong isi semua data!")),
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
          builder: (context) => HasilPrediksiScreen(
            animalName: predictionResult['Animal_Name'],
            confidence: predictionResult['confidence'].toDouble(),
            labelPrediksi: predictionResult['label_prediksi'],
            imageUrl: predictionResult['image_url'],
          ),
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
      body: Stack(
        children: [
          Positioned.fill(
            child: _cameraController == null ||
                    !_cameraController!.value.isInitialized
                ? const Center(child: CircularProgressIndicator())
                : CameraPreview(_cameraController!),
          ),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                  icon: const Icon(Icons.cameraswitch, color: Colors.white),
                  onPressed: _flipCamera,
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {
                    // Add more options functionality here
                  },
                ),
              ],
            ),
          ),
          Center(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius:
                        BorderRadius.circular(20), // Adjust the corner radius
                  ),
                  width: 290,
                  height: 280,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        20), // Same as the container's border radius
                    child: Container(
                      color: Colors.transparent, // Keep the center transparent
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _scanController,
                  builder: (context, child) {
                    return Positioned(
                      top: _scanAnimation.value,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2,
                        color: Colors.blue,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: _captureImage,
                    child: const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.camera_alt, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Sesuaikan posisi mata kambing agar memenuhi Frame',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15), // Adjust the spacing as needed
                  ElevatedButton(
                    onPressed: _selectImageFromGallery,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.drive_folder_upload_rounded),
                        SizedBox(width: 5), // spacing between icon and text
                        Text('Unggah Gambar'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
