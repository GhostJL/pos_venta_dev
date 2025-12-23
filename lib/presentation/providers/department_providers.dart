import 'package:posventa/domain/entities/department.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'department_providers.g.dart';

// Providers moved to product_di.dart

@Riverpod(keepAlive: true)
class DepartmentList extends _$DepartmentList {
  @override
  Future<List<Department>> build() async {
    final getAllDepartments = ref.watch(getAllDepartmentsUseCaseProvider);
    return getAllDepartments();
  }

  Future<int?> addDepartment(Department department) async {
    state = const AsyncValue.loading();
    int? newId;
    state = await AsyncValue.guard(() async {
      newId = await ref.read(createDepartmentUseCaseProvider).call(department);
      return ref.read(getAllDepartmentsUseCaseProvider).call();
    });
    return newId;
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
