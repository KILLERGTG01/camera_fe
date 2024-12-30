import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TopAppBar({super.key});
  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        // Dropdown Menu Button
        PopupMenuButton<String>(
          icon: const Icon(Icons.menu),
          onSelected: (String value) {
            developer.log('Selected option: $value', name: 'TopAppBar');
          },
          itemBuilder: (BuildContext context) {
            return [
              const PopupMenuItem(value: 'Option 1', child: Text('Option 1')),
              const PopupMenuItem(value: 'Option 2', child: Text('Option 2')),
              const PopupMenuItem(value: 'Option 3', child: Text('Option 3')),
              const PopupMenuItem(value: 'Option 4', child: Text('Option 4')),
            ];
          },
        ),
        // Return Button
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            developer.log('Return button pressed', name: 'TopAppBar');
            Navigator.pop(context);
          },
        ),
        // Share Button
        IconButton(
          icon: const Icon(Icons.ios_share_outlined),
          onPressed: () {
            developer.log('Share button pressed', name: 'TopAppBar');
          },
        ),
        // Delete Button
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            developer.log('Delete button pressed', name: 'TopAppBar');
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
