import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/app/theme.dart';
import 'package:myapp/presentation/widgets/dashboard_card.dart';

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
      crossAxisAlignment: CrossAxisAlignment.start,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Builder(
          builder: (context) => _buildSectionTitle(context, 'Resumen Diario'),
        ),
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: kpiCards.map((card) {
            return SizedBox(
              width: isSmallScreen ? double.infinity : 250,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Builder(
          builder: (context) => _buildSectionTitle(context, 'Acceso Rápido'),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isSmallScreen ? 1 : 2,
            childAspectRatio: isSmallScreen ? 4 : 3.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
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
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppTheme.borders, width: 1),
          ),
          child: Column(
            children: List.generate(5, (index) {
              final amount = 10.0 + (index * 5.5);
              final time = TimeOfDay(
                hour: 14 - index,
                minute: 30 - (index * 5),
              );
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.inputBackground,
                  child: Icon(
                    Icons.receipt_rounded,
                    color: AppTheme.textSecondary,
                  ),
                ),
                title: Text(
                  'Venta #${120 - index}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Cajero: Ana'),
                trailing: Text(
                  '${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount)} - ${time.format(context)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
