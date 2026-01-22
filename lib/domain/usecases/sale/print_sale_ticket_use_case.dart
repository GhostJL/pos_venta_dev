import 'package:posventa/core/utils/file_manager_service.dart';
import 'package:posventa/domain/entities/sale.dart';
import 'package:posventa/domain/entities/sale_item.dart';
import 'package:posventa/domain/entities/ticket_data.dart';
import 'package:posventa/domain/entities/user.dart';
import 'package:posventa/domain/repositories/settings_repository.dart';
import 'package:posventa/domain/repositories/i_store_repository.dart';
import 'package:posventa/domain/repositories/sale_return_repository.dart';
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
  final SaleReturnRepository _saleReturnRepository;

  PrintSaleTicketUseCase(
    this._printerService,
    this._settingsRepository,
    this._storeRepository,
    this._saleReturnRepository,
  );

  Future<PrintSaleTicketResult> execute({
    required Sale sale,
    required User? cashier,
  }) async {
    try {
      final settings = await _settingsRepository.getSettings();
      final store = await _storeRepository.getStore();
      final returnedQuantities = await _saleReturnRepository
          .getReturnedQuantities(sale.id!);

      // Filter and adjust items based on returns
      final effectiveItems = sale.items
          .map((item) {
            final returnedQty = returnedQuantities[item.id] ?? 0.0;
            final remainingQty = item.quantity - returnedQty;

            if (remainingQty <= 0) return null;

            if (remainingQty < item.quantity) {
              // Calculate proportional values based on remaining quantity
              final ratio = remainingQty / item.quantity;
              return item.copyWith(
                quantity: remainingQty,
                subtotalCents: (item.subtotalCents * ratio).round(),
                taxCents: (item.taxCents * ratio).round(),
                discountCents: (item.discountCents * ratio).round(),
                totalCents: (item.totalCents * ratio).round(),
              );
            }
            return item;
          })
          .whereType<SaleItem>()
          .toList();

      // Recalculate Sale Item totals for the header/footer
      int newSubtotal = 0;
      int newTax = 0;
      int newDiscount = 0;
      int newTotal = 0;

      for (final item in effectiveItems) {
        newSubtotal += item.subtotalCents;
        newTax += item.taxCents;
        newDiscount += item.discountCents;
        newTotal += item.totalCents;
      }

      // Create a virtual sale object with updated totals for the ticket
      // Note: We keep original payments. The difference between payments and newTotal
      // will correctly appear as "Change" (which effectively represents the Refunded Amount).
      final effectiveSale =
          effectiveItems.length != sale.items.length ||
              effectiveItems.any((i) => i.quantity != 0)
          ? Sale(
              id: sale.id,
              saleNumber: sale.saleNumber,
              warehouseId: sale.warehouseId,
              customerId: sale.customerId,
              cashierId: sale.cashierId,
              subtotalCents: newSubtotal,
              discountCents: newDiscount,
              taxCents: newTax,
              totalCents: newTotal,
              amountPaidCents: sale.amountPaidCents,
              balanceCents: sale
                  .balanceCents, // This might need review if balance matters
              paymentStatus: sale.paymentStatus,
              status: sale.status,
              saleDate: sale.saleDate,
              createdAt: sale.createdAt,
              cancelledBy: sale.cancelledBy,
              cancelledAt: sale.cancelledAt,
              cancellationReason: sale.cancellationReason,
              items: effectiveItems,
              payments: sale.payments,
              customerName: sale.customerName,
            )
          : sale;

      final printerName = settings.printerName;

      final ticketData = TicketData(
        sale: effectiveSale,
        items: effectiveItems,
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
