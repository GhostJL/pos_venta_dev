import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/widgets/dashboard/dashboard_sections/cashier_session_metrics.dart';
import 'package:posventa/presentation/widgets/dashboard/dashboard_sections/dashboard_app_bar.dart';
import 'package:posventa/presentation/widgets/dashboard/dashboard_sections/dashboard_operations_section.dart';
import 'package:posventa/presentation/widgets/dashboard/dashboard_sections/dashboard_welcome_section.dart';
import 'package:posventa/presentation/widgets/dashboard/dashboard_sections/dashboard_cashier_actions.dart';
import 'package:posventa/presentation/widgets/dashboard/dashboard_sections/dashboard_cashier_movements.dart';

class DashboardCashierPage extends ConsumerWidget {
  const DashboardCashierPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 800;

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

              // 2. Session Metrics (Replacing generic status)
              const CashierSessionMetrics(),

              const SizedBox(height: 24),

              // 2.5 Actions (New)
              const DashboardCashierActions(),

              const SizedBox(height: 24),

              // 2.7 Recent Movements (New)
              const DashboardCashierMovements(),

              const SizedBox(height: 32),

              // 3. Operations (Primary focus for Cashier)
              DashboardOperationsSection(isTablet: isTablet),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
