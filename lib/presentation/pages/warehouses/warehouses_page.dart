import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:posventa/domain/entities/warehouse.dart';
import 'package:posventa/presentation/providers/warehouse_providers.dart';
import 'package:posventa/presentation/widgets/custom_data_table.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/widgets/common/status_chip.dart';
import 'package:posventa/presentation/widgets/common/data_table_actions.dart';

import 'package:posventa/presentation/widgets/warehouse_form_widget.dart';

class WarehousesPage extends ConsumerStatefulWidget {
  const WarehousesPage({super.key});

  @override
  ConsumerState<WarehousesPage> createState() => _WarehousesPageState();
}

class _WarehousesPageState extends ConsumerState<WarehousesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(warehouseProvider);
    });
  }

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Almacenes'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: warehousesAsync.when(
          data: (warehouses) {
            return CustomDataTable<Warehouse>(
              itemCount: warehouses.length,
              onAddItem: hasManagePermission
                  ? () => _showWarehouseForm()
                  : () {},
              emptyText: 'No hay almacenes registrados.',
              columns: const [
                DataColumn(label: Text('NOMBRE')),
                DataColumn(label: Text('CÓDIGO')),
                DataColumn(label: Text('PRINCIPAL')),
                DataColumn(label: Text('ESTADO')),
                DataColumn(label: Text('ACCIONES')),
              ],
              rows: warehouses.map((warehouse) {
                return DataRow(
                  cells: [
                    DataCell(Text(warehouse.name)),
                    DataCell(Text(warehouse.code)),
                    DataCell(
                      Chip(
                        label: Text(warehouse.isMain ? 'Sí' : 'No'),
                        backgroundColor: warehouse.isMain
                            ? Theme.of(
                                context,
                              ).colorScheme.primary.withAlpha(25)
                            : Theme.of(context).colorScheme.surface,
                        labelStyle: TextStyle(
                          color: warehouse.isMain
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                      ),
                    ),
                    DataCell(
                      StatusChip(
                        isActive: warehouse.isActive,
                        activeText: 'Activo',
                        inactiveText: 'Inactivo',
                      ),
                    ),
                    DataCell(
                      DataTableActions(
                        hasEditPermission: hasManagePermission,
                        hasDeletePermission: hasManagePermission,
                        onEdit: () => _showWarehouseForm(warehouse),
                        onDelete: () {
                          ref
                              .read(warehouseProvider.notifier)
                              .removeWarehouse(warehouse.id!);
                        },
                        editTooltip: 'Editar',
                        deleteTooltip: 'Eliminar',
                      ),
                    ),
                  ],
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}
