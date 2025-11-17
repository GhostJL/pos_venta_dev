import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/data/repositories/department_repository_impl.dart';
import 'package:posventa/domain/entities/department.dart';
import 'package:posventa/domain/repositories/department_repository.dart';
import 'package:posventa/domain/use_cases/create_department.dart';
import 'package:posventa/domain/use_cases/delete_department.dart';
import 'package:posventa/domain/use_cases/get_all_departments.dart';
import 'package:posventa/domain/use_cases/update_department.dart';

// Provider for DatabaseHelper
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

// Provider for the Repository
final departmentRepositoryProvider = Provider<DepartmentRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return DepartmentRepositoryImpl(dbHelper);
});

// Use Case Providers
final getAllDepartmentsUseCaseProvider = Provider(
  (ref) => GetAllDepartments(ref.watch(departmentRepositoryProvider)),
);
final createDepartmentUseCaseProvider = Provider(
  (ref) => CreateDepartment(ref.watch(departmentRepositoryProvider)),
);
final updateDepartmentUseCaseProvider = Provider(
  (ref) => UpdateDepartment(ref.watch(departmentRepositoryProvider)),
);
final deleteDepartmentUseCaseProvider = Provider(
  (ref) => DeleteDepartment(ref.watch(departmentRepositoryProvider)),
);

// StateNotifier for the department list
class DepartmentListNotifier
    extends StateNotifier<AsyncValue<List<Department>>> {
  final GetAllDepartments _getAllDepartments;
  final CreateDepartment _createDepartment;
  final UpdateDepartment _updateDepartment;
  final DeleteDepartment _deleteDepartment;

  DepartmentListNotifier(
    this._getAllDepartments,
    this._createDepartment,
    this._updateDepartment,
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
    } finally {
      await loadDepartments();
    }
  }

  Future<void> updateDepartment(Department department) async {
    final previousState = state;
    // Optimistic update
    if (state is AsyncData<List<Department>>) {
      final currentDepartments = state.value!;
      final updatedList = [
        for (final dep in currentDepartments)
          if (dep.id == department.id) department else dep,
      ];
      state = AsyncValue.data(updatedList);
    }

    try {
      await _updateDepartment(department);
    } catch (e) {
      // If the update fails, revert the state
      state = previousState;
    }
  }

  Future<void> deleteDepartment(int id) async {
    try {
      await _deleteDepartment(id);
    } finally {
      await loadDepartments();
    }
  }
}

// The final provider for the notifier
final departmentListProvider =
    StateNotifierProvider<DepartmentListNotifier, AsyncValue<List<Department>>>(
      (ref) {
        return DepartmentListNotifier(
          ref.watch(getAllDepartmentsUseCaseProvider),
          ref.watch(createDepartmentUseCaseProvider),
          ref.watch(updateDepartmentUseCaseProvider),
          ref.watch(deleteDepartmentUseCaseProvider),
        );
      },
    );
