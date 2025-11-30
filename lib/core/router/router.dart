import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/user.dart';

import 'package:posventa/presentation/pages/screens.dart';
import 'package:posventa/presentation/widgets/barcode_scanner_widget.dart';
import 'package:posventa/presentation/widgets/cash_session_guard.dart';

import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';

import 'package:posventa/presentation/widgets/product_form_page.dart';
import 'package:posventa/presentation/widgets/brand_form.dart';
import 'package:posventa/presentation/widgets/category_form.dart';
import 'package:posventa/presentation/widgets/customer_form.dart';
import 'package:posventa/presentation/widgets/department_form.dart';
import 'package:posventa/presentation/widgets/supplier_form.dart';

import 'package:posventa/domain/entities/product.dart';

import 'package:posventa/domain/entities/cash_session.dart';
import 'package:posventa/domain/entities/brand.dart';
import 'package:posventa/domain/entities/category.dart';
import 'package:posventa/domain/entities/customer.dart';
import 'package:posventa/domain/entities/department.dart';
import 'package:posventa/domain/entities/supplier.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final refreshNotifier = ValueNotifier<int>(0);
  ref.listen(authProvider, (_, __) => refreshNotifier.value++);

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
      // Create Account Route
      GoRoute(
        path: '/create-account',
        builder: (context, state) => const CreateAccountPage(),
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
                const NoTransitionPage(child: DashboardAdminPage()),
          ),
          GoRoute(
            path: '/home', // Cashier home
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DashboardCashierPage()),
          ),
          GoRoute(
            path: '/products',
            pageBuilder: (context, state) =>
                NoTransitionPage(child: ProductsPage()),
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
                const NoTransitionPage(child: PosSalesPage()),
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
            path: '/sale-returns-detail/:id',
            pageBuilder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              final sale = state.extra as Sale;
              return NoTransitionPage(
                child: SaleReturnsDetailPage(saleId: id, sale: sale),
              );
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
                // Step 1: Header page
                return const NoTransitionPage(child: PurchaseHeaderPage());
              }
              return NoTransitionPage(
                child: PurchaseDetailPage(purchaseId: int.parse(id)),
              );
            },
          ),
          // Step 2: Products page (receives header data)
          GoRoute(
            path: '/purchases/new/products',
            pageBuilder: (context, state) {
              final headerData = state.extra as Map<String, dynamic>?;
              return NoTransitionPage(
                child: PurchaseFormPage(headerData: headerData),
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

          // Form Routes
          GoRoute(
            path: '/products/form',
            pageBuilder: (context, state) {
              final product = state.extra as Product?;
              return NoTransitionPage(child: ProductFormPage(product: product));
            },
          ),
          GoRoute(
            path: '/suppliers/form',
            pageBuilder: (context, state) {
              final supplier = state.extra as Supplier?;
              return NoTransitionPage(child: SupplierForm(supplier: supplier));
            },
          ),
          GoRoute(
            path: '/departments/form',
            pageBuilder: (context, state) {
              final department = state.extra as Department?;
              return NoTransitionPage(
                child: DepartmentForm(department: department),
              );
            },
          ),
          GoRoute(
            path: '/customers/form',
            pageBuilder: (context, state) {
              final customer = state.extra as Customer?;
              return NoTransitionPage(child: CustomerForm(customer: customer));
            },
          ),
          GoRoute(
            path: '/categories/form',
            pageBuilder: (context, state) {
              final category = state.extra as Category?;
              return NoTransitionPage(child: CategoryForm(category: category));
            },
          ),
          GoRoute(
            path: '/brands/form',
            pageBuilder: (context, state) {
              final brand = state.extra as Brand?;
              return NoTransitionPage(child: BrandForm(brand: brand));
            },
          ),

          GoRoute(
            path: '/inventory/form',
            pageBuilder: (context, state) {
              final inventory = state.extra as dynamic;
              return NoTransitionPage(
                child: InventoryFormPage(inventory: inventory),
              );
            },
          ),
          GoRoute(
            path: '/cashiers/form',
            pageBuilder: (context, state) {
              final cashier = state.extra as User?;
              return NoTransitionPage(child: CashierFormPage(cashier: cashier));
            },
          ),
          GoRoute(
            path: '/cashiers/permissions',
            pageBuilder: (context, state) {
              final cashier = state.extra as User;
              return NoTransitionPage(
                child: CashierPermissionsPage(cashier: cashier),
              );
            },
          ),
          GoRoute(
            path: '/cash-sessions/detail',
            pageBuilder: (context, state) {
              final session = state.extra as CashSession;
              return NoTransitionPage(
                child: CashSessionDetailPage(session: session),
              );
            },
          ),
          GoRoute(
            path: '/scanner',
            pageBuilder: (context, state) {
              return NoTransitionPage(
                child: BarcodeScannerWidget(
                  onBarcodeScanned: (context, barcode) {
                    context.pop(barcode);
                  },
                ),
              );
            },
          ),

          // New Module Routes
          GoRoute(
            path: '/returns',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ReturnsManagementPage()),
          ),
          GoRoute(
            path: '/inventory-adjustments',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: InventoryAdjustmentsPage()),
          ),
          GoRoute(
            path: '/inventory-adjustments-menu',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: InventoryAdjustmentsMenuPage()),
          ),
          GoRoute(
            path: '/adjustments/physical-inventory',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PhysicalInventoryAdjustmentPage(),
            ),
          ),

          GoRoute(
            path: '/adjustments/price-adjustment',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ComingSoonPage(
                title: 'Ajuste de Precios',
                description:
                    'Corregir precios o descuentos aplicados en ventas',
                icon: Icons.price_change_rounded,
                iconColor: Colors.blue,
              ),
            ),
          ),
          GoRoute(
            path: '/adjustments/payment-correction',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ComingSoonPage(
                title: 'Corrección de Forma de Pago',
                description:
                    'Modificar la forma de pago registrada en una venta',
                icon: Icons.payment_rounded,
                iconColor: Colors.purple,
              ),
            ),
          ),
          GoRoute(
            path: '/adjustments/return-processing',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ReturnProcessingPage()),
          ),

          // Physical Inventory Routes
          GoRoute(
            path: '/adjustments/inventory-reversal',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ComingSoonPage(
                title: 'Reversión por Devolución',
                description:
                    'Devolver productos al inventario tras una devolución',
                icon: Icons.undo_rounded,
                iconColor: Colors.teal,
              ),
            ),
          ),
          GoRoute(
            path: '/adjustments/damage-loss',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ComingSoonPage(
                title: 'Registro de Mermas',
                description:
                    'Registrar productos dañados, caducados o perdidos',
                icon: Icons.delete_sweep_rounded,
                iconColor: Colors.red,
              ),
            ),
          ),
          // Cash Control Routes
          GoRoute(
            path: '/adjustments/cash-movements',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ComingSoonPage(
                title: 'Ingresos/Egresos de Caja',
                description:
                    'Registrar movimientos de efectivo no relacionados con ventas',
                icon: Icons.swap_vert_rounded,
                iconColor: Colors.orange,
              ),
            ),
          ),
          GoRoute(
            path: '/adjustments/cash-adjustment',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ComingSoonPage(
                title: 'Ajuste de Recibidos',
                description:
                    'Corregir montos recibidos en caja por errores de cambio',
                icon: Icons.account_balance_rounded,
                iconColor: Colors.deepOrange,
              ),
            ),
          ),

          GoRoute(
            path: '/users-permissions',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: UsersPermissionsPage()),
          ),
          GoRoute(
            path: '/tax-store-config',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: TaxStoreConfigPage()),
          ),

          GoRoute(
            path: '/shift-close',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ShiftClosePage()),
          ),
        ],
      ),
    ],

    redirect: (context, state) {
      final location = state.matchedLocation;

      final authLoading = authState.status == AuthStatus.loading;

      final loggedIn = authState.status == AuthStatus.authenticated;
      final isAtLogin = location == '/login';
      final isAtCreateAccount = location == '/create-account';
      final isAtSplash = location == '/splash';

      if (authLoading) {
        return '/splash';
      }

      if (loggedIn) {
        final isAdmin = authState.user?.role == UserRole.administrador;
        final targetHome = isAdmin ? '/' : '/home';

        if (isAtLogin || isAtSplash || isAtCreateAccount) {
          return targetHome;
        }

        final onAdminPage = location == '/';
        final onCashierPage = location == '/home';

        if (isAdmin && onCashierPage) return '/';
        if (!isAdmin && onAdminPage) return '/home';

        return null;
      }

      if (!isAtLogin && !isAtCreateAccount) {
        return '/login';
      }

      return null; // No redirection needed
    },
  );
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
