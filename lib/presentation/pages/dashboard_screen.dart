import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:posventa/app/theme.dart';
import 'package:posventa/presentation/widgets/dashboard_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        _buildHeader(context),
        const SizedBox(height: 16),
        _buildKpiSection(isSmallScreen),
        const SizedBox(height: 16),
        _buildQuickAccessSection(isSmallScreen),
        const SizedBox(height: 16),
        _buildRecentActivitySection(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          '¡Buenos días, Administrador!',
          style: Theme.of(
            context,
          ).textTheme.displayLarge?.copyWith(fontSize: 32),
        ),
        const SizedBox(height: 4),
        Text(
          'Aquí tienes el resumen de tu tienda para hoy.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget _buildKpiSection(bool isSmallScreen) {
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

    return Column(
      crossAxisAlignment: .start,
      children: [
        Builder(
          builder: (context) => _buildSectionTitle(context, 'Resumen Diario'),
        ),
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: kpiCards.map((card) {
            return SizedBox(
              width: isSmallScreen ? double.infinity : double.infinity,
              child: card,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickAccessSection(bool isSmallScreen) {
    final actionCards = [
      DashboardCard(
        title: 'Gestionar Inventario',
        value: 'Productos y Stock',
        icon: Icons.inventory_2_rounded,
        iconColor: AppTheme.primary,
        onTap: () {},
      ),
      DashboardCard(
        title: 'Gestionar Equipo',
        value: 'Usuarios y Permisos',
        icon: Icons.people_alt_rounded,
        iconColor: Colors.deepOrange.shade600,
        onTap: () {},
      ),
      DashboardCard(
        title: 'Reportes de Ventas',
        value: 'Ver Historial',
        icon: Icons.bar_chart_rounded,
        iconColor: Colors.purple.shade600,
        onTap: () {},
      ),
      DashboardCard(
        title: 'Configuración',
        value: 'Tienda y POS',
        icon: Icons.settings_rounded,
        iconColor: Colors.grey.shade700,
        onTap: () {},
      ),
    ];

    return Column(
      crossAxisAlignment: .start,
      children: [
        Builder(
          builder: (context) => _buildSectionTitle(context, 'Accesos Rápido'),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isSmallScreen ? 1 : 2,
            childAspectRatio: isSmallScreen ? 4 : 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: actionCards.length,
          itemBuilder: (context, index) => actionCards[index],
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        _buildSectionTitle(context, 'Actividad Reciente'),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppTheme.borders, width: 1),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: 5,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              thickness: 1,
              color: AppTheme.borders,
              indent: 72,
            ),
            itemBuilder: (context, index) {
              final amount = 10.0 + (index * 5.5);
              final time = TimeOfDay(
                hour: 14 - index,
                minute: 30 - (index * 5),
              );

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  children: [
                    // Icono con badge de número
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.success.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.receipt_long_rounded,
                            color: AppTheme.success,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    // Información principal
                    Expanded(
                      child: Column(
                        crossAxisAlignment: .start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Venta #${120 - index}',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Monto destacado
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.success.withAlpha(25),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  NumberFormat.currency(
                                    symbol: '\$',
                                    decimalDigits: 2,
                                  ).format(amount),
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.success,
                                        fontSize: 14,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Detalles secundarios
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
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13,
                                    ),
                              ),
                              Spacer(),
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                time.format(context),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13,
                                    ),
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
