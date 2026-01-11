import 'package:posventa/features/sales/domain/models/ticket_data.dart';
import 'package:printing/printing.dart'; // We use the printing package types for Printer object

abstract class PrinterService {
  /// Get list of available printers
  Future<List<Printer>> getPrinters();

  /// Print a ticket
  /// [printer] is the target printer. If null, it might open a dialog or use default.
  Future<void> printTicket(TicketData ticketData, {Printer? printer});

  /// Test print
  Future<void> testPrint({Printer? printer});
}
