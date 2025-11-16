import 'package:myapp/domain/repositories/department_repository.dart';

class DeleteDepartment {
  final DepartmentRepository repository;

  DeleteDepartment(this.repository);

  Future<void> call(int id) {
    return repository.deleteDepartment(id);
  }
}
