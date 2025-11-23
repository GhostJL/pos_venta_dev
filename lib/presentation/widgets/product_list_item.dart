import 'package:flutter/material.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/product.dart';

class ProductListItem extends StatelessWidget {
  final Product product;
  final VoidCallback onMorePressed;

  const ProductListItem({
    super.key,
    required this.product,
    required this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppTheme.borders.withAlpha(50)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _buildProductIcon(),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: _buildProductSubtitle(),
        trailing: _buildTrailing(),
      ),
    );
  }

  Widget _buildProductIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.inventory_2_rounded, color: AppTheme.primary),
    );
  }

  Widget _buildProductSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppTheme.borders),
              ),
              child: Text(
                product.code,
                style: const TextStyle(fontSize: 12, fontFamily: 'Monospace'),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              product.unitOfMeasure,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrailing() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '\$${(product.salePriceCents / 100).toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.more_vert_rounded),
          onPressed: onMorePressed,
        ),
      ],
    );
  }
}
