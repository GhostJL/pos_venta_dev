import 'package:flutter/material.dart';

class SaleHeaderWidget extends StatelessWidget {
  final String saleNumber;
  final String saleDateText;
  final Color statusColor;
  final Color statusBorderColor;
  final String statusText;
  final Color statusTextColor;
  final bool isCancelled;
  final bool isReturned;

  const SaleHeaderWidget({
    super.key,
    required this.saleNumber,
    required this.saleDateText,
    required this.statusColor,
    required this.statusBorderColor,
    required this.statusText,
    required this.statusTextColor,
    required this.isCancelled,
    required this.isReturned,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 3,
          height: 36,
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                saleNumber,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                saleDateText,
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: statusBorderColor),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: statusTextColor,
            ),
          ),
        ),
      ],
    );
  }
}
