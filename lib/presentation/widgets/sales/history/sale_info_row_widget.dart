import 'package:flutter/material.dart';

class SaleInfoRowWidget extends StatelessWidget {
  final int itemCount;
  final Color textColor;

  const SaleInfoRowWidget({
    super.key,
    required this.itemCount,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.shopping_bag_outlined, size: 14),
        const SizedBox(width: 6),
        Text(
          '$itemCount ${itemCount == 1 ? 'producto' : 'productos'}',
          style: TextStyle(fontSize: 12, color: textColor),
        ),
      ],
    );
  }
}
