import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/presentation/pages/inventory/inventory_lot_detail_page.dart';
import 'package:posventa/presentation/pages/inventory/inventory_lots_page.dart';
import 'package:posventa/presentation/pages/settings/backup/backup_settings_page.dart';

import 'package:posventa/presentation/pages/shared/main_layout.dart';

import 'package:posventa/presentation/pages/adjustments/return_processing_page.dart';
import 'package:posventa/presentation/pages/adjustments/returns_management_page.dart';
import 'package:posventa/presentation/pages/adjustments/shift_close_page.dart';
import 'package:posventa/presentation/pages/brands/brands_page.dart';
import 'package:posventa/presentation/pages/cash/cash_session_close_page.dart';
import 'package:posventa/presentation/pages/cash/cash_movements_page.dart';
import 'package:posventa/presentation/pages/cash/cash_session_detail_page.dart';
import 'package:posventa/presentation/pages/cash/cash_session_history_page.dart';
import 'package:posventa/presentation/pages/cash/cash_session_open_page.dart';
import 'package:posventa/presentation/pages/cashier/cashier_form_page.dart';
import 'package:posventa/presentation/pages/cashier/cashier_list_page.dart';
import 'package:posventa/presentation/pages/cashier/cashier_permissions_page.dart';
import 'package:posventa/presentation/pages/categories/categories_page.dart';
import 'package:posventa/presentation/pages/customers/customers_page.dart';
import 'package:posventa/presentation/pages/customers/customer_details_page.dart';

import 'package:posventa/presentation/pages/dashboards/dashboard_admin_page.dart';
import 'package:posventa/presentation/pages/dashboards/dashboard_cashier_page.dart';
import 'package:posventa/presentation/pages/departaments/departments_page.dart';
import 'package:posventa/presentation/pages/inventory/inventory_page.dart';
import 'package:posventa/presentation/pages/inventory/inventory_notifications_page.dart';
import 'package:posventa/presentation/pages/login/login_page.dart';
import 'package:posventa/presentation/pages/login/create_account/create_account_page.dart';
import 'package:posventa/presentation/pages/pos_sale/pos_sales_page.dart';
import 'package:posventa/presentation/pages/pos_sale/cart_page.dart';
import 'package:posventa/presentation/pages/pos_sale/payment_page.dart';
import 'package:posventa/presentation/pages/products/products_page.dart';
import 'package:posventa/presentation/pages/products/bulk_import_page.dart';
import 'package:posventa/presentation/pages/purchase/purchase_detail_page.dart';
import 'package:posventa/presentation/pages/purchase/purchase_form_page.dart';
import 'package:posventa/presentation/pages/purchase/purchase_header_page.dart';
import 'package:posventa/presentation/pages/purchase/purchase_item_detail_page.dart';
import 'package:posventa/presentation/pages/purchase/purchase_item_form_page.dart';
import 'package:posventa/presentation/pages/purchase/purchase_items_page.dart';
import 'package:posventa/presentation/pages/purchase/reception/purchase_reception_page.dart';
import 'package:posventa/presentation/pages/purchase/purchases_page.dart';
import 'package:posventa/presentation/pages/sale/sale_detail_page.dart';
import 'package:posventa/presentation/pages/sale/sale_returns_detail_page.dart';
import 'package:posventa/presentation/pages/sale/sales_history_page.dart';
import 'package:posventa/presentation/pages/suppliers/suppliers_page.dart';
import 'package:posventa/presentation/pages/store/store_page.dart';
import 'package:posventa/presentation/pages/tax/tax_rate_page.dart';
import 'package:posventa/presentation/pages/settings/settings_page.dart';
import 'package:posventa/presentation/pages/settings/help/app_shortcuts_page.dart';
import 'package:posventa/presentation/pages/settings/hardware_settings_page.dart';
import 'package:posventa/presentation/pages/settings/print_settings_page.dart';
import 'package:posventa/presentation/pages/settings/ticket/ticket_config_page.dart';
import 'package:posventa/features/reports/presentation/pages/reports_page.dart';

import 'package:posventa/presentation/pages/users/users_permissions_page.dart';
import 'package:posventa/presentation/pages/warehouses/warehouses_page.dart';
import 'package:posventa/presentation/widgets/common/misc/barcode_scanner_widget.dart';
import 'package:posventa/presentation/widgets/common/misc/scanner_arguments.dart';
import 'package:posventa/presentation/widgets/cash_sessions/misc/cash_session_guard.dart';

import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';

import 'package:posventa/presentation/pages/products/product_form_page.dart';
import 'package:posventa/presentation/widgets/products/forms/variant_form_page.dart';
import 'package:posventa/presentation/widgets/catalog/brands/brand_form.dart';
import 'package:posventa/presentation/widgets/catalog/categories/category_form.dart';
import 'package:posventa/presentation/widgets/catalog/customers/customer_form.dart';
import 'package:posventa/presentation/widgets/catalog/departments/department_form.dart';
import 'package:posventa/presentation/widgets/catalog/suppliers/supplier_form.dart';

