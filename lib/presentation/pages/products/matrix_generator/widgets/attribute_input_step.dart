import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/pages/products/matrix_generator/matrix_generator_controller.dart';

class AttributeInputStep extends ConsumerStatefulWidget {
  final int productId;

  const AttributeInputStep({super.key, required this.productId});

  @override
  ConsumerState<AttributeInputStep> createState() => _AttributeInputStepState();
}

class _AttributeInputStepState extends ConsumerState<AttributeInputStep> {
  final TextEditingController _attributeNameController =
      TextEditingController();
  final TextEditingController _valueController = TextEditingController();

  // State to track which attribute is currently being edited for adding values
  int? _activeAttributeIndex;

  @override
  void dispose() {
    _attributeNameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _addAttribute() {
    if (_attributeNameController.text.trim().isEmpty) return;

    ref
        .read(matrixGeneratorProvider(widget.productId).notifier)
        .addAttribute(_attributeNameController.text.trim());

    _attributeNameController.clear();
  }

  void _addValue(int attributeIndex) {
    if (_valueController.text.trim().isEmpty) return;

    ref
        .read(matrixGeneratorProvider(widget.productId).notifier)
        .addValueToAttribute(attributeIndex, _valueController.text.trim());

    _valueController.clear();
    // Keep focus or something? For now just clear.
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(matrixGeneratorProvider(widget.productId));
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paso 1: Definir Atributos',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega las características de tus productos, como Talla, Color o Material. El sistema generará todas las combinaciones posibles.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Add Attribute Section
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _attributeNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Atributo',
                    hintText: 'Ej. Talla, Color',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _addAttribute(),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _addAttribute,
                icon: const Icon(Icons.add),
                label: const Text('Agregar'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Attributes List
          if (state.attributes.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 48,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay atributos definidos',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.attributes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final attribute = state.attributes[index];
                final isEditing = _activeAttributeIndex == index;

                return Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              attribute.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: theme.colorScheme.error,
                              onPressed: () => ref
                                  .read(
                                    matrixGeneratorProvider(
                                      widget.productId,
                                    ).notifier,
                                  )
                                  .removeAttribute(index),
                            ),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ...attribute.values.map(
                              (value) => Chip(
                                label: Text(value),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () => ref
                                    .read(
                                      matrixGeneratorProvider(
                                        widget.productId,
                                      ).notifier,
                                    )
                                    .removeValueFromAttribute(index, value),
                                backgroundColor: theme.colorScheme.surface,
                                deleteIconColor: theme.colorScheme.error,
                                labelStyle: theme.textTheme.bodyMedium
                                    ?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                side: BorderSide(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ),
                            ActionChip(
                              backgroundColor: theme.colorScheme.surface,
                              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                              label: Text(
                                'Agregar Valor',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              avatar: const Icon(Icons.add, size: 16),
                              onPressed: () {
                                setState(() {
                                  _activeAttributeIndex = index;
                                });
                                // Small hack to create a dialog for input
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(
                                      'Agregar valor para ${attribute.name}',
                                    ),
                                    content: TextField(
                                      controller: _valueController,
                                      autofocus: true,
                                      decoration: const InputDecoration(
                                        hintText: 'Ej. Rojo, Grande',
                                      ),
                                      onSubmitted: (_) {
                                        _addValue(index);
                                        Navigator.pop(context);
                                      },
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancelar'),
                                      ),
                                      FilledButton(
                                        onPressed: () {
                                          _addValue(index);
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Agregar'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
