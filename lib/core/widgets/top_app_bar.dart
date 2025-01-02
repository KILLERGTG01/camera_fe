import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:developer' as developer;

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? selectedImagePath; // Path to the image to be shared

  const TopAppBar({super.key, this.selectedImagePath});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Gallery App'),
      actions: [
        // Dropdown Menu Button
        PopupMenuButton<String>(
          icon: const Icon(Icons.menu),
          onSelected: (String value) {
            developer.log('Selected option: $value', name: 'TopAppBar');
          },
          itemBuilder: (BuildContext context) {
            return [
              const PopupMenuItem(value: 'Option 1', child: Text('Option 1')),
              const PopupMenuItem(value: 'Option 2', child: Text('Option 2')),
              const PopupMenuItem(value: 'Option 3', child: Text('Option 3')),
              const PopupMenuItem(value: 'Option 4', child: Text('Option 4')),
            ];
          },
        ),
        // Share Button
        IconButton(
          icon: const Icon(Icons.ios_share_outlined),
          onPressed: () => _shareImage(context),
        ),
        // Delete Button
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            developer.log('Delete button pressed', name: 'TopAppBar');
          },
        ),
      ],
    );
  }

  void _shareImage(BuildContext context) async {
    if (selectedImagePath != null) {
      try {
        await Share.shareXFiles(
          [XFile(selectedImagePath!)],
          text: 'Check out this image!',
        );
        developer.log('Image shared successfully', name: 'TopAppBar');
      } catch (e) {
        developer.log('Error sharing image: $e', name: 'TopAppBar');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to share image.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected to share.')),
      );
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
