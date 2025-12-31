import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/providers/variant_form_provider.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/widgets/common/buttons/scanner_button.dart';

class VariantBarcodeSection extends ConsumerStatefulWidget {
  final ProductVariant? variant;
  final VariantType? initialType;
  final TextEditingController barcodeController;

  const VariantBarcodeSection({
    super.key,
    this.variant,
    this.initialType,
    required this.barcodeController,
  });

  @override
  ConsumerState<VariantBarcodeSection> createState() =>
      _VariantBarcodeSectionState();
}

class _VariantBarcodeSectionState extends ConsumerState<VariantBarcodeSection> {
  final _additionalController = TextEditingController();

  @override
  void dispose() {
    _additionalController.dispose();
    super.dispose();
  }

  Future<void> _openBarcodeScanner(
    BuildContext context, {
    required TextEditingController controller,
    bool autoAdd = false,
  }) async {
    final result = await context.push<String>('/scanner');
    if (result != null && mounted) {
      if (autoAdd) {
        final provider = variantFormProvider(
          widget.variant,
          initialType: widget.initialType,
        );
        ref.read(provider.notifier).addAdditionalBarcode(result);
      } else {
        controller.text = result;
      }
    }
  }

  void _generateInternalCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    widget.barcodeController.text = 'INT$timestamp';
  }

  void _addAdditionalBarcode() {
    if (_additionalController.text.isNotEmpty) {
      final provider = variantFormProvider(
        widget.variant,
        initialType: widget.initialType,
      );
      ref
          .read(provider.notifier)
          .addAdditionalBarcode(_additionalController.text);
      _additionalController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = variantFormProvider(
      widget.variant,
      initialType: widget.initialType,
    );
    final state = ref.watch(provider);
    final barcodeError = state.barcodeError;
    final additionalBarcodes = state.additionalBarcodes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // MAIN BARCODE
        TextFormField(
          controller: widget.barcodeController,
          textInputAction: TextInputAction.next,
          style: const TextStyle(fontFamily: 'monospace', letterSpacing: 1.2),
          decoration: InputDecoration(
            labelText: 'Código de Barras Principal / SKU',
            hintText: 'Escanea o ingresa el código',
            helperText: 'Identificador único principal de la variante',
            errorText: barcodeError,
            prefixIcon: const Icon(Icons.qr_code_2),
            suffixIcon: ScannerButton(
              isCompact: true,
              onPressed: () => _openBarcodeScanner(
                context,
                controller: widget.barcodeController,
              ),
            ),
          ),
          onChanged: (val) => ref.read(provider.notifier).updateBarcode(val),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Campo requerido' : null,
        ),

        const SizedBox(height: 8),
        InkWell(
          onTap: () => _generateInternalCode(),
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

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),

        // ADDITIONAL BARCODES HEADER
        Text(
          'Códigos Adicionales',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Puedes asociar múltiples códigos a esta variante para facilitar la búsqueda.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),

        // ADDITIONAL BARCODE INPUT
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
                    onPressed: () => _openBarcodeScanner(
                      context,
                      controller: _additionalController,
                      autoAdd: true,
                    ),
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

        // CHIPS LIST
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
                onDeleted: () =>
                    ref.read(provider.notifier).removeAdditionalBarcode(code),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
