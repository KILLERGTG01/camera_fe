import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'widgets/top_app_bar.dart';
import 'widgets/bottom_nav_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const PhotoScreen(),
    );
  }
}

class PhotoScreen extends StatefulWidget {
  const PhotoScreen({super.key});
  @override
  State<PhotoScreen> createState() {
    return _PhotoScreenState();
  }
}

class _PhotoScreenState extends State<PhotoScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  // Function to select a photo from the device gallery
  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  // Function to capture a photo using the camera
  Future<void> _captureImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(),
      body: Center(
        child: _selectedImage == null
            ? const Text('No image selected or captured',
                style: TextStyle(fontSize: 18))
            : Image.file(_selectedImage!, fit: BoxFit.cover),
      ),
      bottomNavigationBar: BottomNavBar(
        onCameraPressed: _captureImageFromCamera,
        onGalleryPressed: _pickImageFromGallery,
      ),
    );
  }
}
