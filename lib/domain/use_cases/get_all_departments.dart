
import 'package:myapp/domain/entities/department.dart';
import 'package:myapp/domain/repositories/department_repository.dart';

class GetAllDepartments {
  final DepartmentRepository repository;

  GetAllDepartments(this.repository);

  Future<List<Department>> call() async {
    return await repository.getAllDepartments();
  }
}
