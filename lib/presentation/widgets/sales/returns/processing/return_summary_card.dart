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

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.summarize_outlined,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Resumen de Devolución',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Divider(
                height: 1,
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),

            // Items count
            _buildSummaryRow(
              'Productos seleccionados',
              '${state.selectedItems.length}',
            ),
            const SizedBox(height: 12),

            // Totals
            _buildSummaryRow(
              'Subtotal',
              '\$${(state.totalSubtotalCents / 100.0).toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Impuestos',
              '\$${(state.totalTaxCents / 100.0).toStringAsFixed(2)}',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Divider(
                height: 1,
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            _buildSummaryRow(
              'Total a Reembolsar',
              '\$${(state.totalCents / 100.0).toStringAsFixed(2)}',
              isTotal: true,
            ),
            const SizedBox(height: 24),

            // Refund method
            Text(
              'Método de Reembolso *',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: RefundMethod.values.map((method) {
                final isSelected = state.refundMethod == method;
                return ChoiceChip(
                  label: Text(method.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      ref
                          .read(returnProcessingProvider.notifier)
                          .setRefundMethod(method);
                    }
                  },
                  showCheckmark: false,
                  avatar: isSelected
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: Theme.of(context).colorScheme.onPrimary,
                        )
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? Colors.transparent
                        : Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Reason
            DropdownButtonFormField<ReturnReason>(
              isExpanded: true,
              initialValue: _reasonController.text.isNotEmpty
                  ? ReturnReason.values.firstWhere(
                      (e) => e.label == _reasonController.text,
                      orElse: () => ReturnReason.other,
                    )
                  : null,
              decoration: InputDecoration(
                labelText: 'Motivo de la Devolución *',
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
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

            // Notes
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notas Adicionales (opcional)',
                hintText: 'Información adicional sobre la devolución...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isDense: true,
              ),
              maxLines: 3,
              style: const TextStyle(fontSize: 14),
              onChanged: (value) {
                ref.read(returnProcessingProvider.notifier).setNotes(value);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: isTotal
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
