import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'descriptionpage.dart';

class PredictorPage extends StatefulWidget {
  @override
  _PredictorPageState createState() => _PredictorPageState();
}

class _PredictorPageState extends State<PredictorPage> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  FlashMode _flashMode = FlashMode.auto;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.max);
    await _cameraController!.initialize();
    await _cameraController!.setFlashMode(_flashMode); // Set initial flash mode
    if (!mounted) return;
    setState(() {
      _isCameraInitialized = true;
    });
  }

  void _toggleFlash() {
    setState(() {
      if (_flashMode == FlashMode.auto) {
        _flashMode = FlashMode.always;
      } else if (_flashMode == FlashMode.always) {
        _flashMode = FlashMode.off;
      } else {
        _flashMode = FlashMode.auto;
      }
      _cameraController?.setFlashMode(_flashMode);
    });
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    final XFile file = await _cameraController!.takePicture();
    setState(() {
      _image = File(file.path);
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsPage(image: _image!),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailsPage(image: _image!),
        ),
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
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          _isCameraInitialized
              ? Positioned.fill(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _cameraController!.value.previewSize!.height,
                      height: _cameraController!.value.previewSize!.width,
                      child: CameraPreview(_cameraController!),
                    ),
                  ),
                )
              : Center(child: CircularProgressIndicator()),

          // Back Button
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Flash Control Button
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: Icon(
                _flashMode == FlashMode.auto
                    ? Icons.flash_auto
                    : _flashMode == FlashMode.always
                        ? Icons.flash_on
                        : Icons.flash_off,
                color: Colors.white,
                size: 30,
              ),
              onPressed: _toggleFlash,
            ),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 4),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              SizedBox(height: 200),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    onPressed: _takePicture,
                    child: Icon(Icons.camera),
                  ),
                  SizedBox(width: 30),
                  FloatingActionButton(
                    onPressed: _pickImageFromGallery,
                    child: Icon(Icons.image),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
