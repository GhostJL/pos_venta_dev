import 'package:drift/drift.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart'
    as drift_db;
import 'package:posventa/data/models/customer_model.dart';
import 'package:posventa/domain/entities/customer.dart';
import 'package:posventa/domain/repositories/customer_repository.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final drift_db.AppDatabase db;

  CustomerRepositoryImpl(this.db);

  @override
  Future<List<Customer>> getCustomers({
    String? query,
    int? limit,
    int? offset,
    bool showInactive = false,
  }) async {
    final q = db.select(db.customers);

    if (!showInactive) {
      q.where((t) => t.isActive.equals(true));
    } else {
      if (showInactive) {
        q.where((t) => t.isActive.equals(false));
      } else {
        q.where((t) => t.isActive.equals(true));
      }
    }

    if (query != null && query.isNotEmpty) {
      final search = '%$query%';
      q.where(
        (t) =>
            t.firstName.like(search) |
            t.lastName.like(search) |
            t.businessName.like(search) |
            t.code.like(search),
      );
    }

    q.orderBy([(t) => OrderingTerm.asc(t.lastName)]);

    if (limit != null) {
      q.limit(limit, offset: offset);
    }

    final rows = await q.get();
    return rows
        .map(
          (row) => CustomerModel(
            id: row.id,
            code: row.code,
            firstName: row.firstName,
            lastName: row.lastName,
            businessName: row.businessName,
            taxId: row.taxId,
            phone: row.phone,
            email: row.email,
            address: row.address,
            isActive: row.isActive,
            createdAt: row.createdAt,
            updatedAt: row.updatedAt,
          ),
        )
        .toList();
  }

  @override
  Future<int> countCustomers({String? query, bool showInactive = false}) async {
    final q = db.selectOnly(db.customers)
      ..addColumns([db.customers.id.count()]);

    if (!showInactive) {
      q.where(db.customers.isActive.equals(true));
    } else {
      if (showInactive) {
        q.where(db.customers.isActive.equals(false));
      } else {
        q.where(db.customers.isActive.equals(true));
      }
    }

    if (query != null && query.isNotEmpty) {
      final search = '%$query%';
      q.where(
        db.customers.firstName.like(search) |
            db.customers.lastName.like(search) |
            db.customers.businessName.like(search) |
            db.customers.code.like(search),
      );
    }

    final result = await q.getSingle();
    return result.read(db.customers.id.count()) ?? 0;
  }

  @override
  Future<Customer?> getCustomerById(int id) async {
    final row = await (db.select(
      db.customers,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row != null) {
      return CustomerModel(
        id: row.id,
        code: row.code,
        firstName: row.firstName,
        lastName: row.lastName,
        businessName: row.businessName,
        taxId: row.taxId,
        phone: row.phone,
        email: row.email,
        address: row.address,
        isActive: row.isActive,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );
    }
    return null;
  }

  @override
  Future<Customer?> getCustomerByCode(String code) async {
    final row = await (db.select(
      db.customers,
    )..where((t) => t.code.equals(code))).getSingleOrNull();
    if (row != null) {
      return CustomerModel(
        id: row.id,
        code: row.code,
        firstName: row.firstName,
        lastName: row.lastName,
        businessName: row.businessName,
        taxId: row.taxId,
        phone: row.phone,
        email: row.email,
        address: row.address,
        isActive: row.isActive,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );
    }
    return null;
  }

  @override
  Future<int> createCustomer(Customer customer) async {
    return await db
        .into(db.customers)
        .insert(
          drift_db.CustomersCompanion.insert(
            code: customer.code,
            firstName: customer.firstName,
            lastName: customer.lastName,
            businessName: Value(customer.businessName),
            taxId: Value(customer.taxId),
            phone: Value(customer.phone),
            email: Value(customer.email),
            address: Value(customer.address),
            isActive: Value(customer.isActive),
            createdAt: Value(customer.createdAt),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  @override
  Future<int> updateCustomer(Customer customer) async {
    await (db.update(
      db.customers,
    )..where((t) => t.id.equals(customer.id!))).write(
      drift_db.CustomersCompanion(
        code: Value(customer.code),
        firstName: Value(customer.firstName),
        lastName: Value(customer.lastName),
        businessName: Value(customer.businessName),
        taxId: Value(customer.taxId),
        phone: Value(customer.phone),
        email: Value(customer.email),
        address: Value(customer.address),
        isActive: Value(customer.isActive),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return customer.id!;
  }

  @override
  Future<int> deleteCustomer(int id) async {
    final customer = await getCustomerById(id);
    if (customer != null) {
      // Soft delete
      await (db.update(db.customers)..where((t) => t.id.equals(id))).write(
        drift_db.CustomersCompanion(
          isActive: Value(false),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return 1;
    }
    return 0;
  }

  @override
  Future<List<Customer>> searchCustomers(String query) async {
    return getCustomers(query: query, limit: 50);
  }

  @override
  Future<String> generateNextCustomerCode() async {
    final query = db.selectOnly(db.customers)
      ..addColumns([db.customers.id.max()]);
    final result = await query.getSingle();
    final maxId = result.read(db.customers.id.max());

    int nextId = (maxId ?? 0) + 1;
    String code = 'C$nextId';

    while (true) {
      final exists = await (db.select(
        db.customers,
      )..where((t) => t.code.equals(code))).getSingleOrNull();
      if (exists == null) break;
      nextId++;
      code = 'C$nextId';
    }
    return code;
  }

  @override
  Future<bool> isCodeUnique(String code, {int? excludeId}) async {
    final q = db.select(db.customers)..where((t) => t.code.equals(code));
    if (excludeId != null) {
      q.where((t) => t.id.equals(excludeId).not());
    }
    final res = await q.get();
    return res.isEmpty;
  }
}
