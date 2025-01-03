import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../data/image_state.dart';

class ImageNotifier extends StateNotifier<ImageState> {
  final ImagePicker _imagePicker = ImagePicker();

  ImageNotifier() : super(ImageState());

  Future<void> requestPermission() async {
    PermissionStatus status;

    if (Platform.isIOS) {
      status = await Permission.photos.request();
    } else if (Platform.isAndroid) {
      status = await Permission.storage.request();
    } else {
      throw UnsupportedError("Unsupported platform");
    }

    if (status.isGranted) {
      state = state.copyWith(isPermissionGranted: true);
    } else {
      state = state.copyWith(isPermissionGranted: false);
    }
  }

  Future<void> pickImages() async {
    if (!state.isPermissionGranted) {
      await requestPermission();
    }

    if (state.isPermissionGranted) {
      try {
        final List<XFile> images = await _imagePicker.pickMultiImage();

        if (images.isNotEmpty) {
          state = state.copyWith(
            selectedImages: images.take(10).toList(),
          );
        }
      } catch (e) {
        _logError('Error picking images', e);
      }
    } else {
      _logWarning('Permission not granted to access the gallery.');
    }
  }

  /// Add a single image to the state
  Future<void> addImageFromPath(String path) async {
    if (state.selectedImages.length < 10) {
      state = state.copyWith(
        selectedImages: [
          ...state.selectedImages,
          XFile(path),
        ],
      );
    } else {
      _logWarning('Maximum number of images reached.');
    }
  }

  /// Delete an image from the state
  void deleteImage(String path) {
    final updatedImages =
        state.selectedImages.where((image) => image.path != path).toList();

    state = state.copyWith(selectedImages: updatedImages);

    _logInfo('Image deleted successfully: $path');
  }

  void _logError(String message, Object error) {
    debugPrint('$message: $error');
  }

  void _logWarning(String message) {
    debugPrint('Warning: $message');
  }

  void _logInfo(String message) {
    debugPrint('Info: $message');
  }
}

final imageNotifierProvider =
    StateNotifierProvider<ImageNotifier, ImageState>((ref) {
  return ImageNotifier();
});
