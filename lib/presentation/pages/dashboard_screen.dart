import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:posventa/app/theme.dart';
import 'package:posventa/presentation/widgets/dashboard_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 800;

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        _buildHeader(context),
        const SizedBox(height: 24),
        _buildKpiSection(context, isSmallScreen),
        const SizedBox(height: 32),
        _buildQuickAccessSection(context, isSmallScreen),
        const SizedBox(height: 32),
        _buildRecentActivitySection(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¡Buenos días, Administrador!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Aquí tienes el resumen de tu tienda para hoy.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildKpiSection(BuildContext context, bool isSmallScreen) {
    final kpiCards = [
      DashboardCard(
        title: "Ventas de Hoy",
        value: NumberFormat.currency(
          symbol: '\$',
          decimalDigits: 2,
        ).format(1250.75),
        icon: Icons.monetization_on_rounded,
        iconColor: AppTheme.success,
        isKpi: true,
      ),
      DashboardCard(
        title: 'Transacciones',
        value: '82',
        icon: Icons.receipt_long_rounded,
        iconColor: Colors.orange.shade700,
        isKpi: true,
      ),
      DashboardCard(
        title: 'Ticket Promedio',
        value: NumberFormat.currency(
          symbol: '\$',
          decimalDigits: 2,
        ).format(15.25),
        icon: Icons.show_chart_rounded,
        iconColor: Colors.blue.shade700,
        isKpi: true,
      ),
    ];

    if (isSmallScreen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, 'Resumen Diario'),
          ...kpiCards.map(
            (card) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: SizedBox(width: double.infinity, child: card),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Resumen Diario'),
        Row(
          children:
              kpiCards
                  .map(
                    (card) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: card,
                      ),
                    ),
                  )
                  .toList()
                ..last = Expanded(
                  child: kpiCards.last,
                ), // Remove padding from last item
        ),
      ],
    );
  }

  Widget _buildQuickAccessSection(BuildContext context, bool isSmallScreen) {
    final actionCards = [
      DashboardCard(
        title: 'Punto de Venta',
        value: 'Iniciar Venta',
        icon: Icons.point_of_sale,
        iconColor: AppTheme.primary,
        onTap: () {
          context.go('/sales');
        },
      ),
      DashboardCard(
        title: 'Historial de Ventas',
        value: 'Ver Ventas',
        icon: Icons.receipt_long,
        iconColor: Colors.green.shade600,
        onTap: () {
          context.go('/sales-history');
        },
      ),
      DashboardCard(
        title: 'Gestionar Inventario',
        value: 'Productos y Stock',
        icon: Icons.inventory_2_rounded,
        iconColor: Colors.orange.shade600,
        onTap: () {
          context.go('/inventory');
        },
      ),
      DashboardCard(
        title: 'Clientes',
        value: 'Gestionar Clientes',
        icon: Icons.people_alt_rounded,
        iconColor: Colors.purple.shade600,
        onTap: () {
          context.go('/customers');
        },
      ),
      DashboardCard(
        title: 'Compras',
        value: 'Gestionar Compras',
        icon: Icons.shopping_cart_rounded,
        iconColor: Colors.teal.shade600,
        onTap: () {
          context.go('/purchases');
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Accesos Rápido'),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isSmallScreen ? 1 : 2,
            childAspectRatio: isSmallScreen ? 3.5 : 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: actionCards.length,
          itemBuilder: (context, index) => actionCards[index],
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Actividad Reciente'),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.textPrimary.withAlpha(10),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: AppTheme.borders.withAlpha(50)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: 5,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 1,
              color: AppTheme.borders.withAlpha(50),
              indent: 80,
              endIndent: 24,
            ),
            itemBuilder: (context, index) {
              final amount = 10.0 + (index * 5.5);
              final time = TimeOfDay(
                hour: 14 - index,
                minute: 30 - (index * 5),
              );

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.success.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: AppTheme.success,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Venta #${120 - index}',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                              ),
                              Text(
                                NumberFormat.currency(
                                  symbol: '\$',
                                  decimalDigits: 2,
                                ).format(amount),
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.success,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline_rounded,
                                size: 14,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Ana',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppTheme.textSecondary),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                time.format(context),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
