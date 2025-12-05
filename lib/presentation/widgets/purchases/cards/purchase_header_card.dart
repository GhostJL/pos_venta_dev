import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/supplier.dart';
import 'package:posventa/domain/entities/warehouse.dart';
import 'package:posventa/presentation/widgets/common/base/info_row.dart';

/// Widget that displays purchase header information (supplier, warehouse, invoice, date)
class PurchaseHeaderCard extends StatelessWidget {
  final Supplier supplier;
  final Warehouse warehouse;
  final String invoiceNumber;
  final DateTime purchaseDate;

  const PurchaseHeaderCard({
    super.key,
    required this.supplier,
    required this.warehouse,
    required this.invoiceNumber,
    required this.purchaseDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Información de la Compra',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: InfoField(label: 'Proveedor:', value: supplier.name),
                ),
                Expanded(
                  child: InfoField(label: 'Almacén:', value: warehouse.name),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (invoiceNumber.isNotEmpty)
                  Expanded(
                    child: InfoField(label: 'Factura:', value: invoiceNumber),
                  ),
                Expanded(
                  child: InfoField(
                    label: 'Fecha:',
                    value: _formatDate(purchaseDate),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}
