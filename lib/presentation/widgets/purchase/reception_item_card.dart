import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/purchase_item.dart';

/// Widget reutilizable para mostrar un item individual en el diálogo de recepción.
///
/// Muestra:
/// - Nombre del producto
/// - Cantidad pedida, recibida y pendiente
/// - Campo de entrada para cantidad a recibir
class ReceptionItemCard extends StatelessWidget {
  final PurchaseItem item;
  final TextEditingController controller;
  final ValueChanged<double> onQuantityChanged;

  const ReceptionItemCard({
    super.key,
    required this.item,
    required this.controller,
    required this.onQuantityChanged,
  });

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = item.quantity - item.quantityReceived;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.productName ?? 'Producto',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        'Pedido:',
                        '${item.quantity.toStringAsFixed(item.quantity % 1 == 0 ? 0 : 2)} ${item.unitOfMeasure}',
                        Colors.grey.shade700,
                      ),
                      if (item.quantityReceived > 0) ...[
                        const SizedBox(height: 4),
                        _buildInfoRow(
                          'Recibido:',
                          '${item.quantityReceived.toStringAsFixed(item.quantityReceived % 1 == 0 ? 0 : 2)} ${item.unitOfMeasure}',
                          Colors.green.shade700,
                        ),
                      ],
                      const SizedBox(height: 4),
                      _buildInfoRow(
                        'Pendiente:',
                        '${remaining.toStringAsFixed(remaining % 1 == 0 ? 0 : 2)} ${item.unitOfMeasure}',
                        Colors.orange.shade700,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Recibir',
                      suffixText: item.unitOfMeasure,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      final qty = double.tryParse(value) ?? 0;
                      onQuantityChanged(qty);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
