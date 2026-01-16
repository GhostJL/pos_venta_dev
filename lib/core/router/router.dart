import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/presentation/pages/inventory/inventory_lot_detail_page.dart';
import 'package:posventa/presentation/pages/inventory/inventory_lots_page.dart';
import 'package:posventa/presentation/pages/settings/backup/backup_settings_page.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/core/utils/role_permissions_helper.dart';

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
import 'package:posventa/presentation/pages/reports/reports_page.dart';
import 'package:posventa/presentation/pages/settings/ticket/unified_ticket_page.dart';
import 'package:posventa/presentation/pages/settings/profile/admin_profile_page.dart';
import 'package:posventa/presentation/pages/settings/profile/change_password_page.dart';

import 'package:posventa/presentation/pages/users/users_permissions_page.dart';
import 'package:posventa/presentation/pages/users/user_form_page.dart';
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
import 'package:posventa/domain/entities/warehouse.dart';
import 'package:posventa/presentation/widgets/catalog/warehouses/warehouse_form_widget.dart';

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
                const AppTransitionPage(child: DashboardAdminPage()),
          ),
          GoRoute(
            path: '/home', // Cashier home
            pageBuilder: (context, state) =>
                const AppTransitionPage(child: DashboardCashierPage()),
          ),
          GoRoute(
            path: '/products',
            pageBuilder: (context, state) =>
                AppTransitionPage(child: ProductsPage()),
          ),
          GoRoute(
            path: '/departments',
            pageBuilder: (context, state) =>
                const AppTransitionPage(child: DepartmentsPage()),
          ),
          GoRoute(
            path: '/categories',
            pageBuilder: (context, state) =>
                const AppTransitionPage(child: CategoriesPage()),
          ),
          GoRoute(
            path: '/brands',
            pageBuilder: (context, state) =>
                const AppTransitionPage(child: BrandsPage()),
          ),
          GoRoute(
            path: '/inventory/notifications',
            pageBuilder: (context, state) =>
                const AppTransitionPage(child: InventoryNotificationsPage()),
          ),
          GoRoute(
            path: '/suppliers',
            pageBuilder: (context, state) =>
                const AppTransitionPage(child: SuppliersPage()),
          ),
          GoRoute(
            path: '/warehouses',
            pageBuilder: (context, state) =>
                const AppTransitionPage(child: WarehousesPage()),
          ),
          GoRoute(
            path: '/warehouses/form',
            pageBuilder: (context, state) {
              final warehouse = state.extra as Warehouse?;
              return AppTransitionPage(
                child: WarehouseForm(warehouse: warehouse),
              );
            },
          ),
          GoRoute(
            path: '/tax-rates',
            pageBuilder: (context, state) =>
                const AppTransitionPage(child: TaxRatePage()),
          ),
          GoRoute(
            path: '/store',
            pageBuilder: (context, state) =>
                const AppTransitionPage(child: StorePage()),
          ),
          GoRoute(
            path: '/inventory',
            pageBuilder: (context, state) =>
                const AppTransitionPage(child: InventoryPage()),
          ),
          GoRoute(
            path: '/customers',
            pageBuilder: (context, state) =>
                const AppTransitionPage(child: CustomersPage()),
            routes: [
              GoRoute(
                path: 'form',
                pageBuilder: (context, state) {
                  final customer = state.extra as Customer?;
                  return AppTransitionPage(
                    child: CustomerForm(customer: customer),
                  );
                },
              ),
              GoRoute(
                path: ':id',
                pageBuilder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return AppTransitionPage(
                    child: CustomerDetailsPage(customerId: id),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/sales',
            pageBuilder: (context, state) =>
                const AppTransitionPage(child: PosSalesPage()),
          ),
          GoRoute(
            path: '/cart',
            pageBuilder: (context, state) =>
                const AppTransitionPage(child: CartPage()),
          ),
          GoRoute(
            path: '/pos/payment',
            pageBuilder: (context, state) =>
                const AppTransitionPage(child: PaymentPage()),
          ),
          GoRoute(
            path: '/sales-history',
            pageBuilder: (context, state) =>
                const AppTransitionPage(child: SalesHistoryPage()),
          ),
          GoRoute(
            path: '/sale-detail/:id',
            pageBuilder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return AppTransitionPage(child: SaleDetailPage(saleId: id));
            },
          ),
          GoRoute(
            path: '/sale-returns-detail/:id',
            pageBuilder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              final sale = state.extra as Sale;
              return AppTransitionPage(
                child: SaleReturnsDetailPage(saleId: id, sale: sale),
              );
            },
          ),
          GoRoute(
            path: '/purchases',
            pageBuilder: (context, state) =>
                const AppTransitionPage(child: PurchasesPage()),
          ),
          GoRoute(
            path: '/purchases/:id',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              if (id == 'new') {
                // Step 1: Header page
                return const AppTransitionPage(child: PurchaseHeaderPage());
              }
              return AppTransitionPage(
                child: PurchaseDetailPage(purchaseId: int.parse(id)),
              );
            },
          ),
          GoRoute(
            path: '/purchases/reception/:id',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return AppTransitionPage(
                child: PurchaseReceptionPage(purchaseId: int.parse(id)),
              );
            },
          ),
          // Step 2: Products page (receives header data)
          GoRoute(
            path: '/purchases/new/products',
            pageBuilder: (context, state) {
              final headerData = state.extra as Map<String, dynamic>?;
              return AppTransitionPage(
                child: PurchaseFormPage(headerData: headerData),
              );
            },
          ),
          // Purchase Items Routes
          GoRoute(
            path: '/purchase-items',
            pageBuilder: (context, state) =>
                const AppTransitionPage(child: PurchaseItemsPage()),
          ),
          GoRoute(
            path: '/purchase-items/:id',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              if (id == 'new') {
                return const AppTransitionPage(child: PurchaseItemFormPage());
              }
              return AppTransitionPage(
                child: PurchaseItemDetailPage(itemId: int.parse(id)),
              );
            },
          ),
          GoRoute(
            path: '/cashiers',
            pageBuilder: (context, state) =>
                const AppTransitionPage(child: CashierListPage()),
          ),
          GoRoute(
            path: '/cash-sessions-history',
            pageBuilder: (context, state) =>
                const AppTransitionPage(child: CashSessionHistoryPage()),
          ),

          // Form Routes
          GoRoute(
            path: '/products/form',
            pageBuilder: (context, state) {
              final product = state.extra as Product?;
              return AppTransitionPage(
                child: ProductFormPage(product: product),
              );
            },
          ),
          GoRoute(
            path: '/products/new',
            pageBuilder: (context, state) =>
                const AppTransitionPage(child: ProductFormPage(product: null)),
          ),
          GoRoute(
            path: '/products/matrix-generator',
            pageBuilder: (context, state) {
              final productId = state.extra as int?;
              return AppTransitionPage(
                child: MatrixGeneratorPage(productId: productId ?? 0),
              );
            },
          ),
          GoRoute(
            path: '/products/import_csv',
            pageBuilder: (context, state) =>
                const AppTransitionPage(child: BulkImportPage()),
          ),
          GoRoute(
            path: '/product-form/variant',
            pageBuilder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return AppTransitionPage(
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
              return AppTransitionPage(child: SupplierForm(supplier: supplier));
            },
          ),
          GoRoute(
            path: '/departments/form',
            pageBuilder: (context, state) {
              final department = state.extra as Department?;
              return AppTransitionPage(
                child: DepartmentForm(department: department),
              );
            },
          ),

          GoRoute(
            path: '/categories/form',
            pageBuilder: (context, state) {
              final category = state.extra as Category?;
              return AppTransitionPage(child: CategoryForm(category: category));
            },
          ),
          GoRoute(
            path: '/brands/form',
            pageBuilder: (context, state) {
              final brand = state.extra as Brand?;
              return AppTransitionPage(child: BrandForm(brand: brand));
            },
          ),

          GoRoute(
            path: '/cashiers/form',
            pageBuilder: (context, state) {
              final cashier = state.extra as User?;
              return AppTransitionPage(
                child: CashierFormPage(cashier: cashier),
              );
            },
          ),
          GoRoute(
            path: '/cashiers/permissions',
            pageBuilder: (context, state) {
              final cashier = state.extra as User;
              return AppTransitionPage(
                child: CashierPermissionsPage(cashier: cashier),
              );
            },
          ),
          GoRoute(
            path: '/cash-sessions/detail',
            pageBuilder: (context, state) {
              final session = state.extra as CashSession;
              return AppTransitionPage(
                child: CashSessionDetailPage(session: session),
              );
            },
          ),
          GoRoute(
            path: '/scanner',
            pageBuilder: (context, state) {
              final args = state.extra as ScannerArguments?;
              return AppTransitionPage(
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
                const AppTransitionPage(child: ReturnsManagementPage()),
          ),

          GoRoute(
            path: '/adjustments/return-processing',
            pageBuilder: (context, state) {
              final sale = state.extra as Sale?;
              return AppTransitionPage(child: ReturnProcessingPage(sale: sale));
            },
          ),

          // Physical Inventory Routes

          // Cash Control Routes
          GoRoute(
            path: '/users-permissions',
            pageBuilder: (context, state) =>
                const AppTransitionPage(child: UsersPermissionsPage()),
            routes: [
              GoRoute(
                path: 'form',
                pageBuilder: (context, state) {
                  final user = state.extra as User?;
                  return AppTransitionPage(child: UserFormPage(user: user));
                },
              ),
            ],
          ),
          GoRoute(
            path: '/cash-movements',
            pageBuilder: (context, state) =>
                const AppTransitionPage(child: CashMovementsPage()),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) =>
                const AppTransitionPage(child: SettingsPage()),
          ),
          GoRoute(
            path: '/settings/shortcuts',
            pageBuilder: (context, state) =>
                const AppTransitionPage(child: AppShortcutsPage()),
          ),
          GoRoute(
            path: '/settings/hardware',
            pageBuilder: (context, state) =>
                const AppTransitionPage(child: HardwareSettingsPage()),
          ),
          GoRoute(
            path: '/settings/backup',
            pageBuilder: (context, state) =>
                const AppTransitionPage(child: BackupSettingsPage()),
          ),
          GoRoute(
            path: '/settings/print',
            pageBuilder: (context, state) =>
                const AppTransitionPage(child: PrintSettingsPage()),
          ),
          GoRoute(
            path: '/settings/business',
            pageBuilder: (context, state) =>
                const AppTransitionPage(child: UnifiedTicketPage()),
          ),
          GoRoute(
            path: '/settings/profile',
            pageBuilder: (context, state) =>
                const AppTransitionPage(child: AdminProfilePage()),
            routes: [
              GoRoute(
                path: 'change-password',
                pageBuilder: (context, state) =>
                    const AppTransitionPage(child: ChangePasswordPage()),
              ),
            ],
          ),

          /* Deprecated routes retained for safety if needed, or removed */
          /*
          GoRoute(
            path: '/settings/ticket',
            pageBuilder: (context, state) =>
                const AppTransitionPage(child: TicketConfigPage()),
          ),
          */
          GoRoute(
            path: '/reports',
            pageBuilder: (context, state) =>
                const AppTransitionPage(child: ReportsPage()),
          ),

          GoRoute(
            path: '/shift-close',
            pageBuilder: (context, state) =>
                const AppTransitionPage(child: ShiftClosePage()),
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

              return AppTransitionPage(
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
              return AppTransitionPage(
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
              return AppTransitionPage(
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

        // Check if user has permission for the requested route
        if (!_checkRouteAccess(location, authState.user!)) {
          // Redirect to appropriate home if access denied
          return targetHome;
        }

        return null;
      }

      if (!isAtLogin && !isAtCreateAccount) {
        return '/login';
      }

      return null; // No redirection needed
    },
  );
});

