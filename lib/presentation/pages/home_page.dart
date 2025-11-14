import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/app/theme.dart';
import 'package:myapp/presentation/providers/auth_provider.dart';
import 'package:myapp/presentation/screens/cash_session_screen.dart';
import 'package:myapp/presentation/widgets/dashboard_card.dart';

class HomePage extends ConsumerWidget {
  final Widget child; // This will be the content from the nested GoRoute

  const HomePage({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine the selected index based on the current route
    final String location = GoRouterState.of(context).matchedLocation;
    final int selectedIndex = location == '/session' ? 1 : 0;

    // The list of views for the BottomNavBar
    final List<Widget> views = [
      const DashboardView(),
      const CashSessionScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedIndex == 0 ? 'Dashboard' : 'Cash Session'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.primary),
            onPressed: () {
              ref.read(authStateProvider.notifier).signOut();
              // No need to context.go here, the redirect logic in the router will handle it
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      // Display the selected view
      body: IndexedStack(index: selectedIndex, children: views),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale_rounded),
            label: 'Session',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: AppTheme.primary,
        onTap: (index) {
          // Navigate to the corresponding route when a tab is tapped
          if (index == 0) {
            context.go('/');
          } else {
            context.go('/session');
          }
        },
      ),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

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
        ),
        const SizedBox(height: 16),
        DashboardCard(
          title: 'Active Session',
          value: 'OPEN', // Dummy data
          icon: Icons.check_circle_outline_rounded,
          color: AppTheme.success,
          onTap: () => context.go('/session'), // Navigate to the session tab
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
