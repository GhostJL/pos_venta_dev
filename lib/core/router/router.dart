import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/pages/products_page.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/presentation/pages/tax_rate_page.dart';
import 'package:posventa/presentation/pages/brands_page.dart';
import 'package:posventa/presentation/pages/cashier_home_page.dart';
import 'package:posventa/presentation/pages/categories_page.dart';
import 'package:posventa/presentation/pages/dashboard_screen.dart';
import 'package:posventa/presentation/pages/departments_page.dart';
import 'package:posventa/presentation/pages/login_page.dart';
import 'package:posventa/presentation/widgets/cash_session_guard.dart';
import 'package:posventa/presentation/pages/onboarding/add_cashier_form_page.dart';
import 'package:posventa/presentation/pages/onboarding/add_cashiers_page.dart';
// Onboarding Pages
import 'package:posventa/presentation/pages/onboarding/admin_setup_page.dart';
import 'package:posventa/presentation/pages/onboarding/set_access_key_page.dart';
import 'package:posventa/presentation/pages/suppliers_page.dart';
import 'package:posventa/presentation/pages/warehouses_page.dart';
import 'package:posventa/presentation/pages/inventory_page.dart';
import 'package:posventa/presentation/pages/customers_page.dart';
import 'package:posventa/presentation/pages/sales_page.dart';
import 'package:posventa/presentation/pages/sales_history_page.dart';
import 'package:posventa/presentation/pages/sale_detail_page.dart';
import 'package:posventa/presentation/pages/purchases_page.dart';
import 'package:posventa/presentation/pages/purchase_detail_page.dart';
import 'package:posventa/presentation/pages/purchase_form_page.dart';
import 'package:posventa/presentation/pages/purchase_items_page.dart';
import 'package:posventa/presentation/pages/purchase_item_detail_page.dart';
import 'package:posventa/presentation/pages/purchase_item_form_page.dart';
import 'package:posventa/presentation/pages/cash_session_open_page.dart';
import 'package:posventa/presentation/pages/cash_session_close_page.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:posventa/presentation/providers/transaction_provider.dart';

import 'package:posventa/presentation/pages/cashier/cashier_list_page.dart';
import 'package:posventa/presentation/pages/cash_session_history_page.dart';
import 'package:posventa/presentation/pages/cash_movements_report_page.dart';

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

      // Cash Session Routes (standalone, outside main layout)
      GoRoute(
        path: '/cash-session-open',
        builder: (context, state) => const CashSessionOpenPage(),
      ),
      GoRoute(
        path: '/cash-session-close',
        builder: (context, state) {
          final intent = state.uri.queryParameters['intent'];
          return CashSessionClosePage(isLogoutIntent: intent == 'logout');
        },
      ),

      // Main App Routes with Cash Session Guard
      ShellRoute(
        builder: (context, state, child) => CashSessionGuard(child: child),
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
            path: '/products',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProductsPage()),
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
          GoRoute(
            path: '/tax-rates',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: TaxRatePage()),
          ),
          GoRoute(
            path: '/inventory',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: InventoryPage()),
          ),
          GoRoute(
            path: '/customers',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CustomersPage()),
          ),
          GoRoute(
            path: '/sales',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SalesPage()),
          ),
          GoRoute(
            path: '/sales-history',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SalesHistoryPage()),
          ),
          GoRoute(
            path: '/sale-detail/:id',
            pageBuilder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return NoTransitionPage(child: SaleDetailPage(saleId: id));
            },
          ),
          GoRoute(
            path: '/purchases',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: PurchasesPage()),
          ),
          GoRoute(
            path: '/purchases/:id',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              if (id == 'new') {
                return const NoTransitionPage(child: PurchaseFormPage());
              }
              return NoTransitionPage(
                child: PurchaseDetailPage(purchaseId: int.parse(id)),
              );
            },
          ),
          // Purchase Items Routes
          GoRoute(
            path: '/purchase-items',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: PurchaseItemsPage()),
          ),
          GoRoute(
            path: '/purchase-items/:id',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              if (id == 'new') {
                return const NoTransitionPage(child: PurchaseItemFormPage());
              }
              return NoTransitionPage(
                child: PurchaseItemDetailPage(itemId: int.parse(id)),
              );
            },
          ),
          GoRoute(
            path: '/cashiers',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CashierListPage()),
          ),
          GoRoute(
            path: '/cash-sessions-history',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CashSessionHistoryPage()),
          ),
          GoRoute(
            path: '/cash-movements-report',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CashMovementsReportPage()),
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
