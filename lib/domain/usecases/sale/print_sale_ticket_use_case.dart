import 'package:posventa/core/utils/file_manager_service.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/domain/entities/ticket_data.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/domain/repositories/settings_repository.dart';
import 'package:posventa/domain/repositories/i_store_repository.dart';
import 'package:posventa/domain/services/printer_service.dart';

sealed class PrintSaleTicketResult {}

class TicketPrinted extends PrintSaleTicketResult {
  final String printerName;
  TicketPrinted(this.printerName);
}

class TicketPdfSaved extends PrintSaleTicketResult {
  final String path;
  TicketPdfSaved(this.path);
}

class TicketPrintFailure extends PrintSaleTicketResult {
  final String message;
  TicketPrintFailure(this.message);
}

class PrintSaleTicketUseCase {
  final PrinterService _printerService;
  final SettingsRepository _settingsRepository;
  final IStoreRepository _storeRepository;

  PrintSaleTicketUseCase(
    this._printerService,
    this._settingsRepository,
    this._storeRepository,
  );

  Future<PrintSaleTicketResult> execute({
    required Sale sale,
    required User? cashier,
  }) async {
    try {
      final settings = await _settingsRepository.getSettings();
      final store = await _storeRepository.getStore();

      final printerName = settings.printerName;

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
        cashierName: cashier?.name,
      );

      bool printed = false;

      if (printerName != null) {
        try {
          final printers = await _printerService.getPrinters();
          final targetPrinter = printers
              .where((p) => p.name == printerName)
              .firstOrNull;

          if (targetPrinter != null) {
            final lowerName = targetPrinter.name.toLowerCase();
            final isPdfPrinter =
                lowerName.contains('pdf') ||
                lowerName.contains('microsoft print to pdf') ||
                lowerName.contains('adobe pdf') ||
                lowerName.contains('foxit') ||
                lowerName.contains('cutepdf') ||
                lowerName.contains('novapdf');

            if (!isPdfPrinter) {
              await _printerService.printTicket(
                ticketData,
                printer: targetPrinter,
              );
              printed = true;
            }
          }
        } catch (e) {
          // Log but don't fail, try PDF fallback
          // Trigger failure if strictly needed, but current logic falls back
        }
      }

      if (printed && printerName != null) {
        return TicketPrinted(printerName);
      }

      // Fallback to PDF
      final pdfPath =
          settings.pdfSavePath ??
          await FileManagerService.getDefaultPdfSavePath();

      final savedPath = await _printerService.savePdfTicket(
        ticketData,
        pdfPath,
      );

      return TicketPdfSaved(savedPath);
    } catch (e) {
      return TicketPrintFailure(e.toString());
    }
  }
}
