import 'package:flutter/material.dart';
import 'package:posventa/presentation/widgets/common/confirm_delete_sheet.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/category.dart';
import 'package:posventa/domain/entities/department.dart';
import 'package:posventa/presentation/providers/category_providers.dart';
import 'package:posventa/presentation/providers/department_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/widgets/common/actions/catalog_module_actions_sheet.dart';
import 'package:posventa/presentation/widgets/common/pages/generic_module_list_page.dart';
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
    ConfirmDeleteSheet.show(
      context: context,
      itemName: category.name,
      itemType: 'la categoría',
      onConfirm: () async {
        await ref
            .read(categoryListProvider.notifier)
            .deleteCategory(category.id!);
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

    return GenericModuleListPage<Category>(
      title: 'Categorías',
      items: categoriesAsync.asData?.value ?? [],
      isLoading: categoriesAsync.isLoading,
      emptyIcon: Icons.category_rounded,
      emptyMessage: 'No se encontraron categorías',
      addButtonLabel: 'Añadir Categoría',
      onAddPressed: hasManagePermission ? () => _navigateToForm() : null,
      filterPlaceholder: 'Buscar categorías...',
      filterCallback: (category, query) =>
          category.name.toLowerCase().contains(query.toLowerCase()),
      itemBuilder: (context, category) {
        final departmentName =
            departments.asData?.value
                .cast<Department>()
                .firstWhere(
                  (d) => d.id == category.departmentId,
                  orElse: () =>
                      Department(name: 'N/A', code: '', isActive: true),
                )
                .name ??
            'N/A';

        return _CategoryCard(
          category: category,
          departmentName: departmentName,
          onEdit: () => _navigateToForm(category),
          onDelete:
              hasManagePermission &&
                  ref.read(authProvider).user?.role == UserRole.administrador
              ? () => _confirmDelete(context, ref, category)
              : null,
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final String departmentName;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  const _CategoryCard({
    required this.category,
    required this.departmentName,
    required this.onEdit,
    this.onDelete,
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
                      color: category.isActive
                          ? colorScheme.secondaryContainer.withValues(
                              alpha: 0.5,
                            )
                          : colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.category_rounded,
                      color: category.isActive
                          ? colorScheme.onSecondaryContainer
                          : colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      category.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: category.isActive
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
                          icon: Icons.category_rounded,
                          title: category.name,
                          onEdit: onEdit,
                          onDelete: onDelete,
                        ),
                      );
                    },
                    visualDensity: VisualDensity.compact,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Icon(
                    Icons.apartment_rounded,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Departamento:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        departmentName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),

              if (!category.isActive) ...[
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
                      'Categoría Inactiva',
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
