import 'package:posventa/domain/entities/customer.dart';
import 'package:posventa/domain/entities/customer_payment.dart';
import 'package:posventa/features/sales/domain/models/ticket_data.dart';
import 'package:posventa/domain/entities/store.dart';

import 'package:printing/printing.dart'; // We use the printing package types for Printer object

abstract class PrinterService {
  /// Get list of available printers
  Future<List<Printer>> getPrinters();

  /// Print a ticket
  /// [printer] is the target printer. If null, it might open a dialog or use default.
  Future<void> printTicket(TicketData ticketData, {Printer? printer});

  /// Test print
  Future<void> testPrint({Printer? printer});

  /// Scan for Bluetooth printers (Android only)
  Future<List<Printer>> scanBluetoothPrinters();

  /// Connect to Bluetooth printer (Android only)
  Future<void> connectToDevice(Printer printer);

  /// Disconnect from current printer
  Future<void> disconnect();

  /// Print a payment receipt
  Future<void> printPaymentReceipt({
    required CustomerPayment payment,
    required Customer customer,
    required Store store,
    String? cashierName,
    Printer? printer,
  });

  /// Save a ticket as PDF to the specified path
  Future<String> savePdfTicket(TicketData ticketData, String savePath);

  /// Save a payment receipt as PDF to the specified path
  Future<String> savePdfPaymentReceipt({
    required CustomerPayment payment,
    required Customer customer,
    required Store store,
    String? cashierName,
    required String savePath,
  });
}
