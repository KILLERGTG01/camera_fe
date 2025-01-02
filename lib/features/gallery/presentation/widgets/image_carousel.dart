import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImageCarousel extends StatefulWidget {
  final List<XFile> selectedImages;
  final Function(int index) onImageTap;
  final int highlightedIndex;

  const ImageCarousel({
    required this.selectedImages,
    required this.onImageTap,
    required this.highlightedIndex,
    super.key,
  });

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  void didUpdateWidget(covariant ImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Center the selected image unless it's a corner image
    if (widget.highlightedIndex > 0 &&
        widget.highlightedIndex < widget.selectedImages.length - 1) {
      _carouselController.animateToPage(widget.highlightedIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double carouselHeight = 60; // Same height as button (square)

    return CarouselSlider(
      items: widget.selectedImages.asMap().entries.map(
        (entry) {
          int index = entry.key;
          XFile image = entry.value;

          return GestureDetector(
            onTap: () => widget.onImageTap(index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: index == widget.highlightedIndex
                      ? Colors.teal // Highlight the selected image
                      : Colors.grey,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 1, // Force square aspect ratio
                  child: Image.file(
                    File(image.path),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        },
      ).toList(),
      carouselController: _carouselController,
      options: CarouselOptions(
        height: carouselHeight,
        enlargeCenterPage: true,
        enableInfiniteScroll: false,
        viewportFraction: 0.3, // Small carousel images
        autoPlay: false,
      ),
    );
  }
}
