import 'package:posventa/domain/entities/department.dart';
import 'package:posventa/domain/repositories/department_repository.dart';

class UpdateDepartment {
  final DepartmentRepository repository;

  UpdateDepartment(this.repository);

  Future<void> call(Department department) async {
    // Here you could add business logic, for example:
    // - Check if the department code is unique before updating.
    // - Validate that the name is not empty.
    if (department.name.isEmpty) {
      throw ArgumentError('Department name cannot be empty.');
    }
    return repository.updateDepartment(department);
  }
}
