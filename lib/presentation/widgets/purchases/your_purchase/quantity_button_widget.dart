import 'package:flutter/material.dart';

class QuantityButtonWidget extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const QuantityButtonWidget({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            size: 18,
            color: onPressed != null
                ? const Color(0xFF374151)
                : const Color(0xFFD1D5DB),
          ),
        ),
      ),
    );
  }
}
