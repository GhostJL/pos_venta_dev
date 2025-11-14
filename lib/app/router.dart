import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/presentation/pages/create_account_page.dart';
import 'package:myapp/presentation/pages/home_page.dart';
import 'package:myapp/presentation/pages/login_page.dart';
import 'package:myapp/presentation/providers/auth_provider.dart';
import 'package:myapp/presentation/providers/cash_session_provider.dart';
import 'package:myapp/presentation/screens/add_movement_screen.dart';
import 'package:myapp/presentation/screens/cash_session_screen.dart';
import 'package:myapp/presentation/screens/open_session_screen.dart';
import 'package:myapp/presentation/screens/revenue_details_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final cashSessionAsync = ref.watch(cashSessionProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return HomePage(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: RevenueDetailsScreen()),
          ),
          GoRoute(
            path: '/session',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CashSessionScreen()),
          ),
          GoRoute(
            path: '/revenue-details',
            builder: (context, state) => const RevenueDetailsScreen(),
          ),
        ],
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/create-account',
        builder: (context, state) => const CreateAccountPage(),
      ),
      GoRoute(
        path: '/open-session',
        builder: (context, state) => const OpenSessionScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/add-movement',
        pageBuilder: (context, state) {
          return const MaterialPage(
            fullscreenDialog: true,
            child: AddMovementScreen(),
          );
        },
      ),
    ],
    redirect: (context, state) {
      final loggedIn = authState != null;
      final loggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/create-account';

      if (!loggedIn) {
        return loggingIn ? null : '/login';
      }

      if (loggingIn) {
        return '/';
      }

      // If the session provider is loading, don't redirect. This prevents
      // navigation errors during data refreshes.
      if (cashSessionAsync.isLoading) {
        return null;
      }

      // Safely get the session data.
      final session = cashSessionAsync.hasValue ? cashSessionAsync.value : null;
      final sessionOpen = session != null && session.closedAt == null;

      final isAtProtectedScreen =
          state.matchedLocation == '/session' ||
          state.matchedLocation == '/add-movement';

      if (!sessionOpen && isAtProtectedScreen) {
        return '/open-session';
      }

      if (sessionOpen && state.matchedLocation == '/open-session') {
        return '/';
      }

      return null;
    },
  );
});
