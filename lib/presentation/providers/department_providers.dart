import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:myapp/data/datasources/database_helper.dart';
import 'package:myapp/data/repositories/department_repository_impl.dart';
import 'package:myapp/domain/entities/department.dart';
import 'package:myapp/domain/repositories/department_repository.dart';
import 'package:myapp/domain/use_cases/create_department.dart';
import 'package:myapp/domain/use_cases/delete_department.dart';
import 'package:myapp/domain/use_cases/get_all_departments.dart';

// Provider for DatabaseHelper
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

// Provider for the Repository, now correctly injecting the dependency
final departmentRepositoryProvider = Provider<DepartmentRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return DepartmentRepositoryImpl(dbHelper);
});

// Provider for the GetAllDepartments Use Case
final getAllDepartmentsUseCaseProvider = Provider<GetAllDepartments>((ref) {
  final repository = ref.watch(departmentRepositoryProvider);
  return GetAllDepartments(repository);
});

// Provider for the CreateDepartment Use Case
final createDepartmentUseCaseProvider = Provider<CreateDepartment>((ref) {
  final repository = ref.watch(departmentRepositoryProvider);
  return CreateDepartment(repository);
});

// Provider for the DeleteDepartment Use Case
final deleteDepartmentUseCaseProvider = Provider<DeleteDepartment>((ref) {
  final repository = ref.watch(departmentRepositoryProvider);
  return DeleteDepartment(repository);
});

// StateNotifier for the department list
class DepartmentListNotifier extends StateNotifier<AsyncValue<List<Department>>> {
  final GetAllDepartments _getAllDepartments;
  final CreateDepartment _createDepartment;
  final DeleteDepartment _deleteDepartment;

  DepartmentListNotifier(
    this._getAllDepartments,
    this._createDepartment,
    this._deleteDepartment,
  ) : super(const AsyncValue.loading()) {
    loadDepartments();
  }

  Future<void> loadDepartments() async {
    state = const AsyncValue.loading();
    try {
      final departments = await _getAllDepartments();
      state = AsyncValue.data(departments);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> addDepartment(Department department) async {
    try {
      await _createDepartment(department);
      await loadDepartments(); // Refresh list
    } catch (e) {
      // In a real app, you might want to show an error to the user
      await loadDepartments(); // Ensure UI is consistent
    }
  }

  Future<void> deleteDepartment(int id) async {
    try {
      await _deleteDepartment(id);
      await loadDepartments(); // Refresh list
    } catch (e) {
      // In a real app, you might want to show an error to the user
      await loadDepartments(); // Ensure UI is consistent
    }
  }
}

// The provider for the DepartmentListNotifier
final departmentListProvider =
    StateNotifierProvider<DepartmentListNotifier, AsyncValue<List<Department>>>(
  (ref) {
    final getAll = ref.watch(getAllDepartmentsUseCaseProvider);
    final create = ref.watch(createDepartmentUseCaseProvider);
    final delete = ref.watch(deleteDepartmentUseCaseProvider);
    return DepartmentListNotifier(getAll, create, delete);
  },
);
