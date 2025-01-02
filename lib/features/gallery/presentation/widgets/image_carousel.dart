import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImageCarousel extends StatelessWidget {
  final List<XFile> selectedImages;

  const ImageCarousel({required this.selectedImages, super.key});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: selectedImages
          .map(
            (image) => Container(
              margin: const EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(image.path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          )
          .toList(),
      options: CarouselOptions(
        height: 700,
        enlargeCenterPage: true,
        enableInfiniteScroll: true,
        aspectRatio: 10 / 7,
        autoPlay: false,
      ),
    );
  }
}
