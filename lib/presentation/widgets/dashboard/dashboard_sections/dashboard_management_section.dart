import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/widgets/dashboard/items/dashboard_action_card.dart';

class DashboardManagementSection extends StatelessWidget {
  final bool isTablet;
  const DashboardManagementSection({super.key, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final actionCards = [
      DashboardActionCard(
        title: 'Inventario',
        description: 'Productos y existencias',
        icon: Icons.inventory_2_rounded,
        color: Colors.indigo.shade600,
        onTap: () => context.go('/inventory'),
        isTablet: true,
      ),

      DashboardActionCard(
        title: 'Clientes',
        description: 'Gestionar clientes',
        icon: Icons.people_alt_rounded,
        color: Theme.of(context).colorScheme.primary,
        onTap: () => context.go('/customers'),
        isTablet: true,
      ),
      DashboardActionCard(
        title: 'Compras',
        description: 'Proveedores y ordenes',
        icon: Icons.shopping_cart_rounded,
        color: Colors.teal.shade600,
        onTap: () => context.go('/purchases'),
        isTablet: true,
      ),
      DashboardActionCard(
        title: 'Movimientos de Caja',
        description: 'Auditoría de efectivo',
        icon: Icons.account_balance_wallet_rounded,
        color: Colors.orange.shade700,
        onTap: () => context.go('/cash-movements'),
        isTablet: true,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool useColumn = constraints.maxWidth < 500;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              context,
              'Gestión y Administración',
              Icons.admin_panel_settings_rounded,
            ),

            useColumn
                ? Column(
                    children: actionCards.map((card) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: SizedBox(width: double.infinity, child: card),
                      );
                    }).toList(),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: actionCards.map((card) {
                        // 2 columns with safer calculation to avoid sub-pixel overflow
                        final width = (constraints.maxWidth - 32) / 2;
                        return SizedBox(width: width, child: card);
                      }).toList(),
                    ),
                  ),
          ],
        );
      },
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
