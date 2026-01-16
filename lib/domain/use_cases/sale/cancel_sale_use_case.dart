import 'package:posventa/core/error/domain_exceptions.dart';
import 'package:posventa/core/error/error_reporter.dart';
import 'package:posventa/domain/entities/inventory_movement.dart';
import 'package:posventa/domain/entities/sale_transaction.dart';
import 'package:posventa/domain/use_cases/cash_movement/get_current_session.dart';
import 'package:posventa/domain/use_cases/cash_movement/create_cash_movement.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/domain/repositories/sale_repository.dart';
import 'package:posventa/domain/repositories/settings_repository.dart';

class CancelSaleUseCase {
  final SaleRepository _repository;
  final CreateCashMovement _createCashMovement;
  final GetCurrentSession _getCurrentSession;
  final SettingsRepository _settingsRepository;

  CancelSaleUseCase(
    this._repository,
    this._createCashMovement,
    this._getCurrentSession,
    this._settingsRepository,
  );

  Future<void> call(int saleId, int userId, String reason) async {
    // Fetch the sale to get its details
    final sale = await _repository.getSaleById(saleId);
    if (sale == null) {
      throw SaleNotFoundException(saleId);
    }

    if (sale.status == SaleStatus.cancelled) {
      throw SaleAlreadyCancelledException(saleId);
    }

    if (sale.status == SaleStatus.returned) {
      throw SaleAlreadyReturnedException(
        saleId,
        message:
            'No se puede cancelar una venta que ya ha sido devuelta. Utilice el módulo de devoluciones para más detalles.',
      );
    }

    // Prepare transaction data
    final List<LotRestoration> lotRestorations = [];
    final List<InventoryAdjustment> inventoryAdjustments = [];
    final List<InventoryMovement> movements = [];

    // For each sale item, we need to restore the lots that were deducted
    // This information is stored in the sale_item_lots table
    // The Repository will need to query this table to get the lot deductions
    // For now, we'll prepare the structure and let the Repository handle the details

    // Note: The actual lot restoration details will be fetched by the Repository
    // from the sale_item_lots table during transaction execution.
    // We're just preparing the transaction metadata here.

    // Check inventory settings
    final settings = await _settingsRepository.getSettings();
    final useInventory = settings.useInventory;

    final transaction = SaleCancellationTransaction(
      saleId: saleId,
      userId: userId,
      reason: reason,
      cancelledAt: DateTime.now(),
      lotRestorations: lotRestorations, // Will be populated by Repository
      inventoryAdjustments:
          inventoryAdjustments, // Will be populated by Repository
      movements: movements, // Will be populated by Repository
      restoreInventory: useInventory,
    );

    await _repository.executeSaleCancellation(transaction);

    // Calculate total amount paid
    int totalPaidCents = 0;
    for (final payment in sale.payments) {
      totalPaidCents += payment.amountCents;
    }

    // Determine refund amount:
    // If we paid more than the sale total (i.e., we got change),
    // we should only refund the sale total, because the change was already given back.
    // If we paid partially (less than total), we refund what was paid.
    final int refundAmountCents = (totalPaidCents >= sale.totalCents)
        ? sale.totalCents
        : totalPaidCents;

    if (refundAmountCents > 0) {
      try {
        final currentSession = await _getCurrentSession();
        if (currentSession != null) {
          await _createCashMovement(
            currentSession.id!,
            'return',
            refundAmountCents,
            'Cancelación',
            description: 'Cancelación Venta #${sale.saleNumber}',
          );
        }
      } catch (e, stackTrace) {
        AppErrorReporter().reportError(
          e,
          stackTrace,
          context: 'CancelSaleUseCase - Create Cash Movement',
        );
        // We throw a domain exception so the UI knows something went wrong with the cash movement
        // even though the cancellation itself (stock/sale status) succeeded.
        throw CashMovementException(
          'La venta se canceló, pero hubo un error al registrar la devolución de efectivo.',
          reason: e.toString(),
        );
      }
    }
  }
}
