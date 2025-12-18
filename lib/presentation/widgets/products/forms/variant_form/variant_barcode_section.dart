import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/providers/variant_form_provider.dart';
import 'package:posventa/domain/entities/product_variant.dart';

class VariantBarcodeSection extends ConsumerWidget {
  final ProductVariant? variant;
  final TextEditingController barcodeController;

  const VariantBarcodeSection({
    super.key,
    this.variant,
    required this.barcodeController,
  });

  Future<void> _openBarcodeScanner(BuildContext context) async {
    final result = await context.push<String>('/scanner');
    if (result != null) {
      barcodeController.text = result;
    }
  }

  void _generateInternalCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    barcodeController.text = 'INT$timestamp';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final provider = variantFormProvider(variant);
    final barcodeError = ref.watch(provider.select((s) => s.barcodeError));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        TextFormField(
          controller: barcodeController,
          style: const TextStyle(fontFamily: 'monospace', letterSpacing: 1.2),
          decoration: InputDecoration(
            labelText: 'Código de Barras / SKU',
            hintText: 'Escanea o ingresa el código',
            helperText:
                'Este código identificará la variante en el punto de venta.',
            errorText: barcodeError,
            prefixIcon: const Icon(Icons.qr_code_2_rounded),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: barcodeController,
                  builder: (context, value, _) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 20),
                      onPressed: () => barcodeController.clear(),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.camera_alt_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () => _openBarcodeScanner(context),
                  tooltip: 'Escanear con cámara',
                ),
              ],
            ),
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Campo requerido' : null,
        ),

        const SizedBox(height: 12),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _generateInternalCode,
            icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
            label: const Text('Generar código interno'),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              textStyle: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
