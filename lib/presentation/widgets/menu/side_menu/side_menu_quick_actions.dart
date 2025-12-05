import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/presentation/widgets/menu/side_menu/quick_action_button.dart';

class SideMenuQuickActions extends StatelessWidget {
  final User? user;

  const SideMenuQuickActions({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    if (user?.role == UserRole.cajero) {
      final colorScheme = Theme.of(context).colorScheme;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: colorScheme.outline.withAlpha(100)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ACCIONES RÁPIDAS',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: QuickActionButton(
                    icon: Icons.point_of_sale_rounded,
                    label: 'POS',
                    color: Colors.green,
                    onTap: () => context.go('/sales'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: QuickActionButton(
                    icon: Icons.keyboard_return_rounded,
                    label: 'Devolución',
                    color: Colors.orange,
                    onTap: () => context.go('/returns'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
