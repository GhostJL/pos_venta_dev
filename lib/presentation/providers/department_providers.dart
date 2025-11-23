import 'package:posventa/domain/entities/department.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posventa/domain/repositories/department_repository.dart';
import 'package:posventa/data/repositories/department_repository_impl.dart';
import 'package:posventa/domain/use_cases/department/create_department.dart';
import 'package:posventa/domain/use_cases/department/delete_department.dart';
import 'package:posventa/domain/use_cases/department/get_all_departments.dart';
import 'package:posventa/domain/use_cases/department/update_department.dart';

part 'department_providers.g.dart';

@riverpod
DepartmentRepository departmentRepository(ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return DepartmentRepositoryImpl(dbHelper);
}

@riverpod
GetAllDepartments getAllDepartmentsUseCase(ref) {
  return GetAllDepartments(ref.watch(departmentRepositoryProvider));
}

@riverpod
CreateDepartment createDepartmentUseCase(ref) {
  return CreateDepartment(ref.watch(departmentRepositoryProvider));
}

@riverpod
UpdateDepartment updateDepartmentUseCase(ref) {
  return UpdateDepartment(ref.watch(departmentRepositoryProvider));
}

@riverpod
DeleteDepartment deleteDepartmentUseCase(ref) {
  return DeleteDepartment(ref.watch(departmentRepositoryProvider));
}

@riverpod
class DepartmentList extends _$DepartmentList {
  @override
  Future<List<Department>> build() async {
    final getAllDepartments = ref.watch(getAllDepartmentsUseCaseProvider);
    return getAllDepartments();
  }

  Future<void> addDepartment(Department department) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(createDepartmentUseCaseProvider).call(department);
      return ref.read(getAllDepartmentsUseCaseProvider).call();
    });
  }

  Future<void> updateDepartment(Department department) async {
    // Optimistic update logic could be added here if desired, but for simplicity and consistency we'll use the standard pattern
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(updateDepartmentUseCaseProvider).call(department);
      return ref.read(getAllDepartmentsUseCaseProvider).call();
    });
  }

  Future<void> deleteDepartment(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(deleteDepartmentUseCaseProvider).call(id);
      return ref.read(getAllDepartmentsUseCaseProvider).call();
    });
  }
}
