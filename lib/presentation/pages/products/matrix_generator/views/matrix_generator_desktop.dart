import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/pages/products/matrix_generator/matrix_generator_controller.dart';
import 'package:posventa/presentation/pages/products/matrix_generator/widgets/attribute_input_step.dart';
import 'package:posventa/presentation/pages/products/matrix_generator/widgets/variant_preview_step.dart';

class MatrixGeneratorDesktop extends ConsumerWidget {
  final int productId;
  final VariantType targetType;
  final List<ProductVariant> existingVariants;
  final VoidCallback onCancel;
  final Function(List<ProductVariant>) onConfirm;

  const MatrixGeneratorDesktop({
    super.key,
    required this.productId,
    required this.targetType,
    required this.existingVariants,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(matrixGeneratorProvider(productId));

    return Row(
      children: [
        // Left: Attributes
        Expanded(
          flex: 4,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '1. Definir Atributos',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(child: AttributeInputStep(productId: productId)),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: state.attributes.isEmpty
                        ? null
                        : () {
                            ref
                                .read(
                                  matrixGeneratorProvider(productId).notifier,
                                )
                                .generateVariants();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Variantes generadas/actualizadas.',
                                ),
                                duration: Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                                width: 300,
                              ),
                            );
                          },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Generar / Actualizar Vista Previa'),
                  ),
                ),
              ),
            ],
          ),
        ),

        const VerticalDivider(width: 1),

        // Right: Preview
        Expanded(
          flex: 6,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '2. Vista Previa',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: VariantPreviewStep(
                  productId: productId,
                  targetType: targetType,
                  existingVariants: existingVariants,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: onCancel,
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 16),
                    FilledButton.icon(
                      onPressed: state.generatedVariants.isEmpty
                          ? null
                          : () {
                              final error = ref
                                  .read(
                                    matrixGeneratorProvider(productId).notifier,
                                  )
                                  .validate(targetType);

                              if (error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(error),
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.error,
                                  ),
                                );
                                return;
                              }

                              onConfirm(state.generatedVariants);
                            },
                      icon: const Icon(Icons.check),
                      label: Text(
                        'Confirmar (${state.generatedVariants.length})',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
