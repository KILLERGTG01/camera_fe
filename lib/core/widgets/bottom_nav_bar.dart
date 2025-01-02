import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});
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
              developer.log('Camera button pressed', name: 'BottomNavBar');
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.white),
            onPressed: () {
              developer.log('Video button pressed', name: 'BottomNavBar');
            },
          ),
          IconButton(
            icon: const Icon(Icons.image, color: Colors.white),
            onPressed: () {
              developer.log('Gallery button pressed', name: 'BottomNavBar');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              developer.log('Settings button pressed', name: 'BottomNavBar');
            },
          ),
        ],
      ),
    );
  }
}
