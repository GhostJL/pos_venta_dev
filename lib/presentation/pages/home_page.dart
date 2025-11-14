import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/app/theme.dart';
import 'package:myapp/presentation/providers/auth_provider.dart';
import 'package:myapp/presentation/providers/cash_session_provider.dart';
import 'package:myapp/presentation/screens/cash_session_screen.dart';
import 'package:myapp/presentation/widgets/dashboard_card.dart';

class HomePage extends ConsumerWidget {
  final Widget child;

  const HomePage({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String location = GoRouterState.of(context).matchedLocation;
    final int selectedIndex = location == '/session' ? 1 : 0;

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
            },
            tooltip: 'Logout',
          ),
        ],
      ),
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

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cashSessionAsync = ref.watch(cashSessionProvider);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        DashboardCard(
          title: "Today's Revenue",
          value: '\$1,250.75', // Dummy data
          icon: Icons.monetization_on_outlined,
          color: AppTheme.primary,
          onTap: () => context.go('/revenue-details'),
        ),
        const SizedBox(height: 16),
        cashSessionAsync.when(
          data: (session) {
            if (session != null && session.closedAt == null) {
              return DashboardCard(
                title: 'Active Session',
                value: 'OPEN',
                icon: Icons.check_circle_outline_rounded,
                color: AppTheme.success,
                onTap: () => context.go('/session'),
              );
            } else {
              return DashboardCard(
                title: 'No Active Session',
                value: 'Tap to open',
                icon: Icons.play_circle_outline_rounded,
                color: Colors.blueGrey,
                onTap: () => context.go('/open-session'),
              );
            }
          },
          loading: () => const DashboardCard(
            title: 'Active Session',
            value: 'Loading...',
            icon: Icons.hourglass_empty_rounded,
            color: Colors.grey,
          ),
          error: (err, stack) => DashboardCard(
            title: 'Error',
            value: 'Could not load session',
            icon: Icons.error_outline_rounded,
            color: AppTheme.error,
          ),
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
