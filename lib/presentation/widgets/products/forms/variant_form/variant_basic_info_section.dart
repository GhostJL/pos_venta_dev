import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/variant_form_provider.dart';
import 'package:posventa/domain/entities/product_variant.dart';

class VariantBasicInfoSection extends ConsumerWidget {
  final ProductVariant? variant;

  const VariantBasicInfoSection({super.key, this.variant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(variantFormProvider(variant));
    final notifier = ref.read(variantFormProvider(variant).notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información Básica',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: state.name,
          decoration: const InputDecoration(
            labelText: 'Nombre de la Variante',
            helperText: 'Ej: Caja con 12, Paquete de 6, etc.',
            prefixIcon: Icon(Icons.label),
          ),
          onChanged: notifier.updateName,
          validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: state.quantity,
          decoration: const InputDecoration(
            labelText: 'Cantidad / Factor',
            helperText: 'Cuántas unidades base contiene esta variante',
            prefixIcon: Icon(Icons.numbers),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: notifier.updateQuantity,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Requerido';
            final number = double.tryParse(value!);
            if (number == null || number <= 0) {
              return 'Debe ser mayor a 0';
            }
            return null;
          },
        ),
      ],
    );
  }
}
