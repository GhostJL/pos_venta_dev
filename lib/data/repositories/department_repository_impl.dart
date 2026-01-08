import 'package:drift/drift.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart'
    as drift_db;
import 'package:posventa/data/models/department_model.dart';
import 'package:posventa/domain/entities/department.dart';
import 'package:posventa/domain/repositories/department_repository.dart';

class DepartmentRepositoryImpl implements DepartmentRepository {
  final drift_db.AppDatabase db;

  DepartmentRepositoryImpl(this.db);

  @override
  Future<int> createDepartment(Department department) async {
    return await db
        .into(db.departments)
        .insert(
          drift_db.DepartmentsCompanion.insert(
            name: department.name,
            code: department.code,
            description: Value(department.description),
            displayOrder: Value(department.displayOrder),
            isActive: Value(department.isActive),
          ),
        );
  }

  @override
  Future<Department?> getDepartmentById(int id) async {
    final row = await (db.select(
      db.departments,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row != null) {
      return DepartmentModel(
        id: row.id,
        name: row.name,
        code: row.code,
        description: row.description,
        displayOrder: row.displayOrder,
        isActive: row.isActive,
      );
    }
    return null;
  }

  @override
  Future<List<Department>> getAllDepartments() async {
    final rows = await (db.select(
      db.departments,
    )..orderBy([(t) => OrderingTerm.asc(t.displayOrder)])).get();

    return rows
        .map(
          (row) => DepartmentModel(
            id: row.id,
            name: row.name,
            code: row.code,
            description: row.description,
            displayOrder: row.displayOrder,
            isActive: row.isActive,
          ),
        )
        .toList();
  }

  @override
  Future<void> updateDepartment(Department department) async {
    await (db.update(
      db.departments,
    )..where((t) => t.id.equals(department.id!))).write(
      drift_db.DepartmentsCompanion(
        name: Value(department.name),
        code: Value(department.code),
        description: Value(department.description),
        displayOrder: Value(department.displayOrder),
        isActive: Value(department.isActive),
      ),
    );
  }

  @override
  Future<void> deleteDepartment(int id) async {
    await (db.delete(db.departments)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<bool> isCodeUnique(String code, {int? excludeId}) async {
    final q = db.select(db.departments)..where((t) => t.code.equals(code));
    if (excludeId != null) {
      q.where((t) => t.id.equals(excludeId).not());
    }
    final res = await q.get();
    return res.isEmpty;
  }
}
