import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/pages/products/matrix_generator/matrix_generator_controller.dart';
import 'package:posventa/presentation/pages/products/matrix_generator/widgets/attribute_input_step.dart';
import 'package:posventa/presentation/pages/products/matrix_generator/widgets/variant_preview_step.dart';

class MatrixGeneratorPage extends ConsumerStatefulWidget {
  final int productId;
  final VariantType targetType;
  final List<ProductVariant> existingVariants;

  const MatrixGeneratorPage({
    super.key,
    required this.productId,
    this.targetType = VariantType.sales,
    this.existingVariants = const [],
  });

  @override
  ConsumerState<MatrixGeneratorPage> createState() =>
      _MatrixGeneratorPageState();
}

class _MatrixGeneratorPageState extends ConsumerState<MatrixGeneratorPage> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(matrixGeneratorProvider(widget.productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generador de Variantes'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Custom Stepper Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStepIndicator(theme, 0, 'Atributos'),
                _buildConnector(theme),
                _buildStepIndicator(theme, 1, 'Revisión'),
              ],
            ),
          ),

          Expanded(
            child: _currentStep == 0
                ? AttributeInputStep(productId: widget.productId)
                : VariantPreviewStep(
                    productId: widget.productId,
                    targetType: widget.targetType,
                    existingVariants: widget.existingVariants,
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
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
        child: SafeArea(
          // Ensure buttons are clickable on mobile
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStep == 0)
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Cancelar'),
                )
              else
                OutlinedButton(
                  onPressed: () => setState(() => _currentStep = 0),
                  child: const Text('Atrás'),
                ),

              if (_currentStep == 0)
                FilledButton(
                  onPressed: state.attributes.isEmpty
                      ? null
                      : () {
                          ref
                              .read(
                                matrixGeneratorProvider(
                                  widget.productId,
                                ).notifier,
                              )
                              .generateVariants();
                          setState(() => _currentStep = 1);
                        },
                  child: const Text('Siguiente'),
                )
              else
                FilledButton.icon(
                  onPressed: state.generatedVariants.isEmpty
                      ? null
                      : () {
                          context.pop(state.generatedVariants);
                        },
                  icon: const Icon(Icons.check),
                  label: Text('Confirmar (${state.generatedVariants.length})'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(ThemeData theme, int index, String label) {
    final isActive = _currentStep == index;
    final isCompleted = _currentStep > index;
    final color = isActive || isCompleted
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primary
                : (isCompleted
                      ? theme.colorScheme.primary
                      : Colors.transparent),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: isCompleted
                ? Icon(
                    Icons.check,
                    size: 16,
                    color: theme.colorScheme.onPrimary,
                  )
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isActive
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: isActive || isCompleted
                ? FontWeight.bold
                : FontWeight.normal,
            color: isActive || isCompleted
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildConnector(ThemeData theme) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: _currentStep > 0
          ? theme.colorScheme.primary
          : theme.colorScheme.outlineVariant,
    );
  }
}
