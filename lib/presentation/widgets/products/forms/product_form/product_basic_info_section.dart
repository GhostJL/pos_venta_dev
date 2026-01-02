import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/presentation/providers/product_form_provider.dart';
import 'package:posventa/presentation/widgets/shared/image_picker_widget.dart';
import 'package:posventa/presentation/widgets/common/buttons/scanner_button.dart';

/// Widget for basic product information section with multi-barcode support
class ProductBasicInfoSection extends ConsumerStatefulWidget {
  final Product? product; // Needed to access provider
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
    this.product,
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
  ConsumerState<ProductBasicInfoSection> createState() =>
      _ProductBasicInfoSectionState();
}

class _ProductBasicInfoSectionState
    extends ConsumerState<ProductBasicInfoSection> {
  final _additionalController = TextEditingController();

  @override
  void dispose() {
    _additionalController.dispose();
    super.dispose();
  }

  Future<void> _openScanner(
    BuildContext context, {
    TextEditingController? controller,
    bool autoAdd = false,
  }) async {
    final result = await context.push<String>('/scanner');
    if (result != null && mounted) {
      if (autoAdd) {
        ref
            .read(productFormProvider(widget.product).notifier)
            .addAdditionalBarcode(result);
      } else if (controller != null) {
        controller.text = result;
        // Trigger onChanged if attached to notifier via listener in parent,
        // but parent listens to controller, so just setting text is fine?
        // Parent listener: _controllers.barcodeController.addListener(... notifier.setBarcode ...)
        // Yes, setting text triggers listener.
      }
    }
  }

  void _addAdditionalBarcode() {
    if (_additionalController.text.isNotEmpty) {
      ref
          .read(productFormProvider(widget.product).notifier)
          .addAdditionalBarcode(_additionalController.text);
      _additionalController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = productFormProvider(widget.product);
    final state = ref.watch(provider);
    final additionalBarcodes = state.additionalBarcodes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.onImageSelected != null && widget.onRemoveImage != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: ImagePickerWidget(
                imageFile: widget.imageFile,
                imageUrl: widget.photoUrl,
                onImageSelected: widget.onImageSelected!,
                onRemoveImage: widget.onRemoveImage!,
              ),
            ),
          ),
        TextFormField(
          controller: widget.nameController,
          textInputAction: TextInputAction.next,
          onChanged: widget.onNameChanged,
          decoration: const InputDecoration(
            labelText: 'Nombre del Producto',
            prefixIcon: Icon(Icons.shopping_bag),
          ),
          validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: widget.codeController,
          textInputAction: TextInputAction.next,
          onChanged: widget.onCodeChanged,
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
          controller: widget.barcodeController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Código de Barras Principal',
            helperText: 'EAN-13, UPC, o generado',
            prefixIcon: const Icon(Icons.qr_code_2),
            suffixIcon: ScannerButton(
              isCompact: true,
              onPressed: () =>
                  _openScanner(context, controller: widget.barcodeController),
            ),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
            widget.barcodeController?.text = 'I$timestamp';
          },
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.autorenew,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Generar código interno',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Multi-Barcode Section (Only shown if NOT variable product OR if we decide simple product needs it)
        // Actually, strictly speaking if "Is Variable", this section might be irrelevant?
        // But ProductBasicInfoSection is shown for BOTH.
        // For Variable products, "Main Barcode" on product might be just a reference or empty?
        // Usually, Variable Products have barcodes on Variants.
        // But some systems allow a "Master Barcode" for the generic product?
        // In our logic, 'barcode' field exists on Product entity.
        // But `additionalBarcodes` are stored on VARIANT.
        // If `isVariableProduct` is TRUE, then `ProductFormNotifier` logic for `additionalBarcodes` is... ambiguous?
        // `ProductFormNotifier.additionalBarcodes` logic:
        // `additionalBarcodes: (product.variants...isNotEmpty) ? first.additionalBarcodes : []`
        // It binds to the FIRST variant (Default/Standard).
        // If it's a Variable Product, we probably should HIDE the additional barcodes UI in BASIC info,
        // because users should manage barcodes in the "Variants" tab for each variant.
        // Let's hide it if `state.hasVariants` (or logic: isVariableProduct).
        if (!state.isVariableProduct) ...[
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Códigos Adicionales',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Puedes asociar múltiples códigos para este producto.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _additionalController,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    letterSpacing: 1.1,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Agregar Código Adicional',
                    hintText: 'Escanea o escribe...',
                    isDense: true,
                    prefixIcon: const Icon(Icons.add_link),
                    suffixIcon: ScannerButton(
                      isCompact: true,
                      onPressed: () => _openScanner(context, autoAdd: true),
                    ),
                  ),
                  onFieldSubmitted: (_) => _addAdditionalBarcode(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _addAdditionalBarcode,
                icon: const Icon(Icons.add),
                tooltip: 'Agregar',
              ),
            ],
          ),
          if (additionalBarcodes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: additionalBarcodes.map((code) {
                return Chip(
                  backgroundColor: theme.colorScheme.surface,
                  labelStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  deleteIconColor: theme.colorScheme.error,
                  avatar: const Icon(Icons.qr_code, size: 16),
                  label: Text(
                    code,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => ref
                      .read(productFormProvider(widget.product).notifier)
                      .removeAdditionalBarcode(code),
                );
              }).toList(),
            ),
          ],
        ],

        const SizedBox(height: 16),
        TextFormField(
          controller: widget.descriptionController,
          onChanged: widget.onDescriptionChanged,
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
