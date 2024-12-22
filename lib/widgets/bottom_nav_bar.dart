import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class BottomNavBar extends StatelessWidget {
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;
  final Logger logger = Logger();

  BottomNavBar(
      {required this.onCameraPressed,
      required this.onGalleryPressed,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            onPressed: () {
              logger.d('Camera button pressed');
              onCameraPressed();
            },
          ),
          IconButton(
            icon: const Icon(Icons.photo_library, color: Colors.white),
            onPressed: () {
              logger.d('Gallery button pressed');
              onGalleryPressed();
            },
          ),
        ],
      ),
    );
  }
}
