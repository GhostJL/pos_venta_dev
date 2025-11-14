import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/presentation/pages/create_account_page.dart';
import 'package:myapp/presentation/pages/home_page.dart';
import 'package:myapp/presentation/pages/login_page.dart';
import 'package:myapp/presentation/providers/auth_provider.dart';
import 'package:myapp/presentation/providers/cash_session_provider.dart';
import 'package:myapp/presentation/screens/add_movement_screen.dart';
import 'package:myapp/presentation/screens/open_session_screen.dart';

// Add this key for the root navigator
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final cashSessionAsync = ref.watch(cashSessionProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      // Main application shell
      ShellRoute(
        builder: (context, state, child) {
          return HomePage(child: child); // Your main layout with BottomNavBar
        },
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SizedBox.shrink()), // Placeholder
          ),
          GoRoute(
            path: '/session',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SizedBox.shrink()), // Placeholder
          ),
        ],
      ),
      // Standalone pages (no shell)
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/create-account',
        builder: (context, state) => const CreateAccountPage(),
      ),
      GoRoute(
        path: '/open-session',
        builder: (context, state) => const OpenSessionScreen(),
      ),
      // Modal-style page for adding movements
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

      // If logged in and trying to access login/create account, redirect to home
      if (loggingIn) {
        return '/';
      }

      final sessionOpen = cashSessionAsync.when(
        data: (session) => session != null && session.closedAt == null,
        loading: () => false,
        error: (e, s) => false,
      );

      final isAtOpenSession = state.matchedLocation == '/open-session';

      if (!sessionOpen &&
          !isAtOpenSession &&
          state.matchedLocation != '/add-movement') {
        return '/open-session';
      }

      if (sessionOpen && isAtOpenSession) {
        return '/'; // Go to the main dashboard/shell route
      }

      return null; // No redirection needed
    },
  );
});
