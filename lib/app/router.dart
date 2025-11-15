
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/domain/entities/user.dart';
import 'package:myapp/presentation/pages/cashier_home_page.dart';
import 'package:myapp/presentation/pages/home_page.dart';
import 'package:myapp/presentation/pages/login_page.dart';
import 'package:myapp/presentation/providers/auth_provider.dart';
import 'package:myapp/presentation/pages/dashboard_page.dart';
import 'package:myapp/presentation/providers/transaction_provider.dart';

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
    initialLocation: '/splash', 

    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: '/error',
        builder: (context, state) => const Scaffold(body: Center(child: Text('An error occurred'))),
      ),
      // Onboarding Routes (Unaffected)
      GoRoute(path: '/setup-admin', builder: (context, state) => const AdminSetupPage()),
      GoRoute(path: '/add-cashiers', builder: (context, state) => const AddCashiersPage()),
      GoRoute(path: '/add-cashier-form', builder: (context, state) => const AddCashierFormPage()),
      GoRoute(path: '/set-pin', builder: (context, state) => const SetPinPage()),

      // Login Route
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),

      // Main App Routes
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
      
      // Get auth and onboarding status
      final authLoading = authState.status == AuthStatus.loading;
      final onboardingLoading = onboardingCheck.isLoading;
      final loggedIn = authState.status == AuthStatus.authenticated;
      final needsOnboarding = !(onboardingCheck.asData?.value ?? true);

      // While loading, show splash screen
      if (authLoading || onboardingLoading) {
        return '/splash';
      }

      // --- Onboarding Logic (Unaffected) ---
      final isDuringOnboarding = location.startsWith('/setup') || location.startsWith('/add-cashier') || location == '/set-pin';
      if (needsOnboarding) {
        return isDuringOnboarding ? null : '/setup-admin';
      }
      if (!needsOnboarding && isDuringOnboarding) {
        return '/login';
      }
      // --- End of Onboarding Logic ---

      final isAtLogin = location == '/login';
      final isAtSplash = location == '/splash';

      // --- Handle Authenticated Users ---
      if (loggedIn) {
        final isAdmin = authState.user?.role == UserRole.admin;
        final targetHome = isAdmin ? '/' : '/home';

        // If a logged-in user is on the login or splash page, send them home.
        if (isAtLogin || isAtSplash) {
          return targetHome;
        }

        // If a logged-in user is on the wrong role page, correct it.
        final onAdminPage = location == '/';
        final onCashierPage = location == '/home';

        if (isAdmin && onCashierPage) return '/';
        if (!isAdmin && onAdminPage) return '/home';

        // Otherwise, they are on a valid page.
        return null;
      }

      // --- Handle Unauthenticated Users ---
      // If an unauthenticated user is anywhere but the login page, send them to login.
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
  const NoTransitionPage({
    super.key,
    super.name,
    required super.child,
  }) : super(transitionsBuilder: _transitionsBuilder);

  static Widget _transitionsBuilder(BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) =>
      child;
}
