import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/widgets/dashboard/dashboard_sections/dashboard_app_bar.dart';
import 'package:posventa/presentation/widgets/dashboard/dashboard_sections/dashboard_management_section.dart';
import 'package:posventa/presentation/widgets/dashboard/dashboard_sections/dashboard_operations_section.dart';
import 'package:posventa/presentation/widgets/dashboard/dashboard_sections/dashboard_status_section.dart';
import 'package:posventa/presentation/widgets/dashboard/dashboard_sections/dashboard_welcome_section.dart';

class DashboardAdminPage extends ConsumerWidget {
  const DashboardAdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: const DashboardAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            padding: const EdgeInsets.all(32.0),
            children: [
              // 1. Welcome Message
              DashboardWelcomeSection(firstName: user?.firstName),
              const SizedBox(height: 24),

              // 2. Cash Session Status & Clock
              const DashboardStatusSection(),
              const SizedBox(height: 32),

              // 3. Operations Section
              DashboardOperationsSection(isTablet: isTablet),
              const SizedBox(height: 32),

              // 4. Management Section
              DashboardManagementSection(isTablet: isTablet),
            ],
          );
        },
      ),
    );
  }
}
