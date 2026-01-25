import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/domain/services/printer_service.dart';
import 'package:posventa/domain/entities/ticket_data.dart';
import 'package:posventa/domain/repositories/i_store_repository.dart';
import 'package:posventa/core/utils/file_manager_service.dart';

sealed class PrintTicketResult {}

// ... (classes TicketPrinted, TicketPdfSaved, TicketPrintFailure remain the same)
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

    try {
      await _printerService.printTicket(ticketData);
      return TicketPrinted();
    } catch (e) {
      // PDF fallback if direct printing fails
      try {
        final pdfPath = await FileManagerService.getDefaultPdfSavePath();
        final savedPath = await _printerService.savePdfTicket(
          ticketData,
          pdfPath,
        );

        // Show PDF preview so the user can see it/print manually
        await _printerService.showPdfTicket(ticketData);

        return TicketPdfSaved(savedPath);
      } catch (pdfError) {
        return TicketPrintFailure(
          'Error al imprimir y al generar PDF: $pdfError',
        );
      }
    }
  }
}
