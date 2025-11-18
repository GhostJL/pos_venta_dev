import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/presentation/pages/brands_page.dart';
import 'package:posventa/presentation/pages/cashier_home_page.dart';
import 'package:posventa/presentation/pages/categories_page.dart';
import 'package:posventa/presentation/pages/dashboard_screen.dart';
import 'package:posventa/presentation/pages/departments_page.dart';
import 'package:posventa/presentation/pages/login_page.dart';
import 'package:posventa/presentation/pages/main_layout.dart';
import 'package:posventa/presentation/pages/onboarding/add_cashier_form_page.dart';
import 'package:posventa/presentation/pages/onboarding/add_cashiers_page.dart';
// Onboarding Pages
import 'package:posventa/presentation/pages/onboarding/admin_setup_page.dart';
import 'package:posventa/presentation/pages/onboarding/set_access_key_page.dart';
import 'package:posventa/presentation/pages/suppliers_page.dart';
import 'package:posventa/presentation/pages/warehouses_page.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/transaction_provider.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final refreshNotifier = ValueNotifier<int>(0);
  ref.listen(authProvider, (_, __) => refreshNotifier.value++);

  final onboardingCheck = ref.watch(onboardingCompletedProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: refreshNotifier,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: '/error',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('An error occurred'))),
      ),
      // Onboarding Routes
      GoRoute(
        path: '/setup-admin',
        builder: (context, state) => const AdminSetupPage(),
      ),
      GoRoute(
        path: '/add-cashiers',
        builder: (context, state) => const AddCashiersPage(),
      ),
      GoRoute(
        path: '/add-cashier-form',
        builder: (context, state) => const AddCashierFormPage(),
      ),
      GoRoute(
        path: '/set-access-key',
        builder: (context, state) => const SetAccessKeyPage(),
      ),
      // Login Route
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),

      // Main App Routes
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/', // Admin dashboard
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: '/home', // Cashier home
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CashierHomePage()),
          ),
          GoRoute(
            path: '/departments',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DepartmentsPage()),
          ),
          GoRoute(
            path: '/categories',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CategoriesPage()),
          ),
          GoRoute(
            path: '/brands',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: BrandsPage()),
          ),
          GoRoute(
            path: '/suppliers',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SuppliersPage()),
          ),
          GoRoute(
            path: '/warehouses',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: WarehousesPage()),
          ),
        ],
      ),
    ],

    redirect: (context, state) {
      final location = state.matchedLocation;

      final authLoading = authState.status == AuthStatus.loading;
      final onboardingLoading = onboardingCheck.isLoading;
      final loggedIn = authState.status == AuthStatus.authenticated;
      final needsOnboarding = !(onboardingCheck.asData?.value ?? true);

      if (authLoading || onboardingLoading) {
        return '/splash';
      }

      // --- Onboarding Logic ---
      final isDuringOnboarding =
          location == '/setup-admin' ||
          location == '/add-cashiers' ||
          location == '/add-cashier-form' ||
          location == '/set-access-key';
      if (needsOnboarding) {
        return isDuringOnboarding ? null : '/setup-admin';
      }
      if (!needsOnboarding && isDuringOnboarding) {
        return '/login';
      }
      // --- End of Onboarding Logic ---

      final isAtLogin = location == '/login';
      final isAtSplash = location == '/splash';

      if (loggedIn) {
        final isAdmin = authState.user?.role == UserRole.administrador;
        final targetHome = isAdmin ? '/' : '/home';

        if (isAtLogin || isAtSplash) {
          return targetHome;
        }

        final onAdminPage = location == '/';
        final onCashierPage = location == '/home';

        if (isAdmin && onCashierPage) return '/';
        if (!isAdmin && onAdminPage) return '/home';

        return null;
      }

      if (!isAtLogin) {
        return '/login';
      }

      return null; // No redirection needed
    },
  );
});

final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final dbHelper = ref.watch(databaseHelperProvider);
  return await dbHelper.onboardingCompleted();
});

class NoTransitionPage<T> extends CustomTransitionPage<T> {
  const NoTransitionPage({super.key, super.name, required super.child})
    : super(transitionsBuilder: _transitionsBuilder);

  static Widget _transitionsBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => child;
}
