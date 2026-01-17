import 'dart:io';
import 'package:flutter/material.dart';

class ProductSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onScannerPressed;
  final FocusNode? focusNode;

  const ProductSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onScannerPressed,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            focusNode: focusNode,
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre, código o código de barras',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.clear();
                        onChanged('');
                      },
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (Platform.isAndroid || Platform.isIOS)
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
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
