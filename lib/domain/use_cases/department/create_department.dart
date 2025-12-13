import 'package:posventa/domain/entities/department.dart';
import 'package:posventa/domain/repositories/department_repository.dart';

class CreateDepartment {
  final DepartmentRepository repository;

  CreateDepartment(this.repository);

  Future<int> call(Department department) async {
    return await repository.createDepartment(department);
  }
}
