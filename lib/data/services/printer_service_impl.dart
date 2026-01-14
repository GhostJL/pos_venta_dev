import 'dart:io';
import 'dart:typed_data';
import 'package:blue_thermal_printer/blue_thermal_printer.dart' as blue;
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:posventa/domain/entities/customer.dart';
import 'package:posventa/domain/entities/customer_payment.dart';
import 'package:posventa/domain/services/printer_service.dart';
import 'package:posventa/features/sales/domain/models/ticket_data.dart';
import 'package:posventa/features/sales/presentation/widgets/ticket_pdf_builder.dart';
import 'package:printing/printing.dart';

import 'package:permission_handler/permission_handler.dart';

class PrinterServiceImpl implements PrinterService {
  final blue.BlueThermalPrinter _bluetooth = blue.BlueThermalPrinter.instance;

  @override
  Future<List<Printer>> getPrinters() async {
    if (Platform.isAndroid) {
      return scanBluetoothPrinters();
    }
    return await Printing.listPrinters();
  }

  @override
  Future<List<Printer>> scanBluetoothPrinters() async {
    if (!Platform.isAndroid) return [];

    try {
      // Request permissions for Android 12+
      // BLUETOOTH_CONNECT is required to communicate with paired devices
      if (await Permission.bluetoothConnect.request().isGranted) {
        // Some devices/plugins might also need Scan, though getBondedDevices conceptually doesn't scan.
        // Best to be safe.
        await Permission.bluetoothScan.request();

        final devices = await _bluetooth.getBondedDevices();
        return devices
            .map(
              (d) => Printer(
                url: d.address ?? '',
                name: d.name ?? 'Unknown Bluetooth Printer',
              ),
            )
            .toList();
      }
      return [];
    } catch (e) {
      // Ensure we don't throw and hang the UI
      return [];
    }
  }

  @override
  Future<void> connectToDevice(Printer printer) async {
    if (!Platform.isAndroid) return;

    // Check if already connected to this device
    final isConnected = await _bluetooth.isConnected;
    if (isConnected == true) {
      // Logic to check if it's the *same* device is hard without current connection info access in simple API
      // We'll disconnect and reconnect to be safe or just try connecting.
      // For now, simple connection:
    }

    final device = blue.BluetoothDevice(printer.name, printer.url);
    try {
      if (isConnected == true) {
        try {
          await _bluetooth.disconnect();
        } catch (e) {
          // ignore disconnect error
        }
      }
      await _bluetooth.connect(device);
    } catch (e) {
      throw Exception('Could not connect to ${printer.name}: $e');
    }
  }

  @override
  Future<void> disconnect() async {
    if (Platform.isAndroid) {
      await _bluetooth.disconnect();
    }
  }

  @override
  Future<void> printTicket(TicketData ticketData, {Printer? printer}) async {
    if (Platform.isAndroid) {
      await _printAndroidTicket(ticketData, printer);
      return;
    }

    final pdf = await TicketPdfBuilder.buildTicket(ticketData);

    if (printer != null) {
      await Printing.directPrintPdf(
        printer: printer,
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } else {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Ticket_${ticketData.sale.saleNumber}',
        format: PdfPageFormat.roll80,
      );
    }
  }

  Future<void> _printAndroidTicket(
    TicketData ticketData,
    Printer? printer,
  ) async {
    if (printer != null && (await _bluetooth.isConnected) != true) {
      await connectToDevice(printer);
    }

    if ((await _bluetooth.isConnected) != true) {
      throw Exception('Printer not connected');
    }

    // Generate ESC/POS commands
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    // Header
    bytes += generator.text(
      ticketData.storeName,
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
        bold: true,
      ),
    );
    bytes += generator.feed(1);

    if (ticketData.storeAddress.isNotEmpty) {
      bytes += generator.text(
        ticketData.storeAddress,
        styles: const PosStyles(align: PosAlign.center),
      );
    }
    if (ticketData.storePhone.isNotEmpty) {
      bytes += generator.text(
        'Tel: ${ticketData.storePhone}',
        styles: const PosStyles(align: PosAlign.center),
      );
    }
    bytes += generator.feed(1);

    bytes += generator.hr();
    bytes += generator.text('Ticket: ${ticketData.sale.saleNumber}');
    bytes += generator.text('Fecha: ${ticketData.sale.saleDate}');
    bytes += generator.hr();

