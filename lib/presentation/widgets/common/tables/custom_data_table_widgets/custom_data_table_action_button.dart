import 'package:flutter/material.dart';

class CustomDataTableActionButton extends StatelessWidget {
  final VoidCallback onAddItem;

  const CustomDataTableActionButton({super.key, required this.onAddItem});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onAddItem,
      icon: const Icon(Icons.add_rounded, size: 20),
      label: const Text('Agregar Nuevo'),
    );
  }
}
