import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:myapp/data/repositories/department_repository_impl.dart';
import 'package:myapp/domain/entities/department.dart';
import 'package:myapp/domain/repositories/department_repository.dart';
import 'package:myapp/domain/use_cases/create_department.dart';
import 'package:myapp/domain/use_cases/get_all_departments.dart';

// 1. Provider for the Repository
final departmentRepositoryProvider = Provider<DepartmentRepository>((ref) {
  return DepartmentRepositoryImpl();
});

// 2. Provider for the GetAllDepartments Use Case
final getAllDepartmentsUseCaseProvider = Provider<GetAllDepartments>((ref) {
  final repository = ref.watch(departmentRepositoryProvider);
  return GetAllDepartments(repository);
});

// 3. Provider for the CreateDepartment Use Case
final createDepartmentUseCaseProvider = Provider<CreateDepartment>((ref) {
  final repository = ref.watch(departmentRepositoryProvider);
  return CreateDepartment(repository);
});

// 4. StateNotifierProvider for the list of departments
class DepartmentListNotifier
    extends StateNotifier<AsyncValue<List<Department>>> {
  final GetAllDepartments _getAllDepartments;
  final CreateDepartment _createDepartment;

  DepartmentListNotifier(this._getAllDepartments, this._createDepartment)
    : super(const AsyncValue.loading()) {
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
      await loadDepartments(); // Refresh the list after adding
    } catch (e) {
      await loadDepartments();
    }
  }
}

final departmentListProvider =
    StateNotifierProvider<DepartmentListNotifier, AsyncValue<List<Department>>>(
      (ref) {
        final getAllDepartments = ref.watch(getAllDepartmentsUseCaseProvider);
        final createDepartment = ref.watch(createDepartmentUseCaseProvider);
        return DepartmentListNotifier(getAllDepartments, createDepartment);
      },
    );
