import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/supplier.dart';
import 'package:posventa/domain/entities/warehouse.dart';
import 'package:posventa/presentation/providers/supplier_providers.dart';

class PurchaseHeaderForm extends ConsumerWidget {
  final Supplier? selectedSupplier;
  final Warehouse? selectedWarehouse;
  final String invoiceNumber;
  final DateTime purchaseDate;
  final ValueChanged<Supplier?> onSupplierChanged;
  final ValueChanged<String> onInvoiceNumberChanged;

  const PurchaseHeaderForm({
    super.key,
    required this.selectedSupplier,
    required this.selectedWarehouse,
    required this.invoiceNumber,
    required this.purchaseDate,
    required this.onSupplierChanged,
    required this.onInvoiceNumberChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliersAsync = ref.watch(supplierListProvider);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Datos Generales',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            suppliersAsync.when(
              data: (suppliers) => DropdownButtonFormField<Supplier>(
                initialValue: selectedSupplier,
                decoration: const InputDecoration(
                  labelText: 'Proveedor',
                  prefixIcon: Icon(Icons.business_outlined),
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                items: suppliers
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                    .toList(),
                onChanged: onSupplierChanged,
                validator: (value) =>
                    value == null ? 'Seleccione un proveedor' : null,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Error al cargar proveedores'),
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: invoiceNumber,
                    decoration: const InputDecoration(
                      labelText: 'N° Factura',
                      prefixIcon: Icon(Icons.receipt_long_outlined),
                      hintText: 'Opcional',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: onInvoiceNumberChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.warehouse_outlined,
                    label: 'Almacén de Recepción',
                    value: selectedWarehouse?.name ?? 'Cargando...',
                  ),
                  const Divider(height: 16),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Fecha de Compra',
                    value: DateFormat('dd/MM/yyyy').format(purchaseDate),
                  ),
                ],
              ),
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
        Column(
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
            ),
          ],
        ),
      ],
    );
  }
}
