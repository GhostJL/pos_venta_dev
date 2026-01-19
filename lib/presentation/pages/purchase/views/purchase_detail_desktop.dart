import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/presentation/widgets/purchases/cards/purchase_info_card.dart';
import 'package:posventa/presentation/widgets/purchases/cards/purchase_totals_card.dart';
import 'package:posventa/presentation/widgets/purchases/tables/purchase_items_table.dart';

class PurchaseDetailDesktop extends StatelessWidget {
  final Purchase purchase;

  const PurchaseDetailDesktop({super.key, required this.purchase});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column: Summary and Totals (Fixed width or flex)
          SizedBox(
            width: 350,
            child: Column(
              children: [
                PurchaseInfoCard(purchase: purchase),
                const SizedBox(height: 16),
                PurchaseTotalsCard(
                  subtotalCents: purchase.subtotalCents,
                  taxCents: purchase.taxCents,
                  totalCents: purchase.totalCents,
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Right Column: Items Table (Expands)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detalle de Productos',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                PurchaseItemsTable(items: purchase.items, purchase: purchase),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
