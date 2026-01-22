import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:posventa/domain/entities/sale_return.dart';
import 'package:posventa/domain/entities/return_reason.dart';
import 'package:posventa/presentation/providers/return_processing_provider.dart';

class ReturnSummaryCard extends ConsumerStatefulWidget {
  const ReturnSummaryCard({super.key});

  @override
  ConsumerState<ReturnSummaryCard> createState() => _ReturnSummaryCardState();
}

class _ReturnSummaryCardState extends ConsumerState<ReturnSummaryCard> {
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(returnProcessingProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // This widget is now placed inside a container in the layout, so we don't need a Card here.
    // We treat it as the content of the summary section.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Totals Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              _buildSummaryRow(
                'Productos seleccionados',
                '${state.selectedItems.length}',
              ),
              const SizedBox(height: 12),
              _buildSummaryRow(
                'Subtotal',
                '\$${(state.totalGrossSubtotalCents / 100.0).toStringAsFixed(2)}',
              ),
              if (state.totalDiscountCents > 0) ...[
                const SizedBox(height: 8),
                _buildSummaryRow(
                  'Descuentos',
                  '-\$${(state.totalDiscountCents / 100.0).toStringAsFixed(2)}',
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
              const SizedBox(height: 8),
              _buildSummaryRow(
                'Impuestos',
                '\$${(state.totalTaxCents / 100.0).toStringAsFixed(2)}',
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1),
              ),
              _buildSummaryRow(
                'Total a Reembolsar',
                '\$${(state.totalCents / 100.0).toStringAsFixed(2)}',
                isTotal: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Refund method
        Text(
          'Método de Reembolso',
          style: theme.textTheme.labelLarge?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            children: RefundMethod.values.map((method) {
              final isSelected = state.refundMethod == method;
              return RadioListTile<RefundMethod>(
                value: method,
                groupValue: state.refundMethod,
                onChanged: (val) {
                  if (val != null) {
                    ref
                        .read(returnProcessingProvider.notifier)
                        .setRefundMethod(val);
                  }
                },
                title: Text(method.displayName),
                activeColor: cs.primary,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                tileColor: isSelected
                    ? cs.primaryContainer.withValues(alpha: 0.2)
                    : null,
                selected: isSelected,
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 24),

        // Global Reason & Notes
        Text(
          'Detalles Generales',
          style: theme.textTheme.labelLarge?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<ReturnReason>(
          isExpanded: true,
          initialValue: _reasonController.text.isNotEmpty
              ? ReturnReason.values.firstWhere(
                  (e) => e.label == _reasonController.text,
                  orElse: () => ReturnReason.other,
                )
              : null,
          decoration: InputDecoration(
            labelText: 'Motivo General *',
            isDense: true,
            filled: true,
            fillColor: cs.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: cs.outlineVariant),
            ),
          ),
          items: ReturnReason.values.map((reason) {
            return DropdownMenuItem(
              value: reason,
              child: Text(reason.label, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              _reasonController.text = value.label;
              ref
                  .read(returnProcessingProvider.notifier)
                  .setGeneralReason(value.label);
            }
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _notesController,
          decoration: InputDecoration(
            labelText: 'Notas Adicionales (opcional)',
            hintText: 'Comentarios sobre la devolución...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: cs.outlineVariant),
            ),
            filled: true, // Use surface color
            fillColor: cs.surface,
            isDense: true,
          ),
          maxLines: 3,
          style: const TextStyle(fontSize: 14),
          onChanged: (value) {
            ref.read(returnProcessingProvider.notifier).setNotes(value);
          },
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            label,
            style: isTotal
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )
                : theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: isTotal
              ? theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color ?? cs.primary,
                )
              : theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color ?? cs.onSurface,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
        ),
      ],
    );
  }
}
