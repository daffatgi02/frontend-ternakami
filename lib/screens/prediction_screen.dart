// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ternakami/services/api_service.dart';
import 'package:flutter/services.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'hasilprediksi_screen.dart';
import 'package:uuid/uuid.dart';

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

  late AnimationController _scanController;
  late Animation<double> _scanAnimation;

  bool _isLoading = false;

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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _image != null
                        ? Image.file(File(_image!.path), height: 200)
                        : SizedBox(
                            height: 200,
                            child: Center(
                                child: Text(
                              'Tidak ada gambar yang di pilih',
                              style: GoogleFonts.poppins(),
                            )),
                          ),
                    const SizedBox(height: 20),
                    _image != null
                        ? ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _showCropScreen();
                            },
                            child: Text(
                              'Potong Gambar',
                              style: GoogleFonts.poppins(),
                            ),
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
                          child: Text(type, style: GoogleFonts.poppins()),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Tipe Hewan',
                        labelStyle: GoogleFonts.poppins(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _animalNameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Peliharaan',
                        labelStyle: GoogleFonts.poppins(),
                      ),
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
                          child: Text(
                            'Foto Ulang',
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _selectedType != null &&
                                  _animalNameController.text.isNotEmpty
                              ? () {
                                  Navigator.of(context).pop();
                                  _predict();
                                }
                              : null,
                          child: Text(
                            'Lanjutkan',
                            style: GoogleFonts.poppins(),
                          ),
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
            title: Text(
              'Potong Gambar',
              style: GoogleFonts.poppins(),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: _cropImage,
              ),
            ],
          ),
          body: _image != null
              ? Crop(
                  image: File(_image!.path).readAsBytesSync(),
                  controller: _cropController,
                  onCropped: (image) async {
                    final uuid = const Uuid().v4();
                    final tempDir = await getTemporaryDirectory();
                    final filePath = '${tempDir.path}/$uuid.png';
                    final file = File(filePath);
                    await file.writeAsBytes(image);

                    setState(() {
                      _image = XFile(filePath);
                    });

                    Navigator.of(context).pop();
                    _showImagePreview();
                  },
                )
              : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Future<void> _cropImage() async {
    _cropController.crop();
  }

  Future<void> _predict() async {
    setState(() {
      _isLoading = true;
    });

    if (_image == null ||
        _selectedType == null ||
        _animalNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Tolong isi semua data!",
            style: GoogleFonts.poppins(),
          ),
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Show loading dialog
    _showLoadingDialog();

    final Map<String, dynamic>? predictionResult = await _apiService.predict(
      widget.token,
      File(_image!.path),
      _selectedType!,
      _animalNameController.text,
    );

    // Hide loading dialog
    Navigator.of(context).pop();

    setState(() {
      _isLoading = false;
    });

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
        SnackBar(
          content: Text(
            "Gagal Melakukan Prediksi ! Laporkan Masalah ini!",
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    }

    // Hapus file gambar sementara setelah prediksi selesai
    final file = File(_image!.path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.blue,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LoadingAnimationWidget.fourRotatingDots(
                  color: Colors.white,
                  size: 60,
                ),
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Mohon Tunggu',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Text(
                        'Proses Sedang Berlangsung',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: _cameraController == null ||
                    !_cameraController!.value.isInitialized
                ? const Center(
                    child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ))
                : CameraPreview(_cameraController!),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: LoadingAnimationWidget.fourRotatingDots(
                    color: Colors.blue,
                    size: 50,
                  ),
                ),
              ),
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
                  Text(
                    'Sesuaikan posisi mata kambing agar memenuhi Frame',
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: _selectImageFromGallery,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.drive_folder_upload_rounded),
                        const SizedBox(width: 5),
                        Text('Unggah Gambar', style: GoogleFonts.poppins()),
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
