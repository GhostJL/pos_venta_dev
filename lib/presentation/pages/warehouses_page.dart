import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/warehouse.dart';
import 'package:posventa/presentation/providers/warehouse_providers.dart';
import 'package:posventa/presentation/widgets/custom_data_table.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/widgets/common/status_chip.dart';
import 'package:posventa/presentation/widgets/common/data_table_actions.dart';

import 'package:posventa/presentation/widgets/warehouse_form_widget.dart';

class WarehousesPage extends ConsumerWidget {
  const WarehousesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warehousesAsync = ref.watch(warehouseProvider);
    final hasManagePermission = ref.watch(
      hasPermissionProvider(PermissionConstants.catalogManage),
    );

    void showWarehouseForm([Warehouse? warehouse]) {
      showDialog(
        context: context,
        builder: (context) => WarehouseFormWidget(warehouse: warehouse),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Almacenes'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: warehousesAsync.when(
          data: (warehouses) {
            return CustomDataTable<Warehouse>(
              itemCount: warehouses.length,
              onAddItem: hasManagePermission
                  ? () => showWarehouseForm()
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
                            ? AppTheme.primary.withAlpha(25)
                            : AppTheme.inputBackground,
                        labelStyle: TextStyle(
                          color: warehouse.isMain
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
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
                        onEdit: () => showWarehouseForm(warehouse),
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
