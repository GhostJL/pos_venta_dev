import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/core/constants/permission_constants.dart';

import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/providers/product_provider.dart';

class ProductActionsSheet extends ConsumerWidget {
  final Product product;

  const ProductActionsSheet({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasManagePermission = ref.watch(
      hasPermissionProvider(PermissionConstants.catalogManage),
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(context),
            const SizedBox(height: 12),
            if (hasManagePermission) ...[
              _buildAction(
                context,
                icon: Icons.edit_rounded,
                color: Theme.of(context).colorScheme.primary,
                label: 'Editar producto',
                onTap: () {
                  context.pop();
                  context.push('/products/form', extra: product);
                },
              ),
              const SizedBox(height: 12),
              _buildAction(
                context,
                icon: Icons.copy_rounded,
                color: Theme.of(context).colorScheme.secondary,
                label: 'Duplicar producto',
                onTap: () {
                  context.pop();
                  final newProduct = product.copyWith(
                    id: null,
                    name: '${product.name} (Copia)',
                  );
                  context.push('/products/form', extra: newProduct);
                },
              ),
              const SizedBox(height: 12),
              _buildAction(
                context,
                icon: Icons.power_settings_new_rounded,
                color: product.isActive
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.tertiary,
                label: product.isActive
                    ? 'Desactivar producto'
                    : 'Activar producto',
                onTap: () => _handleToggleActive(context, ref),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHandle(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildAction(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleToggleActive(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(productNotifierProvider.notifier)
          .toggleProductActive(product.id!);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              !product.isActive ? 'Producto activado' : 'Producto desactivado',
            ),
            backgroundColor: !product.isActive
                ? Theme.of(context).colorScheme.tertiary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cambiar estado: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
