import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/supplier.dart';
import 'package:posventa/domain/entities/warehouse.dart';

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
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'Información de la Compra',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: _InfoField(label: 'Proveedor:', value: supplier.name),
                ),
                Expanded(
                  child: _InfoField(label: 'Almacén:', value: warehouse.name),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (invoiceNumber.isNotEmpty)
                  Expanded(
                    child: _InfoField(label: 'Factura:', value: invoiceNumber),
                  ),
                Expanded(
                  child: _InfoField(
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

/// Internal widget for displaying a label-value pair
class _InfoField extends StatelessWidget {
  final String label;
  final String value;

  const _InfoField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
