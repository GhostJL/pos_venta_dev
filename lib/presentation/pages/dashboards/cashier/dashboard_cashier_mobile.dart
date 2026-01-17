import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/widgets/dashboard/dashboard_sections/dashboard_app_bar.dart';
import 'package:posventa/presentation/widgets/dashboard/dashboard_sections/dashboard_operations_section.dart';
import 'package:posventa/presentation/widgets/dashboard/dashboard_sections/dashboard_welcome_section.dart';
import 'package:posventa/presentation/widgets/dashboard/dashboard_sections/cashier_session_metrics.dart';
import 'package:posventa/presentation/widgets/dashboard/dashboard_sections/dashboard_cashier_actions.dart';
import 'package:posventa/presentation/widgets/dashboard/dashboard_sections/dashboard_cashier_movements.dart';

class DashboardCashierMobile extends ConsumerWidget {
  const DashboardCashierMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: const DashboardAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          DashboardWelcomeSection(firstName: user?.firstName),
          const SizedBox(height: 24),
          const CashierSessionMetrics(),
          const SizedBox(height: 24),
          const DashboardCashierActions(),
          const SizedBox(height: 24),
          const DashboardCashierMovements(),
          const SizedBox(height: 32),
          const DashboardOperationsSection(isTablet: false),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
