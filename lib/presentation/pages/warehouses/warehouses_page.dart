import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/warehouse.dart';
import 'package:posventa/presentation/providers/warehouse_providers.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/widgets/catalog/warehouses/warehouse_form_widget.dart';
import 'package:posventa/presentation/widgets/common/actions/catalog_module_actions_sheet.dart';
import 'package:posventa/presentation/widgets/common/pages/generic_module_list_page.dart';
import 'package:posventa/presentation/mixins/page_lifecycle_mixin.dart';

class WarehousesPage extends ConsumerStatefulWidget {
  const WarehousesPage({super.key});

  @override
  ConsumerState<WarehousesPage> createState() => _WarehousesPageState();
}

class _WarehousesPageState extends ConsumerState<WarehousesPage>
    with PageLifecycleMixin {
  @override
  List<dynamic> get providersToInvalidate => [warehouseProvider];

  void _showWarehouseForm([Warehouse? warehouse]) {
    showDialog(
      context: context,
      builder: (context) => WarehouseFormWidget(warehouse: warehouse),
    );
  }

  @override
  Widget build(BuildContext context) {
    final warehousesAsync = ref.watch(warehouseProvider);
    final hasManagePermission = ref.watch(
      hasPermissionProvider(PermissionConstants.catalogManage),
    );

    return GenericModuleListPage<Warehouse>(
      title: 'Gestión de Almacenes',
      items: warehousesAsync.asData?.value ?? [],
      isLoading: warehousesAsync.isLoading,
      emptyIcon: Icons.warehouse_rounded,
      emptyMessage: 'No se encontraron almacenes',
      addButtonLabel: 'Añadir Almacén',
      onAddPressed: hasManagePermission ? () => _showWarehouseForm() : null,
      filterPlaceholder: 'Buscar almacenes...',
      filterCallback: (warehouse, query) =>
          warehouse.name.toLowerCase().contains(query.toLowerCase()),
      itemBuilder: (context, warehouse) {
        return _WarehouseCard(
          warehouse: warehouse,
          onEdit: () => _showWarehouseForm(warehouse),
          onDelete: () => _showWarehouseForm(warehouse),
        );
      },
    );
  }
}

class _WarehouseCard extends StatelessWidget {
  final Warehouse warehouse;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _WarehouseCard({
    required this.warehouse,
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
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.6)),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icono
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: warehouse.isActive
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      warehouse.isMain
                          ? Icons.store_mall_directory_rounded
                          : Icons.warehouse_rounded,
                      color: warehouse.isActive
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Información Principal
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                warehouse.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: warehouse.isActive
                                      ? colorScheme.onSurface
                                      : colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ),
                            if (!warehouse.isActive)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.errorContainer.withOpacity(
                                    0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Inactivo',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onErrorContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          warehouse.code,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontFamily: 'Monospace',
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Acción
                  IconButton(
                    icon: const Icon(Icons.more_vert_rounded),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => CatalogModuleActionsSheet(
                          icon: Icons.warehouse_rounded,
                          title: warehouse.name,
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

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Detalles (Dirección y Teléfono)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          context,
                          Icons.location_on_outlined,
                          warehouse.address?.isNotEmpty == true
                              ? warehouse.address!
                              : 'Sin dirección',
                          isPlaceholder: warehouse.address?.isEmpty ?? true,
                        ),
                        const SizedBox(height: 6),
                        _buildInfoRow(
                          context,
                          Icons.phone_outlined,
                          warehouse.phone?.isNotEmpty == true
                              ? warehouse.phone!
                              : 'Sin teléfono',
                          isPlaceholder: warehouse.phone?.isEmpty ?? true,
                        ),
                      ],
                    ),
                  ),
                  if (warehouse.isMain)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: colorScheme.onTertiaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Principal',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onTertiaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String text, {
    bool isPlaceholder = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: isPlaceholder
              ? colorScheme.onSurfaceVariant.withOpacity(0.5)
              : colorScheme.primary.withOpacity(0.7),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isPlaceholder
                  ? colorScheme.onSurfaceVariant.withOpacity(0.5)
                  : colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
