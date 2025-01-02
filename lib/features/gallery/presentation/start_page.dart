import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logic/image_notifier.dart';
import 'widgets/image_carousel.dart';
import '../../../core/widgets/base_scaffold.dart';

class StartPage extends ConsumerWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageState = ref.watch(imageNotifierProvider);
    final imageNotifier = ref.read(imageNotifierProvider.notifier);

    return BaseScaffold(
      body: Stack(
        children: [
          // Main content: Images or "No images selected" text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              imageState.selectedImages.isEmpty
                  ? const Center(child: Text('No images selected.'))
                  : ImageCarousel(selectedImages: imageState.selectedImages),
            ],
          ),

          // Positioned button at the center bottom above the bottom navigation bar
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20, // Above nav bar
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () => imageNotifier.pickImages(),
                child: const Text('Select Images'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
