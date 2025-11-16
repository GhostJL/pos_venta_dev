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
                'No departments found. Add one to get started!',
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
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.cancel, color: Colors.red),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
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
        tooltip: 'Add Department',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref, int departmentId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this department?'),
                Text('This action cannot be undone.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
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
          title: const Text('Add New Department'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: codeController,
                    decoration: const InputDecoration(labelText: 'Code'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a code';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Add'),
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
