import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/app/theme.dart';
import 'package:myapp/presentation/widgets/dashboard_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        DashboardCard(
          title: "Today's Revenue",
          value: '\$1,250.75', // Dummy data
          icon: Icons.monetization_on_outlined,
          color: AppTheme.primary,
          onTap: () {},
        ),
        const SizedBox(height: 16),
        DashboardCard(
          title: 'Total Movements',
          value: '12', // Dummy data
          icon: Icons.sync_alt_rounded,
          color: Colors.orange,
        ),
        const SizedBox(height: 16),
        DashboardCard(
          title: 'Departments',
          value: 'Manage',
          icon: Icons.business_outlined,
          color: Colors.cyan,
          onTap: () => context.push('/departments'),
        ),
        const SizedBox(height: 16),
        DashboardCard(
          title: 'Categories',
          value: 'Manage',
          icon: Icons.category_outlined,
          color: Colors.purple,
          onTap: () => context.push('/categories'),
        ),
      ],
    );
  }
}
