import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/variant_form_provider.dart';
import 'package:posventa/domain/entities/product_variant.dart';

class VariantSettingsSection extends ConsumerWidget {
  final ProductVariant? variant;

  const VariantSettingsSection({super.key, this.variant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(variantFormProvider(variant));
    final notifier = ref.read(variantFormProvider(variant).notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configuración',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Disponible para Venta'),
          subtitle: const Text(
            'Si se desactiva, solo servirá para abastecimiento',
          ),
          value: state.isForSale,
          activeThumbColor: Theme.of(context).colorScheme.primary,
          onChanged: notifier.updateIsForSale,
        ),
      ],
    );
  }
}
