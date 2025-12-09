import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/department.dart';
import 'package:posventa/presentation/providers/department_providers.dart';
import 'package:posventa/presentation/widgets/common/cards/card_base_module_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/core/constants/permission_constants.dart';
import 'package:posventa/presentation/providers/permission_provider.dart';
import 'package:posventa/presentation/widgets/common/confirm_delete_dialog.dart';
import 'package:posventa/presentation/widgets/common/async_value_handler.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Departamentos'),
        actions: [
          if (hasManagePermission)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _navigateToForm(),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: AsyncValueHandler<List<Department>>(
          value: departmentsAsync,
          data: (departments) {
            if (departments.isEmpty) {
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
                      'No se encontraron departamentos',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (hasManagePermission)
                      ElevatedButton.icon(
                        onPressed: () => _navigateToForm(),
                        icon: const Icon(Icons.add),
                        label: const Text('Añadir Departamento'),
                      ),
                  ],
                ),
              );
            }
            return ListView.separated(
              itemCount: departments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final department = departments[index];

                return CardBaseModuleWidget(
                  icon: Icons.apartment_rounded,
                  title: department.name,
                  onEdit: () => _navigateToForm(department),
                  onDelete: () => _confirmDelete(context, ref, department),
                  isActive: department.isActive,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
