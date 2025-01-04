import 'package:flutter/material.dart';

class AnnotationTopBar extends StatelessWidget implements PreferredSizeWidget {
  final ValueNotifier<String?> selectedShapeNotifier;
  final VoidCallback onRevert;

  const AnnotationTopBar({
    required this.selectedShapeNotifier,
    required this.onRevert,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Annotation Tools'),
      actions: [
        IconButton(
          icon: const Icon(Icons.undo),
          onPressed: onRevert,
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.menu),
          onSelected: (String value) {
            selectedShapeNotifier.value = value;
          },
          itemBuilder: (BuildContext context) {
            return const [
              PopupMenuItem(value: 'Freehand', child: Text('Freehand')),
              PopupMenuItem(value: 'Rectangle', child: Text('Rectangle')),
              PopupMenuItem(value: 'Circle', child: Text('Circle')),
              PopupMenuItem(value: 'Line', child: Text('Line')),
            ];
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
