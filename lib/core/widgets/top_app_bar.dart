import 'package:dewinter_gallery/features/gallery/data/image_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:developer' as developer;
import 'package:dewinter_gallery/features/gallery/logic/image_notifier.dart';

class TopAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const TopAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageNotifier = ref.read(imageNotifierProvider.notifier);
    final imageState = ref.watch(imageNotifierProvider);

    return AppBar(
      title: const Text('PathPlus'),
      actions: [
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
            _deleteImage(context, imageNotifier, imageState);
          },
        ),
      ],
    );
  }

  void _shareImage(BuildContext context, ImageState imageState) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (imageState.selectedImages.isNotEmpty) {
      final String imagePath = imageState.selectedImages.first.path;

      // Share the selected image
      Share.shareXFiles(
        [XFile(imagePath)],
        text: 'Shared with PathPlus',
      );
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('No image selected to share.')),
      );
    }
  }

  void _deleteImage(
    BuildContext context,
    ImageNotifier imageNotifier,
    ImageState imageState,
  ) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (imageState.selectedImages.isNotEmpty) {
      final String imagePath = imageState.selectedImages.first.path;

      imageNotifier.deleteImage(imagePath);

      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Image deleted successfully.')),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('No image selected to delete.')),
      );
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
