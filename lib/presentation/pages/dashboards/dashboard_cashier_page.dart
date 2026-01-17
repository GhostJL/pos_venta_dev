import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/pages/dashboards/cashier/dashboard_cashier_desktop.dart';
import 'package:posventa/presentation/pages/dashboards/cashier/dashboard_cashier_mobile.dart';
import 'package:posventa/presentation/widgets/common/responsive/responsive_layout.dart';

class DashboardCashierPage extends ConsumerWidget {
  const DashboardCashierPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const ResponsiveLayout(
      mobile: DashboardCashierMobile(),
      tablet:
          DashboardCashierDesktop(), // Use Desktop layout for Tablet for now
      desktop: DashboardCashierDesktop(),
    );
  }
}
