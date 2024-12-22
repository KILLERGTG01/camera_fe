import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  TopAppBar({super.key});
  final Logger logger = Logger();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.menu),
          onSelected: (String value) {
            logger.i('Selected option: $value');
          },
          itemBuilder: (BuildContext context) {
            return [
              const PopupMenuItem(value: 'Option 1', child: Text('Option 1')),
              const PopupMenuItem(value: 'Option 2', child: Text('Option 2')),
            ];
          },
        ),
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            logger.d('Return button pressed');
          },
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            logger.i('Share button pressed');
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            logger.w('Delete button pressed');
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
