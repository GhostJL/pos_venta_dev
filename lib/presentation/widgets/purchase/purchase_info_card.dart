import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/presentation/widgets/purchase/purchase_status_badge.dart';

/// Widget reutilizable para mostrar la información general de una compra.
///
/// Muestra en un Card:
/// - Número de compra
/// - Estado (badge)
/// - Proveedor
/// - Fecha de compra
/// - Número de factura del proveedor (si existe)
/// - Fecha de última recepción (si existe)
class PurchaseInfoCard extends StatelessWidget {
  final Purchase purchase;

  const PurchaseInfoCard({super.key, required this.purchase});

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Compra \n#${purchase.purchaseNumber}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                PurchaseStatusBadge(status: purchase.status),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Proveedor:', purchase.supplierName ?? 'N/A'),
            _buildInfoRow('Fecha:', dateFormat.format(purchase.purchaseDate)),
            if (purchase.supplierInvoiceNumber != null)
              _buildInfoRow('Factura Prov.:', purchase.supplierInvoiceNumber!),
            if (purchase.receivedDate != null)
              _buildInfoRow(
                'Última Recepción:',
                dateFormat.format(purchase.receivedDate!),
              ),
          ],
        ),
      ),
    );
  }
}