bool _checkRouteAccess(String location, User user) {
  // 1. Get permissions for the user's role
  final permissions = RolePermissionsHelper.getPermissionsForRole(user.role);

  // 2. Define route -> permission mapping
  // This could be moved to a static config if it grows large
  if (location.startsWith('/users')) {
    // Both /users-permissions and future /users routes
    if (!permissions.contains(PermissionConstants.userManage)) return false;
  }

  if (location.startsWith('/settings')) {
    // Basic settings access
    if (!permissions.contains(PermissionConstants.settingsAccess)) return false;

    // Sub-sections protection
    if (location.contains('/hardware') || location.contains('/backup')) {
      // Only Admin should manage hardware/backup (System Manage)
      // Or explicitly check for SYSTEM_MANAGE if we added it
      if (!permissions.contains(PermissionConstants.systemManage)) return false;
    }
  }

  if (location.startsWith('/products') ||
      location.startsWith('/inventory') ||
      location.startsWith('/purchases') ||
      location.startsWith('/suppliers') ||
      location.startsWith('/departments') ||
      location.startsWith('/categories') ||
      location.startsWith('/brands') ||
      location.startsWith('/warehouses') ||
      location.startsWith('/tax-rates')) {
    // Catalog/Inventory Management
    // We can check for catalogManage or inventoryView depending on strictness
    // For now, let's use catalogManage as a broad gatekeeper for configuration
    // and inventoryView for inventory.

    if (location.startsWith('/inventory')) {
      if (!permissions.contains(PermissionConstants.inventoryView)) {
        return false;
      }
    } else {
      if (!permissions.contains(PermissionConstants.catalogManage)) {
        return false;
      }
    }
  }

  if (location.startsWith('/reports')) {
    if (!permissions.contains(PermissionConstants.reportsView)) return false;
  }

  if (location.startsWith('/customers')) {
    if (!permissions.contains(PermissionConstants.customerManage)) return false;
  }

  return true;
}

class AppTransitionPage<T> extends CustomTransitionPage<T> {
  const AppTransitionPage({super.key, super.name, required super.child})
    : super(
        transitionsBuilder: _transitionsBuilder,
        transitionDuration: const Duration(milliseconds: 150),
        reverseTransitionDuration: const Duration(milliseconds: 150),
      );

  static Widget _transitionsBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurveTween(curve: Curves.easeOut).animate(animation),
      child: child,
    );
  }
}
