
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/data/datasources/database_helper.dart';
import 'package:myapp/domain/entities/user.dart';
import 'package:myapp/presentation/pages/cashier_home_page.dart';
import 'package:myapp/presentation/pages/home_page.dart';
import 'package:myapp/presentation/pages/login_page.dart';
import 'package:myapp/presentation/providers/auth_provider.dart';
import 'package:myapp/presentation/pages/dashboard_page.dart';

// Onboarding Pages
import 'package:myapp/presentation/pages/onboarding/admin_setup_page.dart';
import 'package:myapp/presentation/pages/onboarding/add_cashiers_page.dart';
import 'package:myapp/presentation/pages/onboarding/add_cashier_form_page.dart';
import 'package:myapp/presentation/pages/onboarding/set_pin_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final refreshNotifier = ValueNotifier<int>(0);
  ref.listen(authProvider, (_, __) => refreshNotifier.value++);

  final onboardingCheck = ref.watch(onboardingCompletedProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: refreshNotifier,
    initialLocation: '/splash', // Always start at splash to resolve dependencies

    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: '/error',
        builder: (context, state) => const Scaffold(body: Center(child: Text('An error occurred'))),
      ),

      // Onboarding Routes
      GoRoute(path: '/setup-admin', builder: (context, state) => const AdminSetupPage()),
      GoRoute(path: '/add-cashiers', builder: (context, state) => const AddCashiersPage()),
      GoRoute(path: '/add-cashier-form', builder: (context, state) => const AddCashierFormPage()),
      GoRoute(path: '/set-pin', builder: (context, state) => const SetPinPage()),

      // Login Route
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),

      // Main App Routes under a ShellRoute
      ShellRoute(
        builder: (context, state, child) => HomePage(child: child),
        routes: [
          GoRoute(
            path: '/', // Admin dashboard
            pageBuilder: (context, state) => const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: '/home', // Cashier home
            pageBuilder: (context, state) => const NoTransitionPage(child: CashierHomePage()),
          ),
        ],
      ),
    ],

    redirect: (context, state) {
      final location = state.matchedLocation;

      if (authState.status == AuthStatus.loading || onboardingCheck.isLoading) {
        return '/splash';
      }

      final needsOnboarding = !(onboardingCheck.asData?.value ?? true);
      final isSettingUp = location.startsWith('/setup') || location.startsWith('/add-cashier') || location == '/set-pin';

      if (needsOnboarding) {
        return isSettingUp ? null : '/setup-admin';
      }
      if (!needsOnboarding && isSettingUp) {
        return '/login';
      }

      final loggedIn = authState.status == AuthStatus.authenticated;
      final isLoggingIn = location == '/login';

      if (!loggedIn && !isLoggingIn) {
        return '/login';
      }

      if (loggedIn) {
        final isAdmin = authState.user?.role == UserRole.admin;

        final onAdminDashboard = location == '/';
        final onCashierHome = location == '/home';

        if (isLoggingIn) {
          return isAdmin ? '/' : '/home';
        }

        if (onAdminDashboard && !isAdmin) {
          return '/home';
        }

        if (onCashierHome && isAdmin) {
          return '/';
        }
      }
      
      return null;
    },
  );
});

final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final dbHelper = DatabaseHelper();
  return await dbHelper.onboardingCompleted();
});

class NoTransitionPage<T> extends CustomTransitionPage<T> {
  const NoTransitionPage({
    super.key,
    super.name,
    required super.child,
  }) : super(transitionsBuilder: _transitionsBuilder);

  static Widget _transitionsBuilder(BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) =>
      child;
}
