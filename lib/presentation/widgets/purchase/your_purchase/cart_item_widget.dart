import 'package:flutter/material.dart';

import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/presentation/widgets/purchase/your_purchase/action_button_widget.dart';
import 'package:posventa/presentation/widgets/purchase/your_purchase/quantity_button_widget.dart';

class CartItemWidget extends StatelessWidget {
  final PurchaseItem item;
  final Product? product;
  final int index;
  final Function(int index) onEditItem;
  final Function(int index) onRemoveItem;
  final Function(int index, double newQuantity) onQuantityChanged;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.product,
    required this.index,
    required this.onEditItem,
    required this.onRemoveItem,
    required this.onQuantityChanged,
  });

  ProductVariant? get _variant {
    if (item.variantId == null || product == null) return null;
    return product!.variants?.where((v) => v.id == item.variantId).firstOrNull;
  }

  double get _step => _variant?.quantity ?? 1.0;

  (double qty, String unit, double cost, double refCost, bool hasVariant)
  get _priceData {
    if (product == null) {
      return (item.quantity, item.unitOfMeasure, item.unitCost, 0.0, false);
    }

    final variant = _variant;
    if (variant != null) {
      final qty = item.quantity / variant.quantity;
      return (
        qty,
        'cajas/paq',
        (item.subtotalCents / 100.0) / qty,
        variant.costPriceCents / 100.0,
        true,
      );
    }
    return (
      item.quantity,
      item.unitOfMeasure,
      item.unitCost,
      product!.costPriceCents / 100.0,
      false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onEditItem(index),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: isWide
                  ? _buildWideLayout(context)
                  : _buildNarrowLayout(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 3, child: _buildProductInfo(context)),
        SizedBox(width: 24),
        _buildQuantityControls(context),
        SizedBox(width: 24),
        _buildTotal(context),
        SizedBox(width: 12),
        _buildActions(context),
      ],
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildProductInfo(context)),
            _buildActions(context),
          ],
        ),
        SizedBox(height: 16),
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Theme.of(context).colorScheme.surface,
                Colors.transparent,
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [_buildQuantityControls(context), _buildTotal(context)],
        ),
      ],
    );
  }

  Widget _buildProductInfo(BuildContext context) {
    final (qty, unit, cost, refCost, hasVariant) = _priceData;
    final diff = cost - refCost;
    final hasDiff = diff.abs() > 0.01;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.productName ?? 'Producto',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
            height: 1.3,
            letterSpacing: -0.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 10),
        if (hasVariant && _variant != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surface,
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.inventory_2_rounded,
                    size: 10,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  '${qty.toStringAsFixed(qty % 1 == 0 ? 0 : 2)} × ${_variant!.description}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  '(${_variant!.quantity.toStringAsFixed(0)} u)',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 1),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else
          Text(
            '${qty.toStringAsFixed(qty % 1 == 0 ? 0 : 2)} $unit',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 1),
              fontWeight: FontWeight.w600,
            ),
          ),
        SizedBox(height: 8),
        Row(
          children: [
            Text(
              '\$${cost.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 1),
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 4),
            Text(
              'c/u',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 1),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (hasDiff) ...[
              SizedBox(width: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: diff > 0
                      ? Theme.of(
                          context,
                        ).colorScheme.error.withValues(alpha: 0.1)
                      : Theme.of(
                          context,
                        ).colorScheme.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      diff > 0
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 12,
                      color: diff > 0
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.tertiary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${diff > 0 ? '+' : ''}\$${diff.abs().toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: diff > 0
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.tertiary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildQuantityControls(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          QuantityButtonWidget(
            icon: Icons.remove_rounded,
            onPressed: item.quantity > _step
                ? () => onQuantityChanged(index, item.quantity - _step)
                : null,
          ),
          Container(
            constraints: BoxConstraints(minWidth: 40),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              item.quantity.toStringAsFixed(0),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          QuantityButtonWidget(
            icon: Icons.add_rounded,
            onPressed: () => onQuantityChanged(index, item.quantity + _step),
          ),
        ],
      ),
    );
  }

  Widget _buildTotal(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '\$${item.total.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: -0.5,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'Total',
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ActionButtonWidget(
          icon: Icons.edit_rounded,
          color: Theme.of(context).colorScheme.primary,
          onPressed: () => onEditItem(index),
          tooltip: 'Editar',
        ),
        SizedBox(width: 4),
        ActionButtonWidget(
          icon: Icons.delete_rounded,
          color: Theme.of(context).colorScheme.error,
          onPressed: () => onRemoveItem(index),
          tooltip: 'Eliminar',
        ),
      ],
    );
  }
}
