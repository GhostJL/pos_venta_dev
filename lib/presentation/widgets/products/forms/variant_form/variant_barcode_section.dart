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
      _controller.text = result;
      ref
          .read(variantFormProvider(widget.variant).notifier)
          .updateBarcode(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(variantFormProvider(widget.variant));
    final notifier = ref.read(variantFormProvider(widget.variant).notifier);

    // Sync controller if state changes externally (though unlikely with this setup, good practice)
    if (state.barcode != _controller.text) {
      _controller.text = state.barcode;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Código de Barras'),
        const SizedBox(height: 16),
        TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'Código de Barras',
            helperText: 'Debe ser único en todo el sistema',
            errorText: state.barcodeError,
            prefixIcon: const Icon(Icons.qr_code),
            suffixIcon: IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: _openBarcodeScanner,
              tooltip: 'Escanear',
            ),
          ),
          onChanged: notifier.updateBarcode,
          validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    // Mapa de iconos para un toque visual (opcional)
    final Map<String, IconData> sectionIcons = {
      'Código de Barras': Icons.qr_code,
    };

    final icon = sectionIcons[title];

    return Padding(
      // Añadimos padding superior para asegurarnos de que el título esté bien separado de la sección anterior
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary, // Color de acento
            ),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: 18, // Ligeramente más grande para jerarquía
              fontWeight:
                  FontWeight.w700, // Más fuerte, pero sin ser negrita pura
              color: Theme.of(
                context,
              ).colorScheme.primary, // Color principal de texto
              letterSpacing: 0.5, // Un toque moderno
            ),
          ),
        ],
      ),
    );
  }
}
