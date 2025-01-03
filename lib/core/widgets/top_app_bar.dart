import 'package:dewinter_gallery/features/gallery/data/image_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:developer' as developer;
import 'package:dewinter_gallery/features/gallery/logic/image_notifier.dart';
import 'dart:io';

class TopAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const TopAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the current state of ImageNotifier
    final imageState = ref.watch(imageNotifierProvider);

    return AppBar(
      title: const Text(''),
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
          onPressed: () {
            _shareImage(context, imageState);
          },
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

  void _shareImage(BuildContext context, ImageState imageState) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (imageState.selectedImages.isNotEmpty) {
      final String imagePath = imageState.selectedImages.first.path;

      // Log and check file existence
      final file = File(imagePath);
      if (!file.existsSync()) {
        developer.log('File does not exist at path: $imagePath',
            name: 'TopAppBar');
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Image file not found.')),
        );
        return;
      }

      developer.log('Sharing file: $imagePath', name: 'TopAppBar');

      Share.shareXFiles(
        [XFile(imagePath)],
        text: 'Check out this image!',
      ).then((_) {
        developer.log('Image shared successfully', name: 'TopAppBar');
      }).catchError((e) {
        developer.log('Error sharing image: $e', name: 'TopAppBar');
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Failed to share image.')),
        );
      });
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('No image selected to share.')),
      );
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
