import 'package:posventa/core/utils/database_validators.dart';
import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/data/models/customer_model.dart';
import 'package:posventa/domain/entities/customer.dart';
import 'package:posventa/domain/repositories/customer_repository.dart';
import 'package:sqflite/sqflite.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final DatabaseHelper _databaseHelper;

  CustomerRepositoryImpl(this._databaseHelper);

  @override
  Future<List<Customer>> getCustomers({
    String? query,
    int? limit,
    int? offset,
    bool showInactive = false,
  }) async {
    final db = await _databaseHelper.database;
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
        '(first_name LIKE ? OR last_name LIKE ? OR business_name LIKE ? OR code LIKE ?)',
      );
      final q = '%$query%';
      whereArgs.addAll([q, q, q, q]);
    }

    final whereString = whereClauses.isNotEmpty
        ? whereClauses.join(' AND ')
        : null;

    final result = await db.query(
      DatabaseHelper.tableCustomers,
      where: whereString,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'last_name ASC',
      limit: limit,
      offset: offset,
    );
    return result.map((e) => CustomerModel.fromJson(e)).toList();
  }

  @override
  Future<int> countCustomers({String? query, bool showInactive = false}) async {
    final db = await _databaseHelper.database;
    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (showInactive) {
      whereClauses.add('is_active = 0');
    } else {
      whereClauses.add('is_active = 1');
    }

    if (query != null && query.isNotEmpty) {
      whereClauses.add(
        '(first_name LIKE ? OR last_name LIKE ? OR business_name LIKE ? OR code LIKE ?)',
      );
      final q = '%$query%';
      whereArgs.addAll([q, q, q, q]);
    }

    final whereString = whereClauses.isNotEmpty
        ? 'WHERE ${whereClauses.join(' AND ')}'
        : '';

    final sql =
        'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableCustomers} $whereString';
    final result = await db.rawQuery(sql, whereArgs);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<Customer?> getCustomerById(int id) async {
    final result = await _databaseHelper.queryById(
      DatabaseHelper.tableCustomers,
      id,
    );
    if (result != null) {
      return CustomerModel.fromJson(result);
    }
    return null;
  }

  @override
  Future<Customer?> getCustomerByCode(String code) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      DatabaseHelper.tableCustomers,
      where: 'code = ?',
      whereArgs: [code],
    );
    if (result.isNotEmpty) {
      return CustomerModel.fromJson(result.first);
    }
    return null;
  }

  @override
  Future<int> createCustomer(Customer customer) async {
    final customerModel = CustomerModel.fromEntity(customer);
    return await _databaseHelper.insert(
      DatabaseHelper.tableCustomers,
      customerModel.toMap(),
    );
  }

  @override
  Future<int> updateCustomer(Customer customer) async {
    final customerModel = CustomerModel.fromEntity(customer);
    return await _databaseHelper.update(
      DatabaseHelper.tableCustomers,
      customerModel.toMap(),
    );
  }

  @override
  Future<int> deleteCustomer(int id) async {
    final customer = await getCustomerById(id);
    if (customer != null) {
      final updatedCustomer = Customer(
        id: customer.id,
        code: customer.code,
        firstName: customer.firstName,
        lastName: customer.lastName,
        phone: customer.phone,
        email: customer.email,
        address: customer.address,
        taxId: customer.taxId,
        businessName: customer.businessName,
        isActive: false,
        createdAt: customer.createdAt,
        updatedAt: DateTime.now(),
      );
      return await updateCustomer(updatedCustomer);
    }
    return 0;
  }

  @override
  Future<List<Customer>> searchCustomers(String query) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      DatabaseHelper.tableCustomers,
      where:
          '(first_name LIKE ? OR last_name LIKE ? OR business_name LIKE ? OR code LIKE ?) AND is_active = ?',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%', 1],
    );
    return result.map((e) => CustomerModel.fromJson(e)).toList();
  }

  @override
  Future<String> generateNextCustomerCode() async {
    final db = await _databaseHelper.database;

    // Get the last ID to guess the next one
    final result = await db.rawQuery(
      'SELECT MAX(id) as max_id FROM ${DatabaseHelper.tableCustomers}',
    );
    int nextId = 1;
    if (result.isNotEmpty && result.first['max_id'] != null) {
      nextId = (result.first['max_id'] as int) + 1;
    }

    // Ensure uniqueness
    String code = 'C$nextId';
    while (true) {
      final exists = await db.query(
        DatabaseHelper.tableCustomers,
        where: 'code = ?',
        whereArgs: [code],
      );
      if (exists.isEmpty) {
        break;
      }
      nextId++;
      code = 'C$nextId';
    }

    return code;
  }

  @override
  Future<bool> isCodeUnique(String code, {int? excludeId}) async {
    final db = await _databaseHelper.database;
    return DatabaseValidators.isFieldUnique(
      db: db,
      tableName: DatabaseHelper.tableCustomers,
      fieldName: 'code',
      value: code,
      excludeId: excludeId,
    );
  }
}
