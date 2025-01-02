import 'package:image_picker/image_picker.dart';

class ImageState {
  final List<XFile> selectedImages;
  final bool isPermissionGranted;

  ImageState({
    this.selectedImages = const [],
    this.isPermissionGranted = false,
  });

  ImageState copyWith({
    List<XFile>? selectedImages,
    bool? isPermissionGranted,
  }) {
    return ImageState(
      selectedImages: selectedImages ?? this.selectedImages,
      isPermissionGranted: isPermissionGranted ?? this.isPermissionGranted,
    );
  }
}
