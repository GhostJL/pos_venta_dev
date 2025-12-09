import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/category.dart';
import 'package:posventa/presentation/providers/category_providers.dart';
import 'package:posventa/presentation/providers/department_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/widgets/common/cards/card_base_module_widget.dart';
import 'package:posventa/presentation/widgets/common/confirm_delete_dialog.dart';
import 'package:posventa/presentation/widgets/common/async_value_handler.dart';
import 'package:posventa/presentation/mixins/page_lifecycle_mixin.dart';

class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage>
    with PageLifecycleMixin {
  @override
  List<dynamic> get providersToInvalidate => [categoryListProvider];

  void _navigateToForm([Category? category]) {
    context.push('/categories/form', extra: category);
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Category category) {
    ConfirmDeleteDialog.show(
      context: context,
      itemName: category.name,
      itemType: 'la categoría',
      onConfirm: () {
        ref.read(categoryListProvider.notifier).deleteCategory(category.id!);
      },
      successMessage: 'Categoría eliminada correctamente',
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final departments = ref.watch(departmentListProvider);
    final hasManagePermission = ref.watch(
      hasPermissionProvider(PermissionConstants.catalogManage),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
        actions: [
          if (hasManagePermission)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _navigateToForm(),
            ),
        ],
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: AsyncValueHandler<List<Category>>(
          value: categoriesAsync,
          data: (categories) {
            if (categories.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No se encontraron categorías',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (hasManagePermission)
                      ElevatedButton.icon(
                        onPressed: () => _navigateToForm(),
                        icon: const Icon(Icons.add),
                        label: const Text('Añadir Categoría'),
                      ),
                  ],
                ),
              );
            }

            return ListView.separated(
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final category = categories[index];
                final departmentName =
                    departments.asData?.value
                        .firstWhere((d) => d.id == category.departmentId)
                        .name ??
                    'N/A';

                return CardBaseModuleWidget(
                  icon: Icons.category_outlined,
                  title: category.name,
                  subtitle: 'Departamento',
                  departmentName: departmentName,
                  onEdit: () => _navigateToForm(category),
                  onDelete: () => _confirmDelete(context, ref, category),
                  isActive: category.isActive,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
