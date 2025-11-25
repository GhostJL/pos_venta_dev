import 'package:posventa/core/utils/database_validators.dart';
import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/data/models/department_model.dart';
import 'package:posventa/domain/entities/department.dart';
import 'package:posventa/domain/repositories/department_repository.dart';

class DepartmentRepositoryImpl implements DepartmentRepository {
  final DatabaseHelper databaseHelper;

  DepartmentRepositoryImpl(this.databaseHelper);

  @override
  Future<void> createDepartment(Department department) async {
    final db = await databaseHelper.database;
    final departmentModel = DepartmentModel(
      name: department.name,
      code: department.code,
      description: department.description,
      displayOrder: department.displayOrder,
      isActive: department.isActive,
    );
    await db.insert('departments', departmentModel.toMap());
  }

  @override
  Future<Department?> getDepartmentById(int id) async {
    final db = await databaseHelper.database;
    final maps = await db.query(
      'departments',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return DepartmentModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<List<Department>> getAllDepartments() async {
    final db = await databaseHelper.database;
    final maps = await db.query('departments', orderBy: 'display_order ASC');
    return maps.map((map) => DepartmentModel.fromMap(map)).toList();
  }

  @override
  Future<void> updateDepartment(Department department) async {
    final db = await databaseHelper.database;
    final departmentModel = DepartmentModel(
      id: department.id,
      name: department.name,
      code: department.code,
      description: department.description,
      displayOrder: department.displayOrder,
      isActive: department.isActive,
    );
    await db.update(
      'departments',
      departmentModel.toMap(),
      where: 'id = ?',
      whereArgs: [department.id],
    );
  }

  @override
  Future<void> deleteDepartment(int id) async {
    final db = await databaseHelper.database;
    await db.delete('departments', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<bool> isCodeUnique(String code, {int? excludeId}) async {
    final db = await databaseHelper.database;
    return DatabaseValidators.isFieldUnique(
      db: db,
      tableName: DatabaseHelper.tableDepartments,
      fieldName: 'code',
      value: code,
      excludeId: excludeId,
    );
  }
}
