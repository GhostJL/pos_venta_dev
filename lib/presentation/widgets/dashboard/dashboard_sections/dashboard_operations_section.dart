import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/widgets/dashboard/items/dashboard_action_card.dart';

class DashboardOperationsSection extends StatelessWidget {
  final bool isTablet;
  const DashboardOperationsSection({super.key, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final actionCards = [
      DashboardActionCard(
        title: 'Punto de Venta',
        description: 'Iniciar nueva venta',
        icon: Icons.point_of_sale_rounded,
        color: Theme.of(context).colorScheme.primary,
        onTap: () => context.go('/sales'),
        isTablet: isTablet,
      ),
      DashboardActionCard(
        title: 'Historial',
        description: 'Ver ventas y detalles',
        icon: Icons.receipt_long_rounded,
        color: Theme.of(context).colorScheme.primary,
        onTap: () => context.go('/sales-history'),
        isTablet: isTablet,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          context,
          'Operaciones Diarias',
          Icons.storefront_rounded,
        ),
        isTablet
            ? Column(
                children: actionCards.map((card) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: SizedBox(width: double.infinity, child: card),
                  );
                }).toList(),
              )
            : Wrap(
                spacing: 16,
                runSpacing: 16,
                children: actionCards.map((card) {
                  return SizedBox(width: double.infinity, child: card);
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
