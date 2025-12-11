import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/widgets/common/cards/dashboard_card.dart';

class DashboardOperationsSection extends StatelessWidget {
  final bool isTablet;
  const DashboardOperationsSection({super.key, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final actionCards = [
      DashboardCard(
        title: 'Punto de Venta',
        value: 'Iniciar Venta',
        icon: Icons.point_of_sale_rounded,
        iconColor: Theme.of(context).colorScheme.primary,
        onTap: () => context.go('/sales'),
      ),
      DashboardCard(
        title: 'Historial de Ventas',
        value: 'Ver Registros y detalles',
        icon: Icons.receipt_long_rounded,
        iconColor: Theme.of(context).colorScheme.primary,
        onTap: () => context.go('/sales-history'),
      ),
      DashboardCard(
        title: 'Cortes de Caja',
        value: 'Sesiones de Caja y detalles',
        icon: Icons.history_edu_rounded,
        iconColor: Theme.of(context).colorScheme.secondary,
        onTap: () => context.go('/cash-sessions-history'),
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
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: actionCards.map((card) {
            return SizedBox(
              width: isTablet ? 300 : double.infinity,
              child: card,
            );
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
