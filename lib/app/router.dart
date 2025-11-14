
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/presentation/pages/create_account_page.dart';
import 'package:myapp/presentation/pages/home_page.dart';
import 'package:myapp/presentation/pages/login_page.dart';
import 'package:myapp/presentation/providers/auth_provider.dart';
import 'package:myapp/presentation/providers/cash_session_provider.dart';
import 'package:myapp/presentation/screens/cash_session_screen.dart';
import 'package:myapp/presentation/screens/open_session_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final cashSessionAsync = ref.watch(cashSessionProvider);

  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/create-account',
        builder: (context, state) => const CreateAccountPage(),
      ),
      GoRoute(
        path: '/cash-session',
        builder: (context, state) => const CashSessionScreen(),
      ),
      GoRoute(
        path: '/open-session',
        builder: (context, state) => const OpenSessionScreen(),
      ),
    ],
    redirect: (context, state) {
      final loggedIn = authState != null;
      final loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/create-account';

      if (!loggedIn) {
        return loggingIn ? null : '/login';
      }

      // If logged in and trying to access login/create account, redirect to home
      if (loggingIn) {
        return '/';
      }

      // Handle cash session logic only if the user is logged in
      final sessionOpen = cashSessionAsync.when(
        data: (session) => session != null && session.closedAt == null,
        loading: () => false, // Assume no session while loading
        error: (e, s) => false, // Assume no session on error
      );

      final isAtOpenSession = state.matchedLocation == '/open-session';

      // If no session is open, and we are not already going to open one, redirect.
      if (!sessionOpen && !isAtOpenSession) {
        return '/open-session';
      }

      // If a session is open, but we are on the open-session page, go to the main session screen.
      if (sessionOpen && isAtOpenSession) {
        return '/cash-session';
      }
      
      // No redirection needed
      return null;
    },
  );
});
