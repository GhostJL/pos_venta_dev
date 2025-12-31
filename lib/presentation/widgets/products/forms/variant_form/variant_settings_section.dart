import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/product_variant.dart';

class VariantSettingsSection extends ConsumerWidget {
  final ProductVariant? variant;
  final TextEditingController stockMinController;
  final TextEditingController stockMaxController;

  const VariantSettingsSection({
    super.key,
    this.variant,
    required this.stockMinController,
    required this.stockMaxController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          'Límites de Inventario',
          Icons.analytics_outlined,
        ),

        const SizedBox(height: 8),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CAMPO: STOCK MÍNIMO
            TextFormField(
              controller: stockMinController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Stock Mínimo',
                helperText: 'Alerta de resurtido',
                prefixIcon: Icon(
                  Icons.notifications_active_outlined,
                  color: theme.colorScheme.error.withValues(alpha: 0.7),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return null;
                final n = double.tryParse(value);
                if (n == null || n < 0) return 'Inválido';
                return null;
              },
            ),

            const SizedBox(height: 16),

            // CAMPO: STOCK MÁXIMO
            TextFormField(
              controller: stockMaxController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Stock Máximo',
                helperText: 'Capacidad ideal',
                prefixIcon: Icon(Icons.inventory_2_outlined),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return null;
                final n = double.tryParse(value);
                if (n == null || n < 0) return 'Inválido';

                // Validación lógica cruzada
                final min = double.tryParse(stockMinController.text) ?? 0;
                if (n < min) return 'Debe ser > Mín';

                return null;
              },
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Mensaje informativo contextual
        _buildInfoCard(theme),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.primary,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Establecer estos límites te ayudará a generar órdenes de compra automáticas y evitar quiebres de stock.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
