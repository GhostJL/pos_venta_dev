import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/pages/dashboards/admin/dashboard_admin_desktop.dart';
import 'package:posventa/presentation/pages/dashboards/admin/dashboard_admin_mobile.dart';
import 'package:posventa/presentation/widgets/common/responsive/responsive_layout.dart';

class DashboardAdminPage extends ConsumerWidget {
  const DashboardAdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const ResponsiveLayout(
      mobile: DashboardAdminMobile(),
      tablet: DashboardAdminDesktop(), // Use Desktop layout for Tablet for now
      desktop: DashboardAdminDesktop(),
    );
  }
}
