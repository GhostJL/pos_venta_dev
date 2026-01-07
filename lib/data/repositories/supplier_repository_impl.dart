import 'package:posventa/core/utils/database_validators.dart';
import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/data/models/supplier_model.dart';
import 'package:posventa/domain/entities/supplier.dart';
import 'package:posventa/domain/repositories/supplier_repository.dart';
import 'package:sqflite/sqflite.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  final DatabaseHelper _dbHelper;

  SupplierRepositoryImpl(this._dbHelper);

  @override
  Future<List<Supplier>> getAllSuppliers({
    String? query,
    int? limit,
    int? offset,
    bool showInactive = false,
  }) async {
    final db = await _dbHelper.database;
    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    // Filter: Active Status
    if (showInactive) {
      whereClauses.add('is_active = 0');
    } else {
      whereClauses.add('is_active = 1');
    }

    if (query != null && query.isNotEmpty) {
      whereClauses.add(
        '(name LIKE ? OR code LIKE ? OR contact_person LIKE ? OR email LIKE ?)',
      );
      final q = '%$query%';
      whereArgs.addAll([q, q, q, q]);
    }

    final whereString = whereClauses.isNotEmpty
        ? whereClauses.join(' AND ')
        : null;

    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableSuppliers,
      where: whereString,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'name ASC',
      limit: limit,
      offset: offset,
    );
    return List.generate(maps.length, (i) => SupplierModel.fromMap(maps[i]));
  }

  @override
  Future<int> countSuppliers({String? query, bool showInactive = false}) async {
    final db = await _dbHelper.database;
    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (showInactive) {
      whereClauses.add('is_active = 0');
    } else {
      whereClauses.add('is_active = 1');
    }

    if (query != null && query.isNotEmpty) {
      whereClauses.add(
        '(name LIKE ? OR code LIKE ? OR contact_person LIKE ? OR email LIKE ?)',
      );
      final q = '%$query%';
      whereArgs.addAll([q, q, q, q]);
    }

    final whereString = whereClauses.isNotEmpty
        ? 'WHERE ${whereClauses.join(' AND ')}'
        : '';

    final sql =
        'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableSuppliers} $whereString';
    final result = await db.rawQuery(sql, whereArgs);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<Supplier> createSupplier(Supplier supplier) async {
    final db = await _dbHelper.database;
    final model = SupplierModel(
      name: supplier.name,
      code: supplier.code,
      contactPerson: supplier.contactPerson,
      phone: supplier.phone,
      email: supplier.email,
      address: supplier.address,
      taxId: supplier.taxId,
      creditDays: supplier.creditDays,
      isActive: supplier.isActive,
    );
    final id = await db.insert(
      DatabaseHelper.tableSuppliers,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    final createdSupplier = await _getSupplierById(id);
    return createdSupplier;
  }

  @override
  Future<Supplier> updateSupplier(Supplier supplier) async {
    final db = await _dbHelper.database;
    final model = SupplierModel(
      id: supplier.id,
      name: supplier.name,
      code: supplier.code,
      contactPerson: supplier.contactPerson,
      phone: supplier.phone,
      email: supplier.email,
      address: supplier.address,
      taxId: supplier.taxId,
      creditDays: supplier.creditDays,
      isActive: supplier.isActive,
    );
    await db.update(
      DatabaseHelper.tableSuppliers,
      model.toMap(),
      where: 'id = ?',
      whereArgs: [supplier.id],
    );
    final updatedSupplier = await _getSupplierById(supplier.id!);
    return updatedSupplier;
  }

  @override
  Future<void> deleteSupplier(int supplierId) async {
    final db = await _dbHelper.database;
    await db.delete(
      DatabaseHelper.tableSuppliers,
      where: 'id = ?',
      whereArgs: [supplierId],
    );
  }

  Future<Supplier> _getSupplierById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableSuppliers,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return SupplierModel.fromMap(maps.first);
    } else {
      throw Exception('ID $id no encontrado');
    }
  }

  @override
  Future<bool> isCodeUnique(String code, {int? excludeId}) async {
    final db = await _dbHelper.database;
    return DatabaseValidators.isFieldUnique(
      db: db,
      tableName: DatabaseHelper.tableSuppliers,
      fieldName: 'code',
      value: code,
      excludeId: excludeId,
    );
  }
}
