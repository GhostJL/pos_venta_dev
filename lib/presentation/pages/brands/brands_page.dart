import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/brand.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/providers/brand_providers.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/widgets/common/confirm_delete_dialog.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/widgets/common/actions/catalog_module_actions_sheet.dart';
import 'package:posventa/presentation/widgets/common/pages/generic_module_list_page.dart';
import 'package:posventa/presentation/mixins/page_lifecycle_mixin.dart';

class BrandsPage extends ConsumerStatefulWidget {
  const BrandsPage({super.key});

  @override
  ConsumerState<BrandsPage> createState() => _BrandsPageState();
}

class _BrandsPageState extends ConsumerState<BrandsPage>
    with PageLifecycleMixin {
  @override
  List<dynamic> get providersToInvalidate => [brandListProvider];

  void _navigateToForm([Brand? brand]) {
    context.push('/brands/form', extra: brand);
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Brand brand) {
    ConfirmDeleteDialog.show(
      context: context,
      itemName: brand.name,
      itemType: 'la marca',
      onConfirm: () {
        ref.read(brandListProvider.notifier).deleteBrand(brand.id!);
      },
      successMessage: 'Marca eliminada correctamente',
    );
  }

  @override
  Widget build(BuildContext context) {
    final brandList = ref.watch(brandListProvider);
    final hasManagePermission = ref.watch(
      hasPermissionProvider(PermissionConstants.catalogManage),
    );

    return GenericModuleListPage<Brand>(
      title: 'Marcas',
      items: brandList.asData?.value ?? [],
      isLoading: brandList.isLoading,
      emptyIcon: Icons.label_off_rounded,
      emptyMessage: 'No se encontraron marcas',
      addButtonLabel: 'Añadir Marca',
      onAddPressed: hasManagePermission ? () => _navigateToForm() : null,
      filterPlaceholder: 'Buscar marcas...',
      filterCallback: (brand, query) =>
          brand.name.toLowerCase().contains(query.toLowerCase()),
      itemBuilder: (context, brand) {
        return _BrandCard(
          brand: brand,
          onEdit: () => _navigateToForm(brand),
          onDelete: () => _confirmDelete(context, ref, brand),
        );
      },
    );
  }
}

class _BrandCard extends StatelessWidget {
  final Brand brand;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BrandCard({
    required this.brand,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLowest,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: brand.isActive
                          ? colorScheme.primaryContainer.withValues(alpha: 0.4)
                          : colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.label_rounded,
                      color: brand.isActive
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      brand.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: brand.isActive
                            ? colorScheme.onSurface
                            : colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert_rounded),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => CatalogModuleActionsSheet(
                          icon: Icons.label_rounded,
                          title: brand.name,
                          onEdit: () {
                            Navigator.pop(context);
                            onEdit();
                          },
                          onDelete: () {
                            Navigator.pop(context);
                            onDelete();
                          },
                        ),
                      );
                    },
                    visualDensity: VisualDensity.compact,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),

              if (!brand.isActive) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Marca Inactiva',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
