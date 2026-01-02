import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/presentation/pages/products/variant_type_selection_page.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/presentation/providers/di/product_di.dart';
import 'package:posventa/presentation/widgets/products/actions/label_print_dialog.dart';
import 'package:posventa/domain/services/label_service.dart';

class ProductActionsSheet extends ConsumerWidget {
  final Product product;

  const ProductActionsSheet({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Container(
      constraints: BoxConstraints(maxWidth: isTablet ? 480 : double.infinity),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // if (!isTablet) Center(child: _buildHandle(context)), // REMOVED: Managed by sheet property
          _buildSheetHeader(theme),
          const Divider(height: 1, thickness: 0.5),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Consumer(
                builder: (context, ref, child) {
                  final hasManagePermission = ref.watch(
                    hasPermissionProvider(PermissionConstants.catalogManage),
                  );

                  if (!hasManagePermission) {
                    return _buildNoPermissionState(theme);
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildCompactAction(
                        context,
                        icon: Icons.edit_outlined,
                        label: 'Editar información',
                        onTap: () {
                          context.pop();
                          context.push('/products/form', extra: product);
                        },
                      ),
                      _buildCompactAction(
                        context,
                        icon: Icons.history,
                        label: 'Historial de Inventario',
                        onTap: () {
                          context.pop();
                          context.push(
                            '/products/history/${product.id}',
                            extra: {'product': product},
                          );
                        },
                      ),
                      if (product.variants?.isNotEmpty ?? false)
                        _buildCompactAction(
                          context,
                          icon: Icons.inventory_2_outlined,
                          label: 'Variantes y Stock',
                          onTap: () {
                            context.pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    VariantTypeSelectionPage(product: product),
                              ),
                            );
                          },
                        ),
                      _buildCompactAction(
                        context,
                        icon: Icons.copy_rounded,
                        label: 'Duplicar producto',
                        onTap: () => _handleDuplicate(context),
                      ),
                      _buildCompactAction(
                        context,
                        icon: Icons.print_outlined,
                        label: 'Imprimir Etiqueta',
                        onTap: () => _handlePrintLabel(context, ref),
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      _buildCompactAction(
                        context,
                        icon: product.isActive
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        label: product.isActive
                            ? 'Desactivar producto'
                            : 'Activar producto',
                        color: product.isActive
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                        onTap: () => _handleToggleActive(context, ref),
                      ),
                      _buildCompactAction(
                        context,
                        icon: Icons.delete_outline_rounded,
                        label: 'Eliminar producto',
                        color: theme.colorScheme.error,
                        onTap: () => _handleDelete(context, ref),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSheetHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8), // Adjusted padding
      // Removed Container decoration for cleaner look
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                    fontSize: 18,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              if (product.isActive)
                _buildStatusChip(Colors.teal, 'ACTIVO')
              else
                _buildStatusChip(theme.colorScheme.error, 'INACTIVO'),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "CÓDIGO: ${product.code}",
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCompactAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final actionColor = color ?? theme.colorScheme.onSurface;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: actionColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: actionColor, size: 20),
      ),
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurface,
        ),
      ),
      onTap: onTap,
      dense: true,
      contentPadding: EdgeInsets.zero,
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 18,
        color: theme.colorScheme.outlineVariant,
      ),
    );
  }

  // Handle is now managed by showModalBottomSheet(showDragHandle: true)

  Widget _buildNoPermissionState(ThemeData theme) {
    return Center(
      child: Text("Sin permisos de edición", style: theme.textTheme.bodySmall),
    );
  }

  Future<void> _handleToggleActive(BuildContext context, WidgetRef ref) async {
    context.pop();
    try {
      await ref
          .read(productNotifierProvider.notifier)
          .toggleActive(product.id!, !product.isActive);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    // 1. Mostrar diálogo de confirmación
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar producto?'),
        content: const Text(
          'Esta acción eliminará el producto permanentemente.\n\n'
          'Solo se permite si el producto NO tiene historial de ventas, compras o movimientos de inventario.\n\n'
          '¿Estás seguro?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancelar
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true), // Confirmar
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // 2. Cerrar el sheet de acciones
    if (context.mounted) {
      Navigator.pop(context);
    }

    // 3. Intentar eliminar
    try {
      await ref
          .read(productNotifierProvider.notifier)
          .deleteProduct(product.id!);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto eliminado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        // Mejorar el mensaje de error si es una restricción de clave foránea
        String errorMessage = e.toString();
        if (errorMessage.contains('FOREIGN KEY constraint failed') ||
            errorMessage.contains('constraint')) {
          errorMessage =
              'No se puede eliminar: El producto tiene historial (ventas o stock). Intenta desactivarlo en su lugar.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Entendido',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  void _handleDuplicate(BuildContext context) {
    context.pop();

    // Create copy with cleared IDs
    final newVariants = product.variants
        ?.map(
          (v) => ProductVariant(
            id: null,
            productId: 0,
            variantName: v.variantName,
            barcode: null,
            quantity: v.quantity,
            priceCents: v.priceCents,
            costPriceCents: v.costPriceCents,
            wholesalePriceCents: v.wholesalePriceCents,
            isActive: true,
            isForSale: v.isForSale,
            type: v.type,
            linkedVariantId: null,
            stock: 0,
            stockMin: v.stockMin,
            stockMax: v.stockMax,
            conversionFactor: v.conversionFactor,
            unitId: v.unitId,
            isSoldByWeight: v.isSoldByWeight,
            photoUrl: v.photoUrl,
          ),
        )
        .toList();

    final newProduct = Product(
      id: null,
      code: '${product.code}-COPY',
      name: '${product.name} (Copia)',
      description: product.description,
      departmentId: product.departmentId,
      departmentName: product.departmentName,
      categoryId: product.categoryId,
      brandId: product.brandId,
      supplierId: product.supplierId,
      isSoldByWeight: product.isSoldByWeight,
      isActive: true,
      hasExpiration: product.hasExpiration,
      productTaxes: product.productTaxes,
      variants: newVariants,
      stock: 0,
      photoUrl: product.photoUrl,
    );

    context.push('/products/form', extra: newProduct);
  }

  Future<void> _handlePrintLabel(BuildContext context, WidgetRef ref) async {
    final labelService = ref.read(labelServiceProvider);
    final navigator = Navigator.of(context);

    navigator.pop(); // Close sheet

    // Use navigator.context which remains valid
    if (navigator.context.mounted) {
      final requests = await showDialog<List<LabelPrintRequest>>(
        context: navigator.context,
        builder: (context) => LabelPrintDialog(product: product),
      );

      if (requests != null && requests.isNotEmpty) {
        try {
          debugPrint('Starting print job for ${requests.length} requests');
          await labelService.printLabels(requests);
        } catch (e) {
          debugPrint('Print error: $e');
          if (navigator.context.mounted) {
            ScaffoldMessenger.of(
              context.mounted ? context : navigator.context,
            ).showSnackBar(SnackBar(content: Text('Error al imprimir: $e')));
          }
        }
      }
    }
  }
}
