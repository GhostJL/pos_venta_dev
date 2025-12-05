import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/brand.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/providers/brand_providers.dart';
import 'package:posventa/presentation/widgets/common/tables/custom_data_table.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/widgets/common/confirm_delete_dialog.dart';
import 'package:posventa/presentation/widgets/common/status_chip.dart';
import 'package:posventa/presentation/widgets/common/data_table_actions.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';

class BrandsPage extends ConsumerStatefulWidget {
  const BrandsPage({super.key});

  @override
  ConsumerState<BrandsPage> createState() => _BrandsPageState();
}

class _BrandsPageState extends ConsumerState<BrandsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(brandListProvider);
    });
  }

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

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: brandList.when(
        data: (brands) => CustomDataTable<Brand>(
          columns: const [
            DataColumn(label: Text('Nombre')),
            DataColumn(label: Text('Código')),
            DataColumn(label: Text('Estado')),
            DataColumn(label: Text('Acciones')),
          ],
          rows: brands.map((brand) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    brand.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    brand.code,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                DataCell(StatusChip(isActive: brand.isActive)),
                DataCell(
                  DataTableActions(
                    hasEditPermission: hasManagePermission,
                    hasDeletePermission: hasManagePermission,
                    onEdit: () => _navigateToForm(brand),
                    onDelete: () => _confirmDelete(context, ref, brand),
                    editTooltip: 'Editar Marca',
                    deleteTooltip: 'Eliminar Marca',
                  ),
                ),
              ],
            );
          }).toList(),
          itemCount: brands.length,
          onAddItem: hasManagePermission ? () => _navigateToForm() : () {},
          emptyText: 'No se encontraron marcas. ¡Añade una para empezar!',
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
