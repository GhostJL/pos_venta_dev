import 'package:drift/drift.dart';
import 'package:posventa/data/datasources/local/database/app_database.dart'
    as drift_db;
import 'package:posventa/data/models/customer_model.dart';
import 'package:posventa/domain/entities/customer.dart';
import 'package:posventa/domain/entities/customer_payment.dart';
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
            creditLimit: row.creditLimitCents != null
                ? row.creditLimitCents! / 100.0
                : null,
            creditUsed: row.creditUsedCents / 100.0,
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
        creditLimit: row.creditLimitCents != null
            ? row.creditLimitCents! / 100.0
            : null,
        creditUsed: row.creditUsedCents / 100.0,
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
        creditLimit: row.creditLimitCents != null
            ? row.creditLimitCents! / 100.0
            : null,
        creditUsed: row.creditUsedCents / 100.0,
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
            creditLimitCents: Value(
              customer.creditLimit != null
                  ? (customer.creditLimit! * 100).round()
                  : null,
            ),
            creditUsedCents: Value((customer.creditUsed * 100).round()),
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
        creditLimitCents: Value(
          customer.creditLimit != null
              ? (customer.creditLimit! * 100).round()
              : null,
        ),
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

  @override
  Future<void> updateCustomerCredit(
    int customerId,
    double amount, {
    bool isIncrement = true,
  }) async {
    final amountCents = (amount * 100).round();

    // Get current usage
    final customer = await (db.select(
      db.customers,
    )..where((t) => t.id.equals(customerId))).getSingle();
    final currentUsed = customer.creditUsedCents;

    int newUsed;
    if (isIncrement) {
      newUsed = currentUsed + amountCents;
    } else {
      newUsed = currentUsed - amountCents;
    }

    await (db.update(
      db.customers,
    )..where((t) => t.id.equals(customerId))).write(
      drift_db.CustomersCompanion(
        creditUsedCents: Value(newUsed),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<double> getCustomerBalance(int customerId) async {
    final customer = await (db.select(
      db.customers,
    )..where((t) => t.id.equals(customerId))).getSingle();
    return customer.creditUsedCents / 100.0;
  }

  @override
  Future<int> registerPayment(
    CustomerPayment payment, {
    int? cashSessionId,
  }) async {
    return await db.transaction(() async {
      // 1. Insert payment record
      final id = await db
          .into(db.customerPayments)
          .insert(
            drift_db.CustomerPaymentsCompanion.insert(
              customerId: payment.customerId,
              amountCents: (payment.amount * 100).round(),
              paymentMethod: payment.paymentMethod,
              reference: Value(payment.reference),
              processedBy: payment.processedBy,
              notes: Value(payment.notes),
              status: const Value('active'),
              type: const Value('payment'),
              saleId: Value(payment.saleId),
            ),
          );

      // 2. Update customer credit usage (decrease debt)
      await updateCustomerCredit(
        payment.customerId,
        payment.amount,
        isIncrement: false,
      );

      // 3. Update Sale Balance (Allocation Logic)
      if (payment.saleId != null) {
        final sale = await (db.select(
          db.sales,
        )..where((t) => t.id.equals(payment.saleId!))).getSingle();

        final paymentAmountCents = (payment.amount * 100).round();
        final newPaid = sale.amountPaidCents + paymentAmountCents;
        final newBalance = sale.totalCents - newPaid;
        final newPaymentStatus = newBalance <= 0 ? 'paid' : 'partial';

        await (db.update(db.sales)..where((t) => t.id.equals(sale.id))).write(
          drift_db.SalesCompanion(
            amountPaidCents: Value(newPaid),
            balanceCents: Value(newBalance),
            paymentStatus: Value(newPaymentStatus),
          ),
        );
      }

      // 4. If cash payment and session provided, register cash movement
      if (cashSessionId != null && payment.paymentMethod == 'Efectivo') {
        // Fetch customer and user details for better description
        final customerRow = await (db.select(
          db.customers,
        )..where((t) => t.id.equals(payment.customerId))).getSingleOrNull();

        final customerName = customerRow != null
            ? '${customerRow.firstName} ${customerRow.lastName}'
            : 'Cliente ID: ${payment.customerId}';

        final userName =
            (await (db.select(db.users)
                      ..where((t) => t.id.equals(payment.processedBy)))
                    .getSingleOrNull())
                ?.username ??
            'Usuario ID: ${payment.processedBy}';

        final refText =
            payment.reference != null && payment.reference!.isNotEmpty
            ? 'Ref: ${payment.reference}'
            : '';

        // Add allocation info to description
        String allocText = 'Abono General';
        if (payment.saleId != null) {
          final saleRow = await (db.select(
            db.sales,
          )..where((t) => t.id.equals(payment.saleId!))).getSingleOrNull();
          if (saleRow != null) {
            allocText = 'Nota ${saleRow.saleNumber}';
          } else {
            allocText = 'Nota #${payment.saleId}';
          }
        }

        await db
            .into(db.cashMovements)
            .insert(
              drift_db.CashMovementsCompanion.insert(
                cashSessionId: cashSessionId,
                movementType: 'entry',
                amountCents: (payment.amount * 100).round(),
                reason: 'Abono a cuenta',
                description: Value(
                  'Abono ($allocText): $customerName. Realizado por: $userName. $refText',
                ),
                performedBy: payment.processedBy,
                movementDate: Value(DateTime.now()),
              ),
            );
      }

      return id;
    });
  }

  @override
  Future<void> voidPayment({
    required int paymentId,
    required int performedBy,
    required String reason,
  }) async {
    return await db.transaction(() async {
      // 1. Get original payment
      final original = await (db.select(
        db.customerPayments,
      )..where((t) => t.id.equals(paymentId))).getSingle();

      if (original.status == 'voided') {
        throw Exception('El pago ya ha sido anulado.');
      }

      // 2. Update Status to 'voided'
      await (db.update(
        db.customerPayments,
      )..where((t) => t.id.equals(paymentId))).write(
        drift_db.CustomerPaymentsCompanion(
          status: const Value('voided'),
          notes: Value('${original.notes ?? ''} [ANULADO: $reason]'.trim()),
        ),
      );

      // 3. Update Credit (Add debt back - Reverse payment effect)
      await updateCustomerCredit(
        original.customerId,
        original.amountCents / 100.0,
        isIncrement: true,
      );

      // 4. Revert Allocation (If assigned to sale)
      if (original.saleId != null) {
        final sale = await (db.select(
          db.sales,
        )..where((t) => t.id.equals(original.saleId!))).getSingle();

        final newPaid = sale.amountPaidCents - original.amountCents;
        final newBalance = sale.totalCents - newPaid;
        final newPaymentStatus = newPaid <= 0
            ? 'unpaid'
            : (newBalance <= 0 ? 'paid' : 'partial');

        await (db.update(db.sales)..where((t) => t.id.equals(sale.id))).write(
          drift_db.SalesCompanion(
            amountPaidCents: Value(newPaid),
            balanceCents: Value(newBalance),
            paymentStatus: Value(newPaymentStatus),
          ),
        );
      }

      // 5. If cash, reverse movement (Withdrawal)
      if (original.paymentMethod == 'Efectivo') {
        final session =
            await (db.select(db.cashSessions)..where(
                  (t) => t.userId.equals(performedBy) & t.closedAt.isNull(),
                ))
                .getSingleOrNull();

        if (session != null) {
          await db
              .into(db.cashMovements)
              .insert(
                drift_db.CashMovementsCompanion.insert(
                  cashSessionId: session.id,
                  movementType: 'withdrawal',
                  amountCents: original.amountCents,
                  reason: 'Anulación de Abono',
                  description: Value(
                    'Anulación abono #${original.id}. Razón: $reason',
                  ),
                  performedBy: performedBy,
                  movementDate: Value(DateTime.now()),
                ),
              );
        }
      }
    });
  }

  @override
  Stream<List<CustomerPayment>> getPaymentsStream(int customerId) {
    final query =
        db.select(db.customerPayments).join([
            leftOuterJoin(
              db.users,
              db.users.id.equalsExp(db.customerPayments.processedBy),
            ),
          ])
          ..where(db.customerPayments.customerId.equals(customerId))
          ..orderBy([OrderingTerm.desc(db.customerPayments.paymentDate)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final payment = row.readTable(db.customerPayments);
        final user = row.readTableOrNull(db.users);

        return CustomerPayment(
          id: payment.id,
          customerId: payment.customerId,
          amount: payment.amountCents / 100.0,
          paymentMethod: payment.paymentMethod,
          reference: payment.reference,
          paymentDate: payment.paymentDate,
          processedBy: payment.processedBy,
          processedByName: user?.username,
          notes: payment.notes,
          status: payment.status,
          type: payment.type,
          saleId: payment.saleId,
          createdAt: payment.createdAt,
        );
      }).toList();
    });
  }

  @override
  Future<List<CustomerPayment>> getPayments(int customerId) async {
    final query =
        db.select(db.customerPayments).join([
            leftOuterJoin(
              db.users,
              db.users.id.equalsExp(db.customerPayments.processedBy),
            ),
          ])
          ..where(db.customerPayments.customerId.equals(customerId))
          ..orderBy([OrderingTerm.desc(db.customerPayments.paymentDate)]);

    final rows = await query.get();

    return rows.map((row) {
      final payment = row.readTable(db.customerPayments);
      final user = row.readTableOrNull(db.users);

      return CustomerPayment(
        id: payment.id,
        customerId: payment.customerId,
        amount: payment.amountCents / 100.0,
        paymentMethod: payment.paymentMethod,
        reference: payment.reference,
        paymentDate: payment.paymentDate,
        processedBy: payment.processedBy,
        processedByName: user?.username,
        notes: payment.notes,
        status: payment.status,
        type: payment.type,
        saleId: payment.saleId,
        createdAt: payment.createdAt,
      );
    }).toList();
  }

  @override
  Future<List<Customer>> getDebtors() async {
    // Filter customers with creditUsed > 0
    final q = db.select(db.customers)
      ..where((t) => t.creditUsedCents.isBiggerThanValue(0))
      ..orderBy([(t) => OrderingTerm.desc(t.creditUsedCents)]);

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
            creditLimit: row.creditLimitCents != null
                ? row.creditLimitCents! / 100.0
                : null,
            creditUsed: row.creditUsedCents / 100.0,
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
}
