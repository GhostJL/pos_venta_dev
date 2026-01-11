import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:posventa/domain/services/printer_service.dart';
import 'package:posventa/features/sales/domain/models/ticket_data.dart';
import 'package:posventa/features/sales/presentation/widgets/ticket_pdf_builder.dart'; // We will create this next
import 'package:printing/printing.dart';

class PrinterServiceImpl implements PrinterService {
  @override
  Future<List<Printer>> getPrinters() async {
    return await Printing.listPrinters();
  }

  @override
  Future<void> printTicket(TicketData ticketData, {Printer? printer}) async {
    final pdf = await TicketPdfBuilder.buildTicket(ticketData);

    if (printer != null) {
      await Printing.directPrintPdf(
        printer: printer,
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } else {
      // Fallback: Show print preview/dialog
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Ticket_${ticketData.sale.saleNumber}',
        format: PdfPageFormat.roll80, // Default to 80mm roll format for preview
      );
    }
  }

  @override
  Future<void> testPrint({Printer? printer}) async {
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
}