import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/pages/products/product_history_page.dart';
import 'package:posventa/presentation/pages/products/matrix_generator/matrix_generator_page.dart';

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
        builder: (context, state, child) =>
            MainLayout(child: CashSessionGuard(child: child)),
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
            path: '/inventory/notifications',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: InventoryNotificationsPage()),
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
            path: '/store',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: StorePage()),
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
            routes: [
              GoRoute(
                path: 'form',
                pageBuilder: (context, state) {
                  final customer = state.extra as Customer?;
                  return NoTransitionPage(
                    child: CustomerForm(customer: customer),
                  );
                },
              ),
              GoRoute(
                path: ':id',
                pageBuilder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return NoTransitionPage(
                    child: CustomerDetailsPage(customerId: id),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/sales',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: PosSalesPage()),
          ),
          GoRoute(
            path: '/cart',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CartPage()),
          ),
          GoRoute(
            path: '/pos/payment',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: PaymentPage()),
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
          GoRoute(
            path: '/purchases/reception/:id',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return NoTransitionPage(
                child: PurchaseReceptionPage(purchaseId: int.parse(id)),
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
            path: '/products/new',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProductFormPage(product: null)),
          ),
          GoRoute(
            path: '/products/matrix-generator',
            pageBuilder: (context, state) {
              final productId = state.extra as int?;
              return NoTransitionPage(
                child: MatrixGeneratorPage(productId: productId ?? 0),
              );
            },
          ),
          GoRoute(
            path: '/products/import_csv',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: BulkImportPage()),
          ),
          GoRoute(
            path: '/product-form/variant',
            pageBuilder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return NoTransitionPage(
                child: VariantFormPage(
                  variant: extra?['variant'],
                  productId: extra?['productId'],
                  existingBarcodes: extra?['existingBarcodes'],
                  availableVariants: extra?['availableVariants'],
                  initialType: extra?['initialType'] as VariantType?,
                ),
              );
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
              final args = state.extra as ScannerArguments?;
              return NoTransitionPage(
                child: BarcodeScannerWidget(
                  args: args,
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
            path: '/adjustments/return-processing',
            pageBuilder: (context, state) {
              final sale = state.extra as Sale?;
              return NoTransitionPage(child: ReturnProcessingPage(sale: sale));
            },
          ),

          // Physical Inventory Routes

          // Cash Control Routes
          GoRoute(
            path: '/users-permissions',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: UsersPermissionsPage()),
          ),
          GoRoute(
            path: '/cash-movements',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CashMovementsPage()),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SettingsPage()),
          ),
          GoRoute(
            path: '/settings/shortcuts',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: AppShortcutsPage()),
          ),
          GoRoute(
            path: '/settings/hardware',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HardwareSettingsPage()),
          ),
          GoRoute(
            path: '/settings/backup',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: BackupSettingsPage()),
          ),
          GoRoute(
            path: '/settings/print',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: PrintSettingsPage()),
          ),
          GoRoute(
            path: '/settings/ticket',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: TicketConfigPage()),
          ),

          GoRoute(
            path: '/reports',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ReportsPage()),
          ),

          GoRoute(
            path: '/shift-close',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ShiftClosePage()),
          ),
          GoRoute(
            path: '/inventory/lots/:productId/:warehouseId',
            pageBuilder: (context, state) {
              final productId = int.parse(state.pathParameters['productId']!);
              final warehouseId = int.parse(
                state.pathParameters['warehouseId']!,
              );
              final extra = state.extra as Map<String, dynamic>?;
              final productName = extra?['productName'] as String?;
              final variantIdStr = state.uri.queryParameters['variantId'];
              final variantId = variantIdStr != null
                  ? int.tryParse(variantIdStr)
                  : null;

              return NoTransitionPage(
                child: InventoryLotsPage(
                  productId: productId,
                  warehouseId: warehouseId,
                  productName: productName,
                  variantId: variantId,
                ),
              );
            },
          ),
          GoRoute(
            path: '/inventory/lot/:lotId',
            pageBuilder: (context, state) {
              final lotId = state.pathParameters['lotId']!;
              return NoTransitionPage(
                child: InventoryLotDetailPage(lotId: int.parse(lotId)),
              );
            },
          ),
          GoRoute(
            path: '/products/history/:productId',
            pageBuilder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final product = extra?['product'] as Product;
              final variant = extra?['variant'] as ProductVariant?;
              // Fallback to fetching product by ID if not in extra?
              // For now assume extra is provided.
              return NoTransitionPage(
                child: ProductHistoryPage(product: product, variant: variant),
              );
            },
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
