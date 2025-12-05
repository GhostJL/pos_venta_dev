import 'package:flutter/material.dart';
import 'package:posventa/presentation/widgets/common/base/base_button.dart';

class CartItemActions extends StatelessWidget {
  final int index;
  final Function(int index) onEditItem;
  final Function(int index) onRemoveItem;

  const CartItemActions({
    super.key,
    required this.index,
    required this.onEditItem,
    required this.onRemoveItem,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BaseButton.action(
          icon: Icons.edit_rounded,
          color: Theme.of(context).colorScheme.primary,
          onPressed: () => onEditItem(index),
          tooltip: 'Editar',
        ),
        SizedBox(width: 4),
        BaseButton.action(
          icon: Icons.delete_rounded,
          color: Theme.of(context).colorScheme.error,
          onPressed: () => onRemoveItem(index),
          tooltip: 'Eliminar',
        ),
      ],
    );
  }
}
