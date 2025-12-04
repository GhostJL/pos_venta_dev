import 'package:flutter/material.dart';

class CartItemWidget extends StatelessWidget {
  final String? productName;
  final Function() onPressedRemove;
  final Function() onTapLessProduct;
  final Function() onTapMoreProduct;
  final double quantity;
  final double unitPrice;
  final double tax;
  final double total;
  const CartItemWidget({
    super.key,
    required this.productName,
    required this.onPressedRemove,
    required this.onTapLessProduct,
    required this.onTapMoreProduct,
    required this.quantity,
    required this.unitPrice,
    required this.tax,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name and remove button
          Row(
            children: [
              Expanded(
                child: Text(
                  productName ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: onPressedRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Quantity controls and price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Quantity controls
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: onTapLessProduct,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.remove, size: 18),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Text(
                        quantity.toStringAsFixed(0),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: onTapMoreProduct,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.add, size: 18),
                      ),
                    ),
                  ],
                ),
              ),

              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${unitPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (tax > 0)
                    Text(
                      '+ Imp: \$${tax.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
