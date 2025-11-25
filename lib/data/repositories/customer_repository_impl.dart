import 'package:posventa/core/utils/database_validators.dart';
import 'package:posventa/data/datasources/database_helper.dart';
import 'package:posventa/data/models/customer_model.dart';
import 'package:posventa/domain/entities/customer.dart';
import 'package:posventa/domain/repositories/customer_repository.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final DatabaseHelper _databaseHelper;

  CustomerRepositoryImpl(this._databaseHelper);

  @override
  Future<List<Customer>> getCustomers() async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      DatabaseHelper.tableCustomers,
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'last_name ASC',
    );
    return result.map((e) => CustomerModel.fromJson(e)).toList();
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
