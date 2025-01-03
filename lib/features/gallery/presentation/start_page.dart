import 'dart:io'; // Import for File class
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logic/image_notifier.dart';
import 'widgets/image_carousel.dart';
import '../../../core/widgets/base_scaffold.dart';

class StartPage extends ConsumerStatefulWidget {
  const StartPage({super.key});

  @override
  ConsumerState<StartPage> createState() => _StartPageState();
}

class _StartPageState extends ConsumerState<StartPage> {
  int _currentIndex = 0; // Track the selected image index

  @override
  Widget build(BuildContext context) {
    final imageState = ref.watch(imageNotifierProvider);
    final imageNotifier = ref.read(imageNotifierProvider.notifier);

    return BaseScaffold(
      body: Column(
        children: [
          // Display the highlighted image above the carousel
          Expanded(
            flex: 6,
            child: imageState.selectedImages.isEmpty
                ? const Center(
                    child: Text('No images selected.'),
                  )
                : Container(
                    padding: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(imageState.selectedImages[_currentIndex].path),
                        fit: BoxFit.contain, // Ensure the image is not cropped
                        width: double.infinity,
                      ),
                    ),
                  ),
          ),

          // Carousel with small images (same height as "Select Images" button)
          if (imageState.selectedImages.isNotEmpty)
            SizedBox(
              height: 60, // Height matching the button
              child: ImageCarousel(
                selectedImages: imageState.selectedImages,
                onImageTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                highlightedIndex: _currentIndex,
              ),
            ),

          // Positioned button at the bottom
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: ElevatedButton(
              onPressed: () => imageNotifier.pickImages(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(fontSize: 14),
              ),
              child: const Text('Select Images'),
            ),
          ),
        ],
      ),
    );
  }
}
