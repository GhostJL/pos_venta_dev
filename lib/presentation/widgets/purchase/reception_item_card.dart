import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/purchase_item.dart';

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

  Widget _buildBadge(double value, Color color, String unit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '${value.toStringAsFixed(value % 1 == 0 ? 0 : 2)} $unit',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = item.quantity - item.quantityReceived;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Nombre del producto
            Text(
              item.productName ?? 'Producto',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            /// Badges + campo de entrada en una sola fila
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Badges en fila
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildBadge(
                        item.quantity,
                        Colors.blue.shade700,
                        item.unitOfMeasure,
                      ),
                      if (item.quantityReceived > 0)
                        _buildBadge(
                          item.quantityReceived,
                          Colors.green.shade700,
                          item.unitOfMeasure,
                        ),
                      _buildBadge(
                        remaining,
                        Colors.orange.shade700,
                        item.unitOfMeasure,
                      ),
                    ],
                  ),
                ),

                /// Campo de entrada compacto
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                    ),
                    style: const TextStyle(fontSize: 13),
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
