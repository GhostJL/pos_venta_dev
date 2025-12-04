import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:intl/intl.dart';

/// Diálogo de confirmación para anular una transacción
class TransactionVoidDialog {
  static Future<String?> show(BuildContext context, Sale sale) async {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.warning_rounded,
                color: Theme.of(context).colorScheme.error,
                size: 24,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text('Anular Transacción', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Warning message
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange.shade700,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Esta acción no se puede deshacer. El inventario será restaurado automáticamente.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Sale details
                _buildDetailRow(context, 'Número de venta', sale.saleNumber),
                SizedBox(height: 8),
                _buildDetailRow(
                  context,
                  'Fecha',
                  DateFormat('dd/MM/yyyy HH:mm').format(sale.saleDate),
                ),
                SizedBox(height: 8),
                _buildDetailRow(
                  context,
                  'Total',
                  '\$${(sale.totalCents / 100).toStringAsFixed(2)}',
                  isHighlight: true,
                ),
                SizedBox(height: 8),
                _buildDetailRow(context, 'Productos', '${sale.items.length}'),

                SizedBox(height: 20),
                Divider(),
                SizedBox(height: 16),

                // Reason field
                Text(
                  'Motivo de anulación *',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: reasonController,
                  maxLines: 3,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText:
                        'Ej: Cliente solicitó cancelación, error en el pedido...',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El motivo es obligatorio';
                    }
                    if (value.trim().length < 10) {
                      return 'El motivo debe tener al menos 10 caracteres';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(dialogContext).pop(reasonController.text.trim());
              }
            },
            icon: Icon(Icons.cancel_rounded),
            label: Text('Anular Venta'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            fontSize: isHighlight ? 16 : 14,
            color: isHighlight
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
