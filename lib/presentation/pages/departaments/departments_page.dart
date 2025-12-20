import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/department.dart';
import 'package:posventa/presentation/providers/department_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/widgets/common/actions/catalog_module_actions_sheet.dart';
import 'package:posventa/presentation/widgets/common/confirm_delete_dialog.dart';
import 'package:posventa/presentation/widgets/common/pages/generic_module_list_page.dart';
import 'package:posventa/presentation/mixins/page_lifecycle_mixin.dart';

class DepartmentsPage extends ConsumerStatefulWidget {
  const DepartmentsPage({super.key});

  @override
  ConsumerState<DepartmentsPage> createState() => _DepartmentsPageState();
}

class _DepartmentsPageState extends ConsumerState<DepartmentsPage>
    with PageLifecycleMixin {
  @override
  List<dynamic> get providersToInvalidate => [departmentListProvider];

  void _navigateToForm([Department? department]) {
    context.push('/departments/form', extra: department);
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Department department,
  ) {
    ConfirmDeleteDialog.show(
      context: context,
      itemName: department.name,
      itemType: 'el departamento',
      onConfirm: () {
        ref
            .read(departmentListProvider.notifier)
            .deleteDepartment(department.id!);
      },
      successMessage: 'Departamento eliminado correctamente',
    );
  }

  @override
  Widget build(BuildContext context) {
    final departmentsAsync = ref.watch(departmentListProvider);
    final hasManagePermission = ref.watch(
      hasPermissionProvider(PermissionConstants.catalogManage),
    );

    return GenericModuleListPage<Department>(
      title: 'Departamentos',
      items: departmentsAsync.asData?.value ?? [],
      isLoading: departmentsAsync.isLoading,
      emptyIcon: Icons.apartment_rounded,
      emptyMessage: 'No se encontraron departamentos',
      addButtonLabel: 'Añadir Departamento',
      onAddPressed: hasManagePermission ? () => _navigateToForm() : null,
      filterPlaceholder: 'Buscar departamentos...',
      filterCallback: (department, query) =>
          department.name.toLowerCase().contains(query.toLowerCase()),
      itemBuilder: (context, department) {
        return _DepartmentCard(
          department: department,
          onEdit: () => _navigateToForm(department),
          onDelete: () => _confirmDelete(context, ref, department),
        );
      },
    );
  }
}

class _DepartmentCard extends StatelessWidget {
  final Department department;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DepartmentCard({
    required this.department,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: department.isActive
                          ? colorScheme.tertiaryContainer
                          : colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.apartment_rounded,
                      color: department.isActive
                          ? colorScheme.onTertiaryContainer
                          : colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                department.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: department.isActive
                                      ? colorScheme.onSurface
                                      : colorScheme.onSurface.withValues(
                                          alpha: 0.6,
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          department.code,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontFamily: 'Monospace',
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert_rounded),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => CatalogModuleActionsSheet(
                          icon: Icons.apartment_rounded,
                          title: department.name,
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

              if (department.description != null &&
                  department.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Text(
                  department.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              if (!department.isActive) ...[
                const SizedBox(height: 12),
                if (department.description == null ||
                    department.description!.isEmpty) ...[
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                ],
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Departamento Inactivo',
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
