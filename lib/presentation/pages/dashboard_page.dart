import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/presentation/widgets/dashboard_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      DashboardCard(
        title: "Ingresos de Hoy",
        value: '\$1,250.75', // Datos de ejemplo
        icon: Icons.monetization_on_outlined,
        color: const Color(0xFF2E7D32), // Verde oscuro
        onTap: () {},
      ),
      DashboardCard(
        title: 'Movimientos Totales',
        value: '12', // Datos de ejemplo
        icon: Icons.sync_alt_rounded,
        color: const Color(0xFFF57F17), // Ámbar
        onTap: () {},
      ),
      DashboardCard(
        title: 'Departamentos',
        value: 'Gestionar',
        icon: Icons.business_outlined,
        color: const Color(0xFF0277BD), // Azul claro
        onTap: () => context.push('/departments'),
      ),
      DashboardCard(
        title: 'Categorías',
        value: 'Gestionar',
        icon: Icons.category_outlined,
        color: const Color(0xFF6A1B9A), // Púrpura oscuro
        onTap: () => context.push('/categories'),
      ),
      DashboardCard(
        title: 'Marcas',
        value: 'Gestionar',
        icon: Icons.label_important_outline,
        color: const Color(0xFF00695C), // Teal
        onTap: () => context.push('/brands'),
      ),
       DashboardCard(
        title: 'Proveedores',
        value: 'Gestionar',
        icon: Icons.local_shipping_outlined,
        color: const Color(0xFFC62828), // Rojo
        onTap: () => context.push('/suppliers'),
      ),
      DashboardCard(
        title: 'Usuarios',
        value: 'Gestionar',
        icon: Icons.people_outline,
        color: const Color(0xFFD84315), // Naranja oscuro
        onTap: () {},
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Definir puntos de interrupción para el diseño adaptable
        const double mobileBreakpoint = 600;
        const double tabletBreakpoint = 900;

        int crossAxisCount;
        double childAspectRatio;

        if (constraints.maxWidth < mobileBreakpoint) {
          // Diseño móvil: Una sola columna, tarjetas más altas
          crossAxisCount = 1;
          childAspectRatio = 4 / 1.1;
        } else if (constraints.maxWidth < tabletBreakpoint) {
          // Diseño de tableta: Dos columnas
          crossAxisCount = 2;
          childAspectRatio = 3 / 1;
        } else {
          // Diseño de escritorio: Tres columnas
          crossAxisCount = 3;
          childAspectRatio = 2.8 / 1;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            return cards[index];
          },
        );
      },
    );
  }
}
