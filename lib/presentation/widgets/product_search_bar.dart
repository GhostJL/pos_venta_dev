import 'package:flutter/material.dart';

class ProductSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onScannerPressed;

  const ProductSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onScannerPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Buscar por nombre, código o código de barras',
              prefixIcon: Icon(Icons.search_rounded),
            ),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: Icon(
              Icons.qr_code_scanner,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: onScannerPressed,
            tooltip: 'Escanear código',
          ),
        ),
      ],
    );
  }
}
