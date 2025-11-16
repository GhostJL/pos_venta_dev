import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/presentation/widgets/dashboard_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    // --- KPI Cards ---
    final kpiCards = [
      _buildKpiCard(
        title: "Ventas de Hoy",
        value: NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(1250.75),
        icon: Icons.monetization_on_outlined,
        color: const Color(0xFF2E7D32), // Verde
      ),
      _buildKpiCard(
        title: 'Transacciones',
        value: '82',
        icon: Icons.receipt_long_outlined,
        color: const Color(0xFFF57F17), // Ámbar
      ),
      _buildKpiCard(
        title: 'Ticket Promedio',
        value: NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(15.25),
        icon: Icons.show_chart_outlined,
        color: const Color(0xFF1565C0), // Azul
      ),
    ];

    // --- Action Cards ---
    final actionCards = [
      DashboardCard(
        title: 'Gestionar Inventario',
        value: 'Productos',
        icon: Icons.inventory_2_outlined,
        color: const Color(0xFF0277BD),
        onTap: () {},
      ),
      DashboardCard(
        title: 'Gestionar Equipo',
        value: 'Usuarios',
        icon: Icons.people_outline,
        color: const Color(0xFFD84315),
        onTap: () {},
      ),
      DashboardCard(
        title: 'Reportes de Ventas',
        value: 'Ver Historial',
        icon: Icons.bar_chart_outlined,
        color: const Color(0xFF6A1B9A),
        onTap: () {},
      ),
      DashboardCard(
        title: 'Configuración',
        value: 'Tienda y POS',
        icon: Icons.settings_outlined,
        color: const Color(0xFF455A64),
        onTap: () {},
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // --- SECCIÓN DE RESUMEN DEL DÍA ---
        _buildSectionTitle('Resumen del Día', textTheme),
        Wrap(
          spacing: 16.0, // Espacio horizontal
          runSpacing: 16.0, // Espacio vertical
          children: kpiCards.map((card) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: isSmallScreen ? double.infinity : 250,
                maxWidth: isSmallScreen ? double.infinity : 350,
              ),
              child: card,
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // --- SECCIÓN DE ACCESOS RÁPIDOS ---
        _buildSectionTitle('Accesos Rápidos', textTheme),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 400, // Ancho máximo por elemento
            childAspectRatio: isSmallScreen ? 2.5 : 3, // Ajusta el ratio para pantallas grandes
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: actionCards.length,
          itemBuilder: (context, index) => actionCards[index],
        ),
        const SizedBox(height: 24),

        // --- SECCIÓN DE ACTIVIDAD RECIENTE ---
        _buildSectionTitle('Actividad Reciente', textTheme),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Column(
            children: List.generate(5, (index) {
              final amount = 10.0 + (index * 5.5);
              final time = TimeOfDay(hour: 14 - index, minute: 30 - (index * 5));
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.withOpacity(0.1),
                  child: const Icon(Icons.receipt_outlined, color: Colors.green),
                ),
                title: Text('Venta #${120 - index}', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                subtitle: Text('Cajero: Ana'),
                trailing: Text(
                  '${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount)} - ${time.format(context)}',
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: Text(
        title,
        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildKpiCard({required String title, required String value, required IconData icon, required Color color}) {
    return DashboardCard(
      title: title,
      value: value,
      icon: icon,
      color: color,
      isKpi: true, // Añadimos una distinción para estilizarlo diferente si es necesario
    );
  }
}
