import 'package:flutter/material.dart';

/// Widget for basic product information section
class ProductBasicInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController codeController;
  final TextEditingController barcodeController;
  final TextEditingController descriptionController;
  final VoidCallback onScanBarcode;
  final bool showBarcode;

  // New callbacks
  final ValueChanged<String>? onNameChanged;
  final ValueChanged<String>? onCodeChanged;
  final ValueChanged<String>? onBarcodeChanged;
  final ValueChanged<String>? onDescriptionChanged;

  const ProductBasicInfoSection({
    super.key,
    required this.nameController,
    required this.codeController,
    required this.barcodeController,
    required this.descriptionController,
    required this.onScanBarcode,
    this.showBarcode = true,
    this.onNameChanged,
    this.onCodeChanged,
    this.onBarcodeChanged,
    this.onDescriptionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: nameController,
          textInputAction: TextInputAction.next,
          onChanged: onNameChanged,
          decoration: const InputDecoration(
            labelText: 'Nombre del Producto',
            prefixIcon: Icon(Icons.shopping_bag),
          ),
          validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: codeController,
          textInputAction: TextInputAction.next,
          onChanged: onCodeChanged,
          decoration: const InputDecoration(
            labelText: 'Código / Referencia Interna',
            helperText: 'Código único para identificar el producto base',
            prefixIcon: Icon(Icons.tag),
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Requerido para la base de datos' : null,
        ),
        if (showBarcode) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: barcodeController,
            textInputAction: TextInputAction.next,
            onChanged: onBarcodeChanged,
            decoration: InputDecoration(
              labelText: 'Código de Barras Principal',
              helperText: 'Código de barras del producto base',
              prefixIcon: const Icon(Icons.qr_code),
              suffixIcon: IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: onScanBarcode,
                tooltip: 'Escanear',
              ),
            ),
            validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
          ),
        ],
        const SizedBox(height: 16),
        TextFormField(
          controller: descriptionController,
          onChanged: onDescriptionChanged,
          decoration: const InputDecoration(
            labelText: 'Descripción (Opcional)',
            prefixIcon: Icon(Icons.description),
          ),
          maxLines: 3,
        ),
      ],
    );
  }
}
