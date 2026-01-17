import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/widgets/dashboard/dashboard_sections/dashboard_app_bar.dart';
import 'package:posventa/presentation/widgets/dashboard/dashboard_sections/dashboard_management_section.dart';
import 'package:posventa/presentation/widgets/dashboard/dashboard_sections/dashboard_metrics_section.dart';
import 'package:posventa/presentation/widgets/dashboard/dashboard_sections/dashboard_operations_section.dart';
import 'package:posventa/presentation/widgets/dashboard/dashboard_sections/dashboard_status_section.dart';
import 'package:posventa/presentation/widgets/dashboard/dashboard_sections/dashboard_welcome_section.dart';
import 'package:posventa/presentation/widgets/dashboard/dashboard_sections/cashier_session_metrics.dart';
import 'package:posventa/presentation/widgets/dashboard/dashboard_sections/dashboard_cashier_actions.dart';
import 'package:posventa/presentation/widgets/dashboard/dashboard_sections/dashboard_cashier_movements.dart';

class DashboardAdminDesktop extends ConsumerWidget {
  const DashboardAdminDesktop({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: const DashboardAppBar(),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 1600,
          ), // Wider max width for desktop
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
                    const SizedBox(height: 24),
                    const DashboardMetricsSection(),
                    const SizedBox(height: 24),
                    const DashboardOperationsSection(
                      isTablet: true,
                    ), // Treat desktop as "wide tablet" or similar for grid behavior
                    const SizedBox(height: 24),
                    // Additional detailed charts could go here
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
                    const SizedBox(height: 24),
                    const DashboardStatusSection(),
                    const SizedBox(height: 24),
                    const DashboardManagementSection(isTablet: true),
                    const SizedBox(height: 24),
                    const DashboardCashierActions(),
                    const SizedBox(height: 24),
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
