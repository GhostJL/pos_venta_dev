import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/core/theme/theme.dart';
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

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          const SizedBox(height: 24),
          if (hasManagePermission) ...[
            _buildEditAction(context),
            const SizedBox(height: 8),
            _buildDuplicateAction(context),
            const SizedBox(height: 8),
            _buildToggleActiveAction(context, ref),
            const SizedBox(height: 8),
            _buildDeleteAction(context),
          ],
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildEditAction(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primary.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.edit_rounded, color: AppTheme.primary),
      ),
      title: const Text(
        'Editar Producto',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      onTap: () {
        context.pop();
        context.push('/products/form', extra: product);
      },
    );
  }

  Widget _buildDuplicateAction(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.secondary.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.copy_rounded, color: AppTheme.secondary),
      ),
      title: const Text(
        'Duplicar Producto',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      onTap: () {
        context.pop();
        final newProduct = product.copyWith(
          id: null,
          name: '${product.name} (Copia)',
        );
        context.push('/products/form', extra: newProduct);
      },
    );
  }

  Widget _buildToggleActiveAction(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (product.isActive ? AppTheme.error : AppTheme.success)
              .withAlpha(20),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.power_settings_new_rounded,
          color: product.isActive ? AppTheme.error : AppTheme.success,
        ),
      ),
      title: Text(
        product.isActive ? 'Desactivar Producto' : 'Activar Producto',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      onTap: () => _handleToggleActive(context, ref),
    );
  }

  Widget _buildDeleteAction(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.error.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.delete_rounded, color: AppTheme.error),
      ),
      title: const Text(
        'Eliminar Producto',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      onTap: () {
        context.pop();
        _showDeleteConfirmation(context);
      },
    );
  }

  Future<void> _handleToggleActive(BuildContext context, WidgetRef ref) async {
    context.pop();
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
                ? AppTheme.success
                : AppTheme.textSecondary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cambiar estado: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Confirmar Eliminación',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            '¿Estás seguro de que quieres eliminar el producto "${product.name}"?',
            style: const TextStyle(fontSize: 16),
          ),
          actionsPadding: const EdgeInsets.all(16),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Eliminar'),
              onPressed: () => _handleDelete(dialogContext, messenger),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleDelete(
    BuildContext dialogContext,
    ScaffoldMessengerState messenger,
  ) async {
    // Get ref from the widget tree
    final container = ProviderScope.containerOf(dialogContext);

    await container
        .read(productNotifierProvider.notifier)
        .deleteProduct(product.id!);

    // Check if context is still mounted before using Navigator
    if (dialogContext.mounted) {
      Navigator.of(dialogContext).pop();
    }

    messenger.showSnackBar(
      const SnackBar(
        content: Text('Producto eliminado correctamente'),
        backgroundColor: AppTheme.success,
      ),
    );
  }
}
