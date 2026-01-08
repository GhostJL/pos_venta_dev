import 'package:drift/drift.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart'
    as drift_db;
import 'package:posventa/data/models/supplier_model.dart';
import 'package:posventa/domain/entities/supplier.dart';
import 'package:posventa/domain/repositories/supplier_repository.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  final drift_db.AppDatabase db;

  SupplierRepositoryImpl(this.db);

  @override
  Future<List<Supplier>> getAllSuppliers({
    String? query,
    int? limit,
    int? offset,
    bool showInactive = false,
  }) async {
    final q = db.select(db.suppliers);

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
            t.name.like(search) |
            t.code.like(search) |
            t.contactPerson.like(search) |
            t.email.like(search),
      );
    }

    q.orderBy([(t) => OrderingTerm.asc(t.name)]);

    if (limit != null) {
      q.limit(limit, offset: offset);
    }

    final rows = await q.get();
    return rows
        .map(
          (row) => SupplierModel(
            id: row.id,
            name: row.name,
            code: row.code,
            contactPerson: row.contactPerson,
            phone: row.phone,
            email: row.email,
            address: row.address,
            taxId: row.taxId,
            creditDays: row.creditDays,
            isActive: row.isActive,
          ),
        )
        .toList();
  }

  @override
  Future<int> countSuppliers({String? query, bool showInactive = false}) async {
    final q = db.selectOnly(db.suppliers)
      ..addColumns([db.suppliers.id.count()]);

    if (!showInactive) {
      q.where(db.suppliers.isActive.equals(true));
    } else {
      if (showInactive) {
        q.where(db.suppliers.isActive.equals(false));
      } else {
        q.where(db.suppliers.isActive.equals(true));
      }
    }

    if (query != null && query.isNotEmpty) {
      final search = '%$query%';
      q.where(
        db.suppliers.name.like(search) |
            db.suppliers.code.like(search) |
            db.suppliers.contactPerson.like(search) |
            db.suppliers.email.like(search),
      );
    }

    final result = await q.getSingle();
    return result.read(db.suppliers.id.count()) ?? 0;
  }

  @override
  Future<Supplier> createSupplier(Supplier supplier) async {
    final id = await db
        .into(db.suppliers)
        .insert(
          drift_db.SuppliersCompanion.insert(
            name: supplier.name,
            code: supplier.code,
            contactPerson: Value(supplier.contactPerson),
            phone: Value(supplier.phone),
            email: Value(supplier.email),
            address: Value(supplier.address),
            taxId: Value(supplier.taxId),
            creditDays: Value(supplier.creditDays),
            isActive: Value(supplier.isActive),
          ),
          mode: InsertMode.replace,
        );
    final created = await _getSupplierById(id);
    return created;
  }

  @override
  Future<Supplier> updateSupplier(Supplier supplier) async {
    await (db.update(
      db.suppliers,
    )..where((t) => t.id.equals(supplier.id!))).write(
      drift_db.SuppliersCompanion(
        name: Value(supplier.name),
        code: Value(supplier.code),
        contactPerson: Value(supplier.contactPerson),
        phone: Value(supplier.phone),
        email: Value(supplier.email),
        address: Value(supplier.address),
        taxId: Value(supplier.taxId),
        creditDays: Value(supplier.creditDays),
        isActive: Value(supplier.isActive),
      ),
    );
    return await _getSupplierById(supplier.id!);
  }

  @override
  Future<void> deleteSupplier(int supplierId) async {
    await (db.delete(db.suppliers)..where((t) => t.id.equals(supplierId))).go();
  }

  Future<Supplier> _getSupplierById(int id) async {
    final row = await (db.select(
      db.suppliers,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row != null) {
      return SupplierModel(
        id: row.id,
        name: row.name,
        code: row.code,
        contactPerson: row.contactPerson,
        phone: row.phone,
        email: row.email,
        address: row.address,
        taxId: row.taxId,
        creditDays: row.creditDays,
        isActive: row.isActive,
      );
    } else {
      throw Exception('ID $id no encontrado');
    }
  }

  @override
  Future<bool> isCodeUnique(String code, {int? excludeId}) async {
    final q = db.select(db.suppliers)..where((t) => t.code.equals(code));
    if (excludeId != null) {
      q.where((t) => t.id.equals(excludeId).not());
    }
    final res = await q.get();
    return res.isEmpty;
  }
}
