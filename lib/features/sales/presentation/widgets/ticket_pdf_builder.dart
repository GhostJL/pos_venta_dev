import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:posventa/features/sales/domain/models/ticket_data.dart';
import 'package:intl/intl.dart';

class TicketPdfBuilder {
  static Future<pw.Document> buildTicket(
    TicketData ticket, {
    bool is58mm = false,
  }) async {
    final pdf = pw.Document();
    final format = is58mm ? PdfPageFormat.roll57 : PdfPageFormat.roll80;

    // Formatter for currency
    final currency = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Text(
                  ticket.storeName,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (ticket.storeAddress.isNotEmpty)
                pw.Center(
                  child: pw.Text(
                    ticket.storeAddress,
                    style: const pw.TextStyle(fontSize: 10),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              pw.SizedBox(height: 10),

              // Ticket Info
              pw.Text('Ticket: ${ticket.sale.saleNumber}'),
              pw.Text('Fecha: ${dateFormat.format(ticket.sale.createdAt)}'),
              pw.Divider(),

              // Items
              ...ticket.items.map((item) {
                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      flex: 4,
                      child: pw.Text(
                        '${item.quantity.toStringAsFixed(1)} x ${item.productName}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        currency.format(item.totalCents / 100.0),
                        style: const pw.TextStyle(fontSize: 10),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                );
              }),

              pw.Divider(),

              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Subtotal:', style: const pw.TextStyle(fontSize: 12)),
                  pw.Text(
                    currency.format(ticket.subtotal),
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
              if (ticket.discount > 0)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Descuento:',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                    pw.Text(
                      '-${currency.format(ticket.discount)}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total:',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  pw.Text(
                    currency.format(ticket.total),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 10),
              // Footer
              pw.Center(
                child: pw.Text(
                  ticket.footerMessage ?? 'Gracias por su compra',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }
}
