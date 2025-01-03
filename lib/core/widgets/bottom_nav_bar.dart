import 'package:dewinter_gallery/features/camera/camera_page.dart';
import 'package:dewinter_gallery/features/gallery/presentation/start_page.dart';
import 'package:dewinter_gallery/features/video/video_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer' as developer;
import 'package:dewinter_gallery/features/gallery/logic/image_notifier.dart';
import 'package:permission_handler/permission_handler.dart';

class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageNotifier = ref.read(imageNotifierProvider.notifier);

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
            onPressed: () async {
              try {
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                );

                if (image != null) {
                  developer.log('Image selected: ${image.path}',
                      name: 'BottomNavBar');

                  // Update the state with the selected image
                  await imageNotifier.addImageFromPath(image.path);

                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StartPage(),
                      ),
                    );
                  }
                } else {
                  developer.log('No image selected', name: 'BottomNavBar');
                }
              } catch (e) {
                developer.log('Error picking image: $e', name: 'BottomNavBar');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () async {
              final bool isOpened = await openAppSettings();
              if (!isOpened && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Unable to open app settings.'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
