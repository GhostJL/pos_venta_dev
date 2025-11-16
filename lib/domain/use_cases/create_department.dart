
import 'package:myapp/domain/entities/department.dart';
import 'package:myapp/domain/repositories/department_repository.dart';

class CreateDepartment {
  final DepartmentRepository repository;

  CreateDepartment(this.repository);

  Future<void> call(Department department) async {
    return await repository.createDepartment(department);
  }
}
