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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _HeaderItem(
                  icon: Icons.business_outlined,
                  label: 'Proveedor',
                  value: supplier.name,
                ),
                _HeaderItem(
                  icon: Icons.warehouse_outlined,
                  label: 'Almacén',
                  value: warehouse.name,
                ),
              ],
            ),
            if (invoiceNumber.isNotEmpty || true) // Show common row
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    _HeaderItem(
                      icon: Icons.receipt_long_outlined,
                      label: 'Factura',
                      value: invoiceNumber.isNotEmpty ? invoiceNumber : '—',
                    ),
                    _HeaderItem(
                      icon: Icons.calendar_today_outlined,
                      label: 'Fecha',
                      value: _formatDate(purchaseDate),
                    ),
                  ],
                ),
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

class _HeaderItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HeaderItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  value,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
