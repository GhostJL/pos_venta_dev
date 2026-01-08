import 'package:drift/drift.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart'
    as drift_db;
import 'package:posventa/domain/entities/store.dart' as domain;
import 'package:posventa/domain/repositories/i_store_repository.dart';

class StoreRepositoryImpl implements IStoreRepository {
  final drift_db.AppDatabase db;

  StoreRepositoryImpl({required this.db});

  @override
  Future<domain.Store?> getStore() async {
    final query = db.select(db.stores)..limit(1);
    final row = await query.getSingleOrNull();

    if (row == null) return null;

    return domain.Store(
      id: row.id,
      name: row.name,
      businessName: row.businessName,
      taxId: row.taxId,
      address: row.address,
      phone: row.phone,
      email: row.email,
      website: row.website,
      logoPath: row.logoPath,
      receiptFooter: row.receiptFooter,
      currency: row.currency,
      timezone: row.timezone,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  @override
  Future<void> updateStore(domain.Store store) async {
    if (store.id == null) {
      // Create if doesn't exist
      await db
          .into(db.stores)
          .insert(
            drift_db.StoresCompanion.insert(
              name: store.name,
              businessName: Value(store.businessName),
              taxId: Value(store.taxId),
              address: Value(store.address),
              phone: Value(store.phone),
              email: Value(store.email),
              website: Value(store.website),
              logoPath: Value(store.logoPath),
              receiptFooter: Value(store.receiptFooter),
              currency: Value(store.currency ?? 'MXN'),
              timezone: Value(store.timezone ?? 'America/Mexico_City'),
              createdAt: Value(store.createdAt),
              updatedAt: Value(store.updatedAt),
            ),
          );
    } else {
      await (db.update(db.stores)..where((s) => s.id.equals(store.id!))).write(
        drift_db.StoresCompanion(
          name: Value(store.name),
          businessName: Value(store.businessName),
          taxId: Value(store.taxId),
          address: Value(store.address),
          phone: Value(store.phone),
          email: Value(store.email),
          website: Value(store.website),
          logoPath: Value(store.logoPath),
          receiptFooter: Value(store.receiptFooter),
          currency: Value(store.currency ?? 'MXN'),
          timezone: Value(store.timezone ?? 'America/Mexico_City'),
          updatedAt: Value(store.updatedAt),
        ),
      );
    }
  }
}
