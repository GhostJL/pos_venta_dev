import 'package:flutter/material.dart';

class ProductSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onScan;

  const ProductSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: onClear,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                isDense: true,
              ),
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: IconButton(
              icon: Icon(
                Icons.qr_code_scanner,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: onScan,
              tooltip: 'Escanear código',
            ),
          ),
        ],
      ),
    );
  }
}
