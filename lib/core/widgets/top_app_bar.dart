import 'package:dewinter_gallery/features/annotations/annotation_page.dart';
import 'package:dewinter_gallery/features/gallery/data/image_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import 'package:share_plus/share_plus.dart';
import 'package:dewinter_gallery/features/gallery/logic/image_notifier.dart';

class TopAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final GlobalKey appBarKey = GlobalKey();
  TopAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageNotifier = ref.read(imageNotifierProvider.notifier);
    final imageState = ref.watch(imageNotifierProvider);

    return AppBar(
      key: appBarKey,
      title: const Text('PathPlus'),
      actions: [
        IconButton(
          icon: const Icon(Icons.colorize_sharp),
          onPressed: () {
            _navigateToAnnotation(context, imageState);
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

  void _navigateToAnnotation(BuildContext context, ImageState imageState) {
    if (imageState.selectedImages.isNotEmpty) {
      final String imagePath = imageState.selectedImages.first.path;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnnotationPage(imagePath: imagePath),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected for annotation.')),
      );
    }
  }

  void _shareImage(BuildContext context, ImageState imageState) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (imageState.selectedImages.isNotEmpty) {
      final String imagePath = imageState.selectedImages.first.path;

      try {
        // Obtain the RenderBox using the GlobalKey
        final RenderBox renderBox =
            appBarKey.currentContext?.findRenderObject() as RenderBox;

        await Share.shareXFiles(
          [XFile(imagePath)],
          text: 'Shared with PathPlus',
          sharePositionOrigin:
              renderBox.localToGlobal(Offset.zero) & renderBox.size,
        );
      } catch (e) {
        developer.log('Error sharing image: $e', name: 'TopAppBar');
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Failed to share image.')),
        );
      }
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
