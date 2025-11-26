import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/core/theme/theme.dart';
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
    final state = ref.watch(returnProcessingNotifierProvider);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.summarize, color: Colors.orange.shade600, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Resumen de Devolución',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

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
            const Divider(height: 24),
            _buildSummaryRow(
              'Total a Reembolsar',
              '\$${(state.totalCents / 100.0).toStringAsFixed(2)}',
              isTotal: true,
            ),
            const SizedBox(height: 24),

            // Refund method
            const Text(
              'Método de Reembolso *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: RefundMethod.values.map((method) {
                final isSelected = state.refundMethod == method;
                return ChoiceChip(
                  label: Text(method.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      ref
                          .read(returnProcessingNotifierProvider.notifier)
                          .setRefundMethod(method);
                    }
                  },
                  selectedColor: Colors.orange.shade100,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.orange.shade900
                        : AppTheme.textPrimary,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Reason
            // Reason
            DropdownButtonFormField<ReturnReason>(
              isExpanded: true,
              value: _reasonController.text.isNotEmpty
                  ? ReturnReason.values.firstWhere(
                      (e) => e.label == _reasonController.text,
                      orElse: () => ReturnReason.other,
                    )
                  : null,
              decoration: const InputDecoration(
                labelText: 'Motivo de la Devolución *',
                border: OutlineInputBorder(),
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
                      .read(returnProcessingNotifierProvider.notifier)
                      .setGeneralReason(value.label);
                }
              },
            ),
            const SizedBox(height: 16),

            // Notes
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notas Adicionales (opcional)',
                hintText: 'Información adicional sobre la devolución...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                ref
                    .read(returnProcessingNotifierProvider.notifier)
                    .setNotes(value);
              },
            ),
            const SizedBox(height: 24),

            // Process button
            FilledButton.icon(
              onPressed: state.canProcess && !state.isProcessing
                  ? () => _processReturn()
                  : null,
              icon: state.isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.check_circle),
              label: Text(
                state.isProcessing ? 'Procesando...' : 'Procesar Devolución',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppTheme.textPrimary : AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 24 : 16,
            fontWeight: FontWeight.bold,
            color: isTotal ? Colors.orange.shade700 : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Future<void> _processReturn() async {
    final success = await ref
        .read(returnProcessingNotifierProvider.notifier)
        .processReturn();

    if (success && mounted) {
      // Success message is handled by the page listener
    }
  }
}
