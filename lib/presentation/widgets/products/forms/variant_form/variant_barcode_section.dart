import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/providers/variant_form_provider.dart';
import 'package:posventa/domain/entities/product_variant.dart';

class VariantBarcodeSection extends ConsumerStatefulWidget {
  final ProductVariant? variant;

  const VariantBarcodeSection({super.key, this.variant});

  @override
  ConsumerState<VariantBarcodeSection> createState() =>
      _VariantBarcodeSectionState();
}

class _VariantBarcodeSectionState extends ConsumerState<VariantBarcodeSection> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final state = ref.read(variantFormProvider(widget.variant));
    _controller = TextEditingController(text: state.barcode);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openBarcodeScanner() async {
    final result = await context.push<String>('/scanner');
    if (result != null && mounted) {
      _updateBarcodeValue(result);
    }
  }

  void _generateInternalCode() {
    // Lógica para generar un código único temporal (puedes ajustarla a tu backend)
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final internalCode = 'INT$timestamp';
    _updateBarcodeValue(internalCode);
  }

  void _updateBarcodeValue(String value) {
    _controller.text = value;
    ref.read(variantFormProvider(widget.variant).notifier).updateBarcode(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(variantFormProvider(widget.variant));
    final notifier = ref.read(variantFormProvider(widget.variant).notifier);

    // Sincronización del controlador
    if (state.barcode != _controller.text) {
      _controller.text = state.barcode;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // Campo de Texto con Estilo Monoespaciado
        TextFormField(
          controller: _controller,
          style: const TextStyle(
            fontFamily: 'monospace', // Mejor legibilidad para códigos
            letterSpacing: 1.2,
          ),
          decoration: InputDecoration(
            labelText: 'Código de Barras / SKU',
            hintText: 'Escanea o ingresa el código',
            helperText:
                'Este código identificará la variante en el punto de venta.',
            errorText: state.barcodeError,
            prefixIcon: const Icon(Icons.qr_code_2_rounded),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_controller.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 20),
                    onPressed: () => _updateBarcodeValue(''),
                  ),
                IconButton(
                  icon: Icon(
                    Icons.camera_alt_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: _openBarcodeScanner,
                  tooltip: 'Escanear con cámara',
                ),
              ],
            ),
          ),
          onChanged: notifier.updateBarcode,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Campo requerido' : null,
        ),

        const SizedBox(height: 12),

        // Botón de Acción Secundaria: Generar código
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
