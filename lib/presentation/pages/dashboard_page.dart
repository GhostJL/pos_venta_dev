import 'package:flutter/material.dart';
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
      ],
    );
  }
}
