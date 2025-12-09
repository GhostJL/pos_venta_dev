import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/warehouse.dart';
import 'package:posventa/presentation/providers/warehouse_providers.dart';
import 'package:posventa/presentation/widgets/common/cards/card_base_module_widget.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/widgets/catalog/warehouses/warehouse_form_widget.dart';
import 'package:posventa/presentation/widgets/common/async_value_handler.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Almacenes'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AsyncValueHandler<List<Warehouse>>(
          value: warehousesAsync,
          data: (warehouses) {
            if (warehouses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warehouse_rounded,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No se encontraron almacenes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (hasManagePermission)
                      ElevatedButton.icon(
                        onPressed: () => _showWarehouseForm(),
                        icon: const Icon(Icons.add),
                        label: const Text('Añadir Almacén'),
                      ),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: warehouses.length,
              itemBuilder: (context, index) {
                final warehouse = warehouses[index];

                return CardBaseModuleWidget(
                  icon: Icons.warehouse_rounded,
                  title: warehouse.name,
                  subtitle: warehouse.isMain
                      ? 'Almacén principal'
                      : 'Almacén secundario',
                  onEdit: () => _showWarehouseForm(warehouse),
                  onDelete: () => _showWarehouseForm(warehouse),
                  isActive: warehouse.isActive,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
