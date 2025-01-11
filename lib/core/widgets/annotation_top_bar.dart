import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class AnnotationTopBar extends StatelessWidget implements PreferredSizeWidget {
  final ValueNotifier<String?> selectedShapeNotifier;
  final ValueNotifier<Color> selectedColorNotifier;
  final ValueNotifier<double> selectedThicknessNotifier;
  final VoidCallback onRevert;

  const AnnotationTopBar({
    required this.selectedShapeNotifier,
    required this.selectedColorNotifier,
    required this.selectedThicknessNotifier,
    required this.onRevert,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(''),
      actions: [
        IconButton(
          icon: const Icon(Icons.undo),
          onPressed: onRevert,
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.build),
          onSelected: (String value) {
            selectedShapeNotifier.value = value;
          },
          itemBuilder: (BuildContext context) {
            return const [
              PopupMenuItem(value: 'Freehand', child: Text('Freehand')),
              PopupMenuItem(value: 'Rectangle', child: Text('Rectangle')),
              PopupMenuItem(value: 'Circle', child: Text('Circle')),
              PopupMenuItem(value: 'Line', child: Text('Line')),
              PopupMenuItem(
                  value: 'Horizontal Line', child: Text('Horizontal Line')),
              PopupMenuItem(
                  value: 'Vertical Line', child: Text('Vertical Line')),
              PopupMenuItem(value: 'Text', child: Text('Text')),
            ];
          },
        ),
        IconButton(
          icon: const Icon(Icons.color_lens),
          onPressed: () => _showColorPicker(context),
        ),
        IconButton(
          icon: const Icon(Icons.line_weight),
          onPressed: () => _showThicknessPicker(context),
        ),
      ],
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: selectedColorNotifier.value,
              onColorChanged: (Color color) {
                selectedColorNotifier.value = color;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  void _showThicknessPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Thickness'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Slider(
                value: selectedThicknessNotifier.value,
                min: 1.0,
                max: 10.0,
                divisions: 9,
                label: selectedThicknessNotifier.value.toStringAsFixed(1),
                onChanged: (double value) {
                  setState(() {
                    selectedThicknessNotifier.value = value;
                  });
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
