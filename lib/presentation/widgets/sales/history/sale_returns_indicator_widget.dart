import 'package:flutter/material.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/sale_return.dart';

class SaleReturnsIndicatorWidget extends StatelessWidget {
  final List<SaleReturn> returns;

  const SaleReturnsIndicatorWidget({super.key, required this.returns});

  @override
  Widget build(BuildContext context) {
    if (returns.isEmpty) return const SizedBox.shrink();

    final totalReturned = returns.fold<int>(0, (sum, r) => sum + r.totalCents);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.alertWarning,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.keyboard_return_outlined,
              size: 14,
              color: AppTheme.onAlertWarning,
            ),
            const SizedBox(width: 6),
            Text(
              '${returns.length} ${returns.length == 1 ? 'devolución' : 'devoluciones'} · -\$${(totalReturned / 100).toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.onAlertWarning,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
