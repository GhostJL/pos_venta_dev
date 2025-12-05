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

    return Scaffold(
      appBar: const DashboardAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determine column count based on width
          int crossAxisCount = 1;
          double childAspectRatio = 3.0;

          if (constraints.maxWidth >= 1100) {
            crossAxisCount = 3;
            childAspectRatio = 2.5;
          } else if (constraints.maxWidth >= 700) {
            crossAxisCount = 2;
            childAspectRatio = 2.2; // Slightly taller for tablets
          }

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
              DashboardOperationsSection(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
              ),
              const SizedBox(height: 32),

              // 4. Management Section
              DashboardManagementSection(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
              ),
            ],
          );
        },
      ),
    );
  }
}
