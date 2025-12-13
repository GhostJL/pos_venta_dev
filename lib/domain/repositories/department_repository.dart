import 'package:posventa/domain/entities/department.dart';

abstract class DepartmentRepository {
  Future<int> createDepartment(Department department);
  Future<Department?> getDepartmentById(int id);
  Future<List<Department>> getAllDepartments();
  Future<void> updateDepartment(Department department);
  Future<void> deleteDepartment(int id);
  Future<bool> isCodeUnique(String code, {int? excludeId});
}
