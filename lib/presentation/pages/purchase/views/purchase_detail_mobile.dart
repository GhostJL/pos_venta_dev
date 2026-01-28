import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/presentation/widgets/purchases/cards/purchase_info_card.dart';
import 'package:posventa/presentation/widgets/purchases/cards/purchase_totals_card.dart';
import 'package:posventa/presentation/widgets/purchases/lists/purchase_items_list.dart';

class PurchaseDetailMobile extends StatelessWidget {
  final Purchase purchase;

  const PurchaseDetailMobile({super.key, required this.purchase});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PurchaseInfoCard(purchase: purchase),
          const SizedBox(height: 16),
          PurchaseTotalsCard(
            subtotalCents: purchase.subtotalCents,
            taxCents: purchase.taxCents,
            totalCents: purchase.totalCents,
          ),
          const SizedBox(height: 24),
          Text('Productos', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          PurchaseItemsList(items: purchase.items, purchase: purchase),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
