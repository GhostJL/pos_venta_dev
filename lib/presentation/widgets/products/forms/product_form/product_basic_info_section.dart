import 'dart:io';

import 'package:flutter/material.dart';
import 'package:posventa/presentation/widgets/shared/image_picker_widget.dart';
import 'package:posventa/presentation/widgets/common/misc/barcode_scanner_widget.dart';
import 'package:posventa/presentation/widgets/common/buttons/scanner_button.dart';

/// Widget for basic product information section
class ProductBasicInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController codeController;
  final TextEditingController descriptionController;
  final TextEditingController? barcodeController;

  // New callbacks
  final ValueChanged<String>? onNameChanged;
  final ValueChanged<String>? onCodeChanged;
  final ValueChanged<String>? onDescriptionChanged;

  // Image handling
  final File? imageFile;
  final String? photoUrl;
  final Function(File)? onImageSelected;
  final VoidCallback? onRemoveImage;

  const ProductBasicInfoSection({
    super.key,
    required this.nameController,
    required this.codeController,
    required this.descriptionController,
    this.barcodeController,
    this.onNameChanged,
    this.onCodeChanged,
    this.onDescriptionChanged,
    this.imageFile,
    this.photoUrl,
    this.onImageSelected,
    this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onImageSelected != null && onRemoveImage != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: ImagePickerWidget(
                imageFile: imageFile,
                imageUrl: photoUrl,
                onImageSelected: onImageSelected!,
                onRemoveImage: onRemoveImage!,
              ),
            ),
          ),
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
        const SizedBox(height: 16),
        TextFormField(
          controller: barcodeController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Código de Barras',
            helperText: 'EAN-13, UPC, o generado',
            prefixIcon: const Icon(Icons.qr_code_2),
            suffixIcon: ScannerButton(
              isCompact: true,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BarcodeScannerWidget(
                      onBarcodeScanned: (context, code) {
                        barcodeController?.text = code;
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
            barcodeController?.text = 'INT$timestamp';
          },
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                Icon(
                  Icons.qr_code_2,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Generar código interno',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: descriptionController,
          onChanged: onDescriptionChanged,
          maxLength: 255,
          maxLines: 3,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Descripción (Opcional)',
            prefixIcon: Icon(Icons.description),
          ),
        ),
      ],
    );
  }
}
