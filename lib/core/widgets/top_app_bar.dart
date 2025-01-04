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
        IconButton(
          icon: const Icon(Icons.draw_sharp),
          onPressed: () {
            developer.log('Selected shape: ', name: 'TopAppBar');
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
