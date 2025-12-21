import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/widgets/pos/sale/cart_section.dart';
import 'package:posventa/presentation/widgets/pos/product_grid_section.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';

class PosSalesPage extends ConsumerWidget {
  const PosSalesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              SizedBox(height: 16),
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

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determinar si es móvil o tablet basado en el ancho
          final isMobile = constraints.maxWidth < 600;
          final isTablet =
              constraints.maxWidth >= 600 && constraints.maxWidth < 1200;
          final isDesktop = constraints.maxWidth >= 1200;

          // Determinar orientación
          final isPortrait = constraints.maxHeight > constraints.maxWidth;

          if (isMobile) {
            // Móvil: usar tabs para alternar entre productos y carrito
            return const _MobileLayout();
          } else if (isTablet && isPortrait) {
            // Tablet vertical: productos arriba, carrito abajo
            return const _TabletPortraitLayout();
          } else {
            // Tablet horizontal o Desktop: productos izquierda, carrito derecha
            return const _TabletLandscapeLayout();
          }
        },
      ),
    );
  }
}

// Layout para móviles sin tabs (diseño refactorizado)
class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return const ProductGridSection(isMobile: true);
  }
}

// Layout para tablet en vertical
class _TabletPortraitLayout extends StatelessWidget {
  const _TabletPortraitLayout();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(flex: 6, child: ProductGridSection(isMobile: false)),
        Expanded(flex: 4, child: CartSection(isMobile: false)),
      ],
    );
  }
}

// Layout para tablet horizontal y desktop
class _TabletLandscapeLayout extends StatelessWidget {
  const _TabletLandscapeLayout();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 7, child: ProductGridSection(isMobile: false)),
        Expanded(flex: 3, child: CartSection(isMobile: false)),
      ],
    );
  }
}
