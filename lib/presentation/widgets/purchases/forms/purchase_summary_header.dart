import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/supplier.dart';
import 'package:posventa/domain/entities/warehouse.dart';

class PurchaseSummaryHeader extends StatelessWidget {
  final Supplier? selectedSupplier;
  final Warehouse? selectedWarehouse;
  final String invoiceNumber;
  final DateTime purchaseDate;

  const PurchaseSummaryHeader({
    super.key,
    required this.selectedSupplier,
    required this.selectedWarehouse,
    required this.invoiceNumber,
    required this.purchaseDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.3,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Datos Generales',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.business_outlined,
              label: 'Proveedor',
              value: selectedSupplier?.name ?? 'No seleccionado',
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.receipt_long_outlined,
              label: 'N° Factura',
              value: invoiceNumber.isNotEmpty ? invoiceNumber : '---',
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.warehouse_outlined,
              label: 'Almacén de Recepción',
              value: selectedWarehouse?.name ?? 'Cargando...',
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Fecha de Compra',
              value: DateFormat('dd/MM/yyyy').format(purchaseDate),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