    // Items
    bytes += generator.row([
      PosColumn(text: 'Cant', width: 2),
      PosColumn(text: 'Producto', width: 7),
      PosColumn(
        text: 'Total',
        width: 3,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    for (final item in ticketData.items) {
      bytes += generator.row([
        PosColumn(text: item.quantity.toStringAsFixed(0), width: 2),
        PosColumn(text: item.productName ?? '', width: 7),
        PosColumn(
          text: '\$${(item.totalCents / 100).toStringAsFixed(2)}',
          width: 3,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr();

    // Totals
    bytes += generator.text(
      'TOTAL: \$${(ticketData.sale.totalCents / 100).toStringAsFixed(2)}',
      styles: const PosStyles(
        align: PosAlign.right,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
        bold: true,
      ),
    );

    bytes += generator.feed(2);
    if (ticketData.footerMessage != null) {
      bytes += generator.text(
        ticketData.footerMessage!,
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
    }
    bytes += generator.feed(3);
    bytes += generator.cut();

    // Send to printer
    await _bluetooth.writeBytes(Uint8List.fromList(bytes));
  }

  @override
  Future<void> testPrint({Printer? printer}) async {
    if (Platform.isAndroid && printer != null) {
      // Android Test
      if ((await _bluetooth.isConnected) != true) {
        try {
          await connectToDevice(printer);
        } catch (e) {
          rethrow;
        }
      }

      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      List<int> bytes = [];
      bytes += generator.text(
        'TEST PRINT SUCCESS',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
        ),
      );
      bytes += generator.feed(3);
      bytes += generator.cut();

      await _bluetooth.writeBytes(Uint8List.fromList(bytes));
      return;
    }

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Center(child: pw.Text("TEST PRINT SUCCESS"));
        },
      ),
    );

    await Printing.directPrintPdf(
      printer: printer ?? const Printer(url: 'default'),
      onLayout: (format) async => pdf.save(),
    );
  }

  @override
  Future<void> printPaymentReceipt({
    required CustomerPayment payment,
    required Customer customer,
    Printer? printer,
  }) async {
    if (Platform.isAndroid) {
      await _printAndroidPaymentReceipt(payment, customer, printer);
      return;
    }

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text(
                'COMPROBANTE DE PAGO',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Cliente: ${customer.fullName}'),
              pw.Text(
                'Fecha: ${payment.paymentDate.toString().substring(0, 16)}',
              ),
              pw.Divider(),
              pw.Text(
                'ABONO: \$${payment.amount.toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              pw.Text('Método: ${payment.paymentMethod}'),
              if (payment.reference != null && payment.reference!.isNotEmpty)
                pw.Text('Ref: ${payment.reference}'),
              pw.Divider(),
              pw.Text('¡Gracias por su pago!'),
            ],
          );
        },
      ),
    );

    if (printer != null) {
      await Printing.directPrintPdf(
        printer: printer,
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } else {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Comprobante_${payment.id}',
        format: PdfPageFormat.roll80,
      );
    }
  }

  Future<void> _printAndroidPaymentReceipt(
    CustomerPayment payment,
    Customer customer,
    Printer? printer,
  ) async {
    if (printer != null && (await _bluetooth.isConnected) != true) {
      await connectToDevice(printer);
    }

    if ((await _bluetooth.isConnected) != true) {
      throw Exception('Printer not connected');
    }

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    // Header
    bytes += generator.text(
      'COMPROBANTE DE PAGO',
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
        bold: true,
      ),
    );
    bytes += generator.feed(1);

    bytes += generator.text('Cliente: ${customer.fullName}');
    bytes += generator.text(
      'Fecha: ${payment.paymentDate.toString().substring(0, 16)}',
    );
    bytes += generator.hr();

    // Amount
    bytes += generator.text(
      'ABONO: \$${payment.amount.toStringAsFixed(2)}',
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
        bold: true,
      ),
    );
    bytes += generator.text(
      'Método: ${payment.paymentMethod}',
      styles: const PosStyles(align: PosAlign.center),
    );

    if (payment.reference != null && payment.reference!.isNotEmpty) {
      bytes += generator.text(
        'Ref: ${payment.reference}',
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    bytes += generator.feed(2);
    bytes += generator.text(
      '¡Gracias por su pago!',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(3);
    bytes += generator.cut();

    await _bluetooth.writeBytes(Uint8List.fromList(bytes));
  }
}
