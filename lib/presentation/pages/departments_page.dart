import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/domain/entities/department.dart';
import 'package:myapp/presentation/providers/department_providers.dart';

class DepartmentsPage extends ConsumerWidget {
  const DepartmentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departmentsAsyncValue = ref.watch(departmentListProvider);

    return Scaffold(
      body: departmentsAsyncValue.when(
        data: (departments) {
          if (departments.isEmpty) {
            return const Center(
              child: Text(
                'No se encontraron departamentos. ¡Añade uno para empezar!',
                style: TextStyle(fontSize: 16),
              ),
            );
          }
          return ListView.builder(
            itemCount: departments.length,
            itemBuilder: (context, index) {
              final department = departments[index];
              return ListTile(
                title: Text(department.name),
                subtitle: Text(department.code),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    department.isActive
                        ? const Icon(Icons.check_circle, color: Colors.green, semanticLabel: 'Activo')
                        : const Icon(Icons.cancel, color: Colors.red, semanticLabel: 'Inactivo'),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                      tooltip: 'Editar Departamento',
                      onPressed: () => _showEditDepartmentDialog(context, ref, department),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      tooltip: 'Eliminar Departamento',
                      onPressed: () => _showDeleteConfirmationDialog(context, ref, department.id!),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDepartmentDialog(context, ref),
        tooltip: 'Añadir Departamento',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showEditDepartmentDialog(BuildContext context, WidgetRef ref, Department department) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: department.name);
    final codeController = TextEditingController(text: department.code);
    final descriptionController = TextEditingController(text: department.description);
    bool isActive = department.isActive;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Editar Departamento'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, introduce un nombre';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: codeController,
                        decoration: const InputDecoration(labelText: 'Código'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, introduce un código';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: 'Descripción'),
                      ),
                      SwitchListTile(
                        title: const Text('Activo'),
                        value: isActive,
                        onChanged: (bool value) {
                          setState(() {
                            isActive = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Guardar'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final updatedDepartment = Department(
                    id: department.id,
                    name: nameController.text,
                    code: codeController.text,
                    description: descriptionController.text,
                    isActive: isActive,
                    displayOrder: department.displayOrder,
                  );
                  ref.read(departmentListProvider.notifier).updateDepartment(updatedDepartment);
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref, int departmentId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('¿Estás seguro de que quieres eliminar este departamento?'),
                Text('Esta acción no se puede deshacer.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Eliminar'),
              onPressed: () {
                ref.read(departmentListProvider.notifier).deleteDepartment(departmentId);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddDepartmentDialog(BuildContext context, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final descriptionController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Añadir Nuevo Departamento'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, introduce un nombre';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: codeController,
                    decoration: const InputDecoration(labelText: 'Código'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, introduce un código';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Añadir'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newDepartment = Department(
                    name: nameController.text,
                    code: codeController.text,
                    description: descriptionController.text,
                    displayOrder: 0,
                    isActive: true,
                  );
                  ref.read(departmentListProvider.notifier).addDepartment(newDepartment);
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
