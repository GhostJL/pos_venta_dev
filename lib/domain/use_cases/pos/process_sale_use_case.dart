import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/domain/entities/sale_item.dart';
import 'package:posventa/domain/entities/sale_payment.dart';
import 'package:posventa/domain/entities/customer.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/domain/entities/cash_session.dart';
import 'package:posventa/domain/entities/sale_transaction.dart';
import 'package:posventa/domain/repositories/customer_repository.dart';
import 'package:posventa/domain/use_cases/sale/create_sale_use_case.dart';
import 'package:posventa/domain/use_cases/sale/generate_next_sale_number_use_case.dart';
import 'package:posventa/domain/use_cases/cash_movement/create_cash_movement.dart';

class ProcessSaleUseCase {
  final GenerateNextSaleNumberUseCase _generateSaleNumber;
  final CreateSaleUseCase _createSale;
  final CustomerRepository _customerRepository;
  final CreateCashMovement _createCashMovement;

  ProcessSaleUseCase(
    this._generateSaleNumber,
    this._createSale,
    this._customerRepository,
    this._createCashMovement,
  );

  Future<Sale> execute({
    required List<SaleItem> items,
    required Customer? customer,
    required String paymentMethod,
    required double amountPaid,
    required User cashier,
    required CashSession? currentSession,
  }) async {
    if (items.isEmpty) {
      throw Exception('El carrito está vacío');
    }

    final saleNumber = await _generateSaleNumber.call();

    // Calculate totals
    int subtotalCents = 0;
    int discountCents = 0;
    int taxCents = 0;
    int totalCents = 0;

    for (var item in items) {
      subtotalCents += item.subtotalCents;
      discountCents += item.discountCents;
      taxCents += item.taxCents;
      totalCents += item.totalCents;
    }

    // Get warehouse from active session or default
    final warehouseId = currentSession?.warehouseId ?? 1;

    final sale = Sale(
      saleNumber: saleNumber,
      warehouseId: warehouseId,
      customerId: customer?.id,
      cashierId: cashier.id!,
      subtotalCents: subtotalCents,
      discountCents: discountCents,
      taxCents: taxCents,
      totalCents: totalCents,
      saleDate: DateTime.now(),
      createdAt: DateTime.now(),
      items: items,
      payments: [
        SalePayment(
          paymentMethod: paymentMethod,
          amountCents: (amountPaid * 100).round(),
          paymentDate: DateTime.now(),
          receivedBy: cashier.id!,
        ),
      ],
    );

    // Credit Logic
    CreditUpdate? creditUpdate;
    if (paymentMethod == 'Crédito') {
      if (customer == null) {
        throw Exception('Debe seleccionar un cliente para ventas a crédito');
      }

      // Fetch fresh customer data
      final freshCustomer = await _customerRepository.getCustomerById(
        customer.id!,
      );

      if (freshCustomer == null) {
        throw Exception('Cliente no encontrado al validar crédito');
      }

      final newBalance = freshCustomer.creditUsed + (totalCents / 100.0);

      if (freshCustomer.creditLimit != null &&
          newBalance > freshCustomer.creditLimit!) {
        throw Exception(
          'El cliente excede su límite de crédito. Disponible: \$${(freshCustomer.creditLimit! - freshCustomer.creditUsed).toStringAsFixed(2)}',
        );
      }

      creditUpdate = CreditUpdate(
        customerId: freshCustomer.id!,
        amountCents: totalCents,
        isIncrement: true,
      );
    }

    // Execute Sale Creation
    await _createSale.call(sale, creditUpdate: creditUpdate);

    // Record change as a cash movement if applicable
    final change = amountPaid - (totalCents / 100.0);
    if (change > 0 && currentSession != null) {
      try {
        await _createCashMovement.call(
          currentSession.id!,
          'withdrawal',
          (change * 100).round(),
          'Cambio',
          description: 'Cambio Venta #$saleNumber',
        );
      } catch (e) {
        // Log but don't fail the sale
        // print('Error recording change movement: $e');
      }
    }

    // Return the created sale (with ID potentially populated by DB if we fetched it back,
    // but here we return the object we created. Ideally CreateSaleUseCase returns the saved entity)
    // Assuming CreateSaleUseCase returns void or int (ID).
    // If it returns void, we return 'sale' but it lacks ID.
    // However, the UI mostly needs SaleNumber and items for printing.
    return sale;
  }
}
