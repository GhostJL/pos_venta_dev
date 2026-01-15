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

class DashboardAdminPage extends ConsumerWidget {
  const DashboardAdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 800;

    // Determine number of columns for the main content
    // Mobile: 1 col
    // Tablet/Desktop: 2 cols (Operations left, Management right? or Stacked?)
    // Actually, distinct sections work best vertically unless screen is very wide.
    // Let's use a responsive container that limits max width on desktop.

    return Scaffold(
      appBar: const DashboardAppBar(),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: ListView(
            padding: EdgeInsets.all(isTablet ? 32.0 : 20.0),
            children: [
              // 1. Welcome Message
              DashboardWelcomeSection(firstName: user?.firstName),

              const SizedBox(height: 24),

              // 2. Metrics (New)
              const DashboardMetricsSection(),

              const SizedBox(height: 24),

              // 2.5 Session Metrics (Added)
              const CashierSessionMetrics(),

              const SizedBox(height: 24),

              // 3. Status
              const DashboardStatusSection(),

              const SizedBox(height: 24),

              // 4. Cashier Actions (Added)
              const DashboardCashierActions(),

              const SizedBox(height: 24),

              // 5. Cashier Movements (Added)
              const DashboardCashierMovements(),

              const SizedBox(height: 32),

              if (isTablet)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DashboardOperationsSection(isTablet: isTablet),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: DashboardManagementSection(isTablet: isTablet),
                    ),
                  ],
                )
              else ...[
                DashboardOperationsSection(isTablet: isTablet),
                const SizedBox(height: 32),
                DashboardManagementSection(isTablet: isTablet),
              ],

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
