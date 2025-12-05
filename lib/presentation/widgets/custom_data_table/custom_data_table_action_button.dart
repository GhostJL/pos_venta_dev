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
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
