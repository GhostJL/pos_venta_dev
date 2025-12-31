import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/providers/variant_form_provider.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/widgets/common/buttons/scanner_button.dart';

class VariantBarcodeSection extends ConsumerWidget {
  final ProductVariant? variant;
  final VariantType? initialType;
  final TextEditingController barcodeController;

  const VariantBarcodeSection({
    super.key,
    this.variant,
    this.initialType,
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
    final provider = variantFormProvider(variant, initialType: initialType);
    final barcodeError = ref.watch(provider.select((s) => s.barcodeError));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        TextFormField(
          controller: barcodeController,
          textInputAction: TextInputAction.next,
          style: const TextStyle(fontFamily: 'monospace', letterSpacing: 1.2),
          decoration: InputDecoration(
            labelText: 'Código de Barras / SKU',
            hintText: 'Escanea o ingresa el código',
            helperText: 'EAN-13 id. de la variante',
            errorText: barcodeError,
            prefixIcon: const Icon(Icons.qr_code_2),
            suffixIcon: ScannerButton(
              isCompact: true,

              onPressed: () => _openBarcodeScanner(context),
            ),
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Campo requerido' : null,
        ),

        const SizedBox(height: 12),
        InkWell(
          onTap: () => _generateInternalCode(),
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
      ],
    );
  }
}
