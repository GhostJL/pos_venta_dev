import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/brand.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/presentation/providers/brand_providers.dart';
import 'package:posventa/presentation/widgets/common/cards/card_base_module_widget.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/widgets/common/confirm_delete_dialog.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/widgets/common/async_value_handler.dart';
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

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: AsyncValueHandler<List<Brand>>(
        value: brandList,
        data: (brands) {
          if (brands.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.build,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No se encontraron marcas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (hasManagePermission)
                    ElevatedButton.icon(
                      onPressed: () => _navigateToForm(),
                      icon: const Icon(Icons.add),
                      label: const Text('Añadir Marca'),
                    ),
                ],
              ),
            );
          }
          return ListView.separated(
            itemCount: brands.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final brand = brands[index];

              return CardBaseModuleWidget(
                icon: Icons.label_rounded,
                title: brand.name,
                onEdit: () => _navigateToForm(brand),
                onDelete: () => _confirmDelete(context, ref, brand),
                isActive: brand.isActive,
              );
            },
          );
        },
      ),
    );
  }
}
