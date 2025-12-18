import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/presentation/pages/products/variant_type_selection_page.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/providers/product_provider.dart';

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
          if (!isTablet) Center(child: _buildHandle(context)),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel(theme, 'Gestión de Catálogo'),
                      const SizedBox(height: 12),
                      _buildFlatAction(
                        context,
                        icon: Icons.edit_outlined,
                        color: theme.colorScheme.primary,
                        label: 'Editar información',
                        subtitle: 'Nombre, códigos y precios base',
                        onTap: () {
                          context.pop();
                          context.push('/products/form', extra: product);
                        },
                      ),
                      _buildFlatAction(
                        context,
                        icon: Icons.inventory_2_outlined,
                        color: Colors.blueGrey,
                        label: 'Variantes y Stock',
                        subtitle: 'Gestionar tallas, colores y existencias',
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
                      _buildFlatAction(
                        context,
                        icon: Icons.copy_all_outlined,
                        color: theme.colorScheme.secondary,
                        label: 'Duplicar producto',
                        subtitle: 'Crear una copia idéntica de este item',
                        onTap: () {
                          context.pop();
                          final newProduct = product.copyWith(
                            id: null,
                            name: '${product.name} (Copia)',
                          );
                          context.push('/products/form', extra: newProduct);
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildSectionLabel(theme, 'Estado del Producto'),
                      const SizedBox(height: 12),
                      _buildFlatAction(
                        context,
                        icon: product.isActive
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: product.isActive
                            ? theme.colorScheme.error
                            : Colors.teal,
                        label: product.isActive
                            ? 'Desactivar para la venta'
                            : 'Activar para la venta',
                        subtitle: product.isActive
                            ? 'Ocultar producto de la caja'
                            : 'Mostrar producto en la caja',
                        onTap: () => _handleToggleActive(context, ref),
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

  Widget _buildSectionLabel(ThemeData theme, String text) {
    return Text(
      text.toUpperCase(),
      style: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
        fontSize: 11,
      ),
    );
  }

  Widget _buildSheetHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
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

  Widget _buildFlatAction(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: theme.colorScheme.outlineVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 32,
      height: 4,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

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
          .toggleProductActive(product.id!);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
