import 'package:dewinter_gallery/features/camera/camera_page.dart';
import 'package:dewinter_gallery/features/video/video_page.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CameraPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.image, color: Colors.black),
            onPressed: () {
              developer.log('Gallery button pressed', name: 'BottomNavBar');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              developer.log('Settings button pressed', name: 'BottomNavBar');
            },
          ),
        ],
      ),
    );
  }
}
