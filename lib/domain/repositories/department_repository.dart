import 'package:posventa/domain/entities/department.dart';

abstract class DepartmentRepository {
  Future<void> createDepartment(Department department);
  Future<Department?> getDepartmentById(int id);
  Future<List<Department>> getAllDepartments();
  Future<void> updateDepartment(Department department);
  Future<void> deleteDepartment(int id);
}
