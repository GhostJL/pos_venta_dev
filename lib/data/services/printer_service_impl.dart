import 'dart:io';
import 'dart:typed_data';
import 'package:blue_thermal_printer/blue_thermal_printer.dart' as blue;
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:posventa/core/utils/file_manager_service.dart';
import 'package:posventa/domain/entities/customer.dart';
import 'package:posventa/domain/entities/customer_payment.dart';
import 'package:posventa/domain/entities/store.dart';
import 'package:posventa/domain/services/printer_service.dart';
import 'package:posventa/domain/entities/ticket_data.dart';
import 'package:posventa/presentation/widgets/sale/ticket_pdf_builder.dart';
import 'package:posventa/presentation/widgets/customers/payment_receipt_pdf_builder.dart';
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

    // Totals Section - Standard Supermarket Format

    // Subtotal (before discounts and taxes)
    bytes += generator.text(
      'Subtotal: \$${(ticketData.subtotal).toStringAsFixed(2)}',
      styles: const PosStyles(align: PosAlign.right),
    );

    // Discount if applicable
    if (ticketData.discount > 0) {
      bytes += generator.text(
        'Descuento: -\$${(ticketData.discount).toStringAsFixed(2)}',
        styles: const PosStyles(align: PosAlign.right),
      );
    }

    // Subtotal Neto (after discount, before tax) - only if there's discount or tax
    if (ticketData.discount > 0 || ticketData.tax > 0) {
      bytes += generator.hr(ch: '-');
      final subtotalNeto = ticketData.subtotal - ticketData.discount;
      bytes += generator.text(
        'Subtotal Neto: \$${subtotalNeto.toStringAsFixed(2)}',
        styles: const PosStyles(align: PosAlign.right),
      );
    }

    // Tax if applicable
    if (ticketData.tax > 0) {
      bytes += generator.text(
        'IVA (16%): +\$${(ticketData.tax).toStringAsFixed(2)}',
        styles: const PosStyles(align: PosAlign.right),
      );
    }

    // Separator before total
    bytes += generator.hr(ch: '=');

    // TOTAL
    bytes += generator.text(
      'TOTAL A PAGAR: \$${(ticketData.total).toStringAsFixed(2)}',
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
    required Store store,
    String? cashierName,
    Printer? printer,
  }) async {
    if (Platform.isAndroid) {
      await _printAndroidPaymentReceipt(
        payment,
        customer,
        store,
        printer,
        cashierName,
      );
      return;
    }

    final pdf = await PaymentReceiptPdfBuilder.buildReceipt(
      payment: payment,
      customer: customer,
      store: store,
      cashierName: cashierName,
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
    Store store,
    Printer? printer,
    String? cashierName,
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

    // Store Header
    bytes += generator.text(
      store.name,
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
        bold: true,
      ),
    );
    bytes += generator.feed(1);

    if (store.businessName != null && store.businessName!.isNotEmpty) {
      bytes += generator.text(
        store.businessName!,
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    if (store.address != null && store.address!.isNotEmpty) {
      bytes += generator.text(
        store.address!,
        styles: const PosStyles(align: PosAlign.center),
      );
    }
    if (store.phone != null && store.phone!.isNotEmpty) {
      bytes += generator.text(
        'Tel: ${store.phone}',
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    if (store.taxId != null && store.taxId!.isNotEmpty) {
      bytes += generator.text(
        'RFC: ${store.taxId}',
        styles: const PosStyles(align: PosAlign.center),
      );
    }
    if (store.email != null && store.email!.isNotEmpty) {
      bytes += generator.text(
        store.email!,
        styles: const PosStyles(align: PosAlign.center),
      );
    }
    if (store.website != null && store.website!.isNotEmpty) {
      bytes += generator.text(
        store.website!,
        styles: const PosStyles(align: PosAlign.center),
      );
    }
    bytes += generator.feed(1);

    // Title
    bytes += generator.text(
      'COMPROBANTE DE PAGO',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(1);

    bytes += generator.text('Cliente: ${customer.fullName}');
    if (cashierName != null && cashierName.isNotEmpty) {
      bytes += generator.text('Le atendió: $cashierName');
    }
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

    // Footer
    if (store.receiptFooter != null && store.receiptFooter!.isNotEmpty) {
      bytes += generator.text(
        store.receiptFooter!,
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
    }
    bytes += generator.text(
      '¡Gracias por su pago!',
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.feed(3);
    bytes += generator.cut();

    await _bluetooth.writeBytes(Uint8List.fromList(bytes));
  }

  @override
  Future<String> savePdfTicket(TicketData ticketData, String savePath) async {
    // Generate organized path with year/month subdirectories
    final organizedPath = FileManagerService.getOrganizedPath(
      savePath,
      category: 'Tickets Venta',
    );
    await FileManagerService.ensureDirectoryExists(organizedPath);

    // Generate unique filename
    final fileName = FileManagerService.generateFileName(
      'ticket',
      'pdf',
      identifier: ticketData.sale.saleNumber,
    );

    final filePath = '$organizedPath${Platform.pathSeparator}$fileName';

    // Build PDF
    final pdf = await TicketPdfBuilder.buildTicket(ticketData);
    final bytes = await pdf.save();

    // Save to file
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    return filePath;
  }

  @override
  Future<String> savePdfPaymentReceipt({
    required CustomerPayment payment,
    required Customer customer,
    required Store store,
    String? cashierName,
    required String savePath,
  }) async {
    // Generate organized path with year/month subdirectories
    final organizedPath = FileManagerService.getOrganizedPath(
      savePath,
      category: 'Abonos',
    );
    await FileManagerService.ensureDirectoryExists(organizedPath);

    // Generate unique filename
    final fileName = FileManagerService.generateFileName(
      'payment',
      'pdf',
      identifier: payment.id?.toString() ?? 'new',
    );

    final filePath = '$organizedPath${Platform.pathSeparator}$fileName';

    // Build PDF
    final pdf = await PaymentReceiptPdfBuilder.buildReceipt(
      payment: payment,
      customer: customer,
      store: store,
      cashierName: cashierName,
    );

    // Save to file
    final bytes = await pdf.save();
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    return filePath;
  }
}
