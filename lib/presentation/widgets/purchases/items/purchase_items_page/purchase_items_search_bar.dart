import 'package:flutter/material.dart';

class PurchaseItemsSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const PurchaseItemsSearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar por producto...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
