import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/domain/services/printer_service.dart';
import 'package:posventa/domain/entities/ticket_data.dart';
import 'package:posventa/domain/repositories/i_store_repository.dart';

sealed class PrintTicketResult {}

class TicketPrinted extends PrintTicketResult {}

class TicketPdfSaved extends PrintTicketResult {
  final String path;
  TicketPdfSaved(this.path);
}

class TicketPrintFailure extends PrintTicketResult {
  final String message;
  TicketPrintFailure(this.message);
}

class PrintSaleTicketUseCase {
  final PrinterService _printerService;
  final IStoreRepository _storeRepository;

  PrintSaleTicketUseCase(this._printerService, this._storeRepository);

  Future<PrintTicketResult> execute({required Sale sale, User? cashier}) async {
    try {
      final store = await _storeRepository.getStore();

      final ticketData = TicketData(
        sale: sale,
        items: sale.items,
        storeName: store?.name ?? 'Mi Tienda POS',
        storeBusinessName: store?.businessName,
        storeAddress: store?.address ?? '',
        storePhone: store?.phone ?? '',
        storeTaxId: store?.taxId,
        storeEmail: store?.email,
        storeWebsite: store?.website,
        storeLogoPath: store?.logoPath,
        footerMessage: store?.receiptFooter ?? '¡Gracias por su compra!',
        cashierName: cashier?.name ?? 'Cajero', // Use passed cashier or default
      );

      await _printerService.printTicket(ticketData);
      return TicketPrinted();
    } catch (e) {
      // TODO: Implement PDF fallback if settings allow, for now just return failure
      return TicketPrintFailure(e.toString());
    }
  }
}
