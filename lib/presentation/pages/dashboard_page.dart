import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/presentation/widgets/dashboard_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      DashboardCard(
        title: "Today's Revenue",
        value: '\$1,250.75', // Dummy data
        icon: Icons.monetization_on_outlined,
        color: const Color(0xFF2E7D32), // Deep Green
        onTap: () {},
      ),
      DashboardCard(
        title: 'Total Movements',
        value: '12', // Dummy data
        icon: Icons.sync_alt_rounded,
        color: const Color(0xFFF57F17), // Amber
        onTap: () {},
      ),
      DashboardCard(
        title: 'Departments',
        value: 'Manage',
        icon: Icons.business_outlined,
        color: const Color(0xFF0277BD), // Light Blue
        onTap: () => context.push('/departments'),
      ),
      DashboardCard(
        title: 'Categories',
        value: 'Manage',
        icon: Icons.category_outlined,
        color: const Color(0xFF6A1B9A), // Deep Purple
        onTap: () => context.push('/categories'),
      ),
      DashboardCard(
        title: 'Brands',
        value: 'Manage',
        icon: Icons.label_important_outline,
        color: const Color(0xFF00695C), // Teal
        onTap: () => context.push('/brands'),
      ),
       DashboardCard(
        title: 'Proveedores',
        value: 'Manage',
        icon: Icons.local_shipping_outlined,
        color: const Color(0xFFC62828), // Red
        onTap: () => context.push('/suppliers'),
      ),
      DashboardCard(
        title: 'Users',
        value: 'Manage',
        icon: Icons.people_outline,
        color: const Color(0xFFD84315), // Deep Orange
        onTap: () {},
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Define breakpoints for responsive layout
        const double mobileBreakpoint = 600;
        const double tabletBreakpoint = 900;

        int crossAxisCount;
        double childAspectRatio;

        if (constraints.maxWidth < mobileBreakpoint) {
          // Mobile layout: Single column, taller cards
          crossAxisCount = 1;
          childAspectRatio = 4 / 1.1;
        } else if (constraints.maxWidth < tabletBreakpoint) {
          // Tablet layout: Two columns
          crossAxisCount = 2;
          childAspectRatio = 3 / 1;
        } else {
          // Desktop layout: Three columns
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
