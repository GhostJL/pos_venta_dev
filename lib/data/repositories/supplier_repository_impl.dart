
import 'package:myapp/data/datasources/database_helper.dart';
import 'package:myapp/data/models/supplier_model.dart';
import 'package:myapp/domain/entities/supplier.dart';
import 'package:myapp/domain/repositories/supplier_repository.dart';
import 'package:sqflite/sqflite.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  final DatabaseHelper _dbHelper;

  SupplierRepositoryImpl(this._dbHelper);

  @override
  Future<List<Supplier>> getAllSuppliers() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(DatabaseHelper.tableSuppliers);
    return List.generate(maps.length, (i) => SupplierModel.fromMap(maps[i]));
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
    final id = await db.insert(DatabaseHelper.tableSuppliers, model.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
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
    await db.update(DatabaseHelper.tableSuppliers, model.toMap(), where: 'id = ?', whereArgs: [supplier.id]);
    final updatedSupplier = await _getSupplierById(supplier.id!);
    return updatedSupplier;
  }

  @override
  Future<void> deleteSupplier(int supplierId) async {
    final db = await _dbHelper.database;
    await db.delete(DatabaseHelper.tableSuppliers, where: 'id = ?', whereArgs: [supplierId]);
  }

  Future<Supplier> _getSupplierById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(DatabaseHelper.tableSuppliers, where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return SupplierModel.fromMap(maps.first);
    } else {
      throw Exception('ID $id no encontrado');
    }
  }
}
