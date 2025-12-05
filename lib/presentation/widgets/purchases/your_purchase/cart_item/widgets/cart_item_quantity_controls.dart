import 'package:flutter/material.dart';
import 'package:posventa/domain/entities/purchase_item.dart';
import 'package:posventa/presentation/widgets/common/base/quantity_control.dart';

class CartItemQuantityControls extends StatelessWidget {
  final PurchaseItem item;
  final double step;
  final int index;
  final Function(int index, double newQuantity) onQuantityChanged;

  const CartItemQuantityControls({
    super.key,
    required this.item,
    required this.step,
    required this.index,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return QuantityControl(
      value: item.quantity,
      step: step,
      minValue: step,
      onChanged: (newQuantity) => onQuantityChanged(index, newQuantity),
      decimals: 0,
    );
  }
}
