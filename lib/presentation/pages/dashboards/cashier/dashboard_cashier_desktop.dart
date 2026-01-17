import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/widgets/dashboard/dashboard_sections/dashboard_app_bar.dart';
import 'package:posventa/presentation/widgets/dashboard/dashboard_sections/dashboard_operations_section.dart';
import 'package:posventa/presentation/widgets/dashboard/dashboard_sections/dashboard_welcome_section.dart';
import 'package:posventa/presentation/widgets/dashboard/dashboard_sections/cashier_session_metrics.dart';
import 'package:posventa/presentation/widgets/dashboard/dashboard_sections/dashboard_cashier_actions.dart';
import 'package:posventa/presentation/widgets/dashboard/dashboard_sections/dashboard_cashier_movements.dart';

class DashboardCashierDesktop extends ConsumerWidget {
  const DashboardCashierDesktop({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    // Cashier Desktop: Focus on efficiency.
    // Maybe grid for actions?
    // Left: Operations/Quick Actions
    // Right: Session Info & Recent Movements
    return Scaffold(
      appBar: const DashboardAppBar(),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1600),
          padding: const EdgeInsets.all(32.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Left Column
              Expanded(
                flex: 3,
                child: ListView(
                  children: [
                    DashboardWelcomeSection(firstName: user?.firstName),
                    const SizedBox(height: 32),
                    // Main Operations (Start Sale, etc)
                    const DashboardOperationsSection(isTablet: true),
                    const SizedBox(height: 32),
                    const DashboardCashierActions(),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              // Right Sidebar Column
              Expanded(
                flex: 2,
                child: ListView(
                  children: [
                    const CashierSessionMetrics(),
                    const SizedBox(height: 32),
                    const DashboardCashierMovements(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
