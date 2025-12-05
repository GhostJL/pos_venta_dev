import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/widgets/common/cards/dashboard_card.dart';

class DashboardManagementSection extends StatelessWidget {
  final int crossAxisCount;
  final double childAspectRatio;

  const DashboardManagementSection({
    super.key,
    required this.crossAxisCount,
    required this.childAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    final actionCards = [
      DashboardCard(
        title: 'Inventario',
        value: 'Productos y Stock',
        icon: Icons.inventory_2_rounded,
        iconColor: Colors.indigo.shade600,
        onTap: () => context.go('/inventory'),
      ),
      DashboardCard(
        title: 'Ajustes de Inventario',
        value: 'Correcciones y Ajustes',
        icon: Icons.tune_rounded,
        iconColor: Theme.of(context).colorScheme.tertiary,
        onTap: () => context.go('/inventory-adjustments-menu'),
      ),
      DashboardCard(
        title: 'Clientes',
        value: 'Informacion y detalles',
        icon: Icons.people_alt_rounded,
        iconColor: Theme.of(context).colorScheme.primary,
        onTap: () => context.go('/customers'),
      ),
      DashboardCard(
        title: 'Compras',
        value: 'Proveedores y Productos',
        icon: Icons.shopping_cart_rounded,
        iconColor: Colors.teal.shade600,
        onTap: () => context.go('/purchases'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          context,
          'Gestión y Administración',
          Icons.admin_panel_settings_rounded,
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
          ),
          itemCount: actionCards.length,
          itemBuilder: (context, index) => actionCards[index],
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
