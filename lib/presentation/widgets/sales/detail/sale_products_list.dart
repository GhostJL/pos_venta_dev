import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/presentation/widgets/sales/common/sale_product_item.dart';

class SaleProductsList extends StatelessWidget {
  final Sale sale;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;

  const SaleProductsList({
    super.key,
    required this.sale,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: physics,
      shrinkWrap: shrinkWrap,
      padding: padding ?? const EdgeInsets.all(16),
      itemCount: sale.items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = sale.items[index];
        return Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SaleProductItem(item: item),
          ),
        );
      },
    );
  }
}
