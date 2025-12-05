import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/presentation/widgets/purchase/purchase_item_tile.dart';

class PurchaseItemsList extends StatelessWidget {
  final List<PurchaseItem> items;
  final Purchase purchase;

  const PurchaseItemsList({
    super.key,
    required this.items,
    required this.purchase,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return PurchaseItemTile(item: items[index], purchase: purchase);
      },
    );
  }
}
