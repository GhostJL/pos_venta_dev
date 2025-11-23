import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/brand.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/providers/brand_providers.dart';
import 'package:posventa/presentation/widgets/custom_data_table.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/widgets/common/confirm_delete_dialog.dart';
import 'package:posventa/presentation/widgets/common/status_chip.dart';
import 'package:posventa/presentation/widgets/common/data_table_actions.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';

class BrandsPage extends ConsumerWidget {
  const BrandsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandList = ref.watch(brandListProvider);
    final hasManagePermission = ref.watch(
      hasPermissionProvider(PermissionConstants.catalogManage),
    );

    void navigateToForm([Brand? brand]) {
      context.push('/brands/form', extra: brand);
    }

    void confirmDelete(BuildContext context, WidgetRef ref, Brand brand) {
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
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    brand.code,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                DataCell(StatusChip(isActive: brand.isActive)),
                DataCell(
                  DataTableActions(
                    hasEditPermission: hasManagePermission,
                    hasDeletePermission: hasManagePermission,
                    onEdit: () => navigateToForm(brand),
                    onDelete: () => confirmDelete(context, ref, brand),
                    editTooltip: 'Editar Marca',
                    deleteTooltip: 'Eliminar Marca',
                  ),
                ),
              ],
            );
          }).toList(),
          itemCount: brands.length,
          onAddItem: hasManagePermission ? () => navigateToForm() : () {},
          emptyText: 'No se encontraron marcas. ¡Añade una para empezar!',
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
