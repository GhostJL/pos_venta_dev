import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/widgets/pos/sale/cart_section.dart';
import 'package:posventa/presentation/widgets/pos/product_grid_section.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/providers/pos_providers.dart';

class PosSalesPage extends ConsumerStatefulWidget {
  const PosSalesPage({super.key});

  @override
  ConsumerState<PosSalesPage> createState() => _PosSalesPageState();
}

class _PosSalesPageState extends ConsumerState<PosSalesPage> {
  // Focus nodes for keyboard navigation
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handlePayShortcut() {
    // Only proceed if cart is not empty
    final cart = ref.read(pOSProvider).cart;
    if (cart.isNotEmpty) {
      context.push('/pos/payment');
    }
  }

  void _handleFocusSearch() {
    _searchFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final hasAccess = ref.watch(
      hasPermissionProvider(PermissionConstants.posAccess),
    );

    if (!hasAccess) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'No tienes acceso al Punto de Venta',
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        // F1: Focus Search
        const SingleActivator(LogicalKeyboardKey.f1): _handleFocusSearch,
        // F5: Pay
        const SingleActivator(LogicalKeyboardKey.f5): _handlePayShortcut,
        // Esc: Clear Search / Unfocus (Handled inside widgets usually, but we can add global here)
        const SingleActivator(LogicalKeyboardKey.escape): () {
          FocusScope.of(context).unfocus();
        },
      },
      child: FocusScope(
        autofocus: true,
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Breakpoints
                final width = constraints.maxWidth;
                final isMobile = width < 700;
                // final isTablet = width >= 700 && width < 1200;
                // final isDesktop = width >= 1200;

                if (isMobile) {
                  return _MobileLayout(searchFocusNode: _searchFocusNode);
                } else {
                  return _DesktopLayout(searchFocusNode: _searchFocusNode);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  final FocusNode searchFocusNode;

  const _MobileLayout({required this.searchFocusNode});

  @override
  Widget build(BuildContext context) {
    return ProductGridSection(isMobile: true, searchFocusNode: searchFocusNode);
  }
}

class _DesktopLayout extends StatelessWidget {
  final FocusNode searchFocusNode;

  const _DesktopLayout({required this.searchFocusNode});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Product Grid Area - Takes up more space
        Expanded(
          flex: 6, // 60% width
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surface,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: ProductGridSection(
                isMobile: false,
                searchFocusNode: searchFocusNode,
              ),
            ),
          ),
        ),

        // Cart Area - Takes up less space but remains readable
        Expanded(
          flex: 4, // 40% width
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
            child: Card(
              elevation: 4,
              shadowColor: Colors.black12,
              color: Theme.of(context).colorScheme.surface,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const CartSection(isMobile: false),
            ),
          ),
        ),
      ],
    );
  }
}
