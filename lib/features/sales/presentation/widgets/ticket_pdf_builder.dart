import 'dart:io';
import 'package:image/image.dart' as img;
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

    // Adjust margins for thermal printers
    // 58mm ~ 58 * 2.835 = 164 points
    // 80mm ~ 80 * 2.835 = 226 points
    // But we use roll57 and roll80 formats from the library
    final format = is58mm ? PdfPageFormat.roll57 : PdfPageFormat.roll80;

    // Formatter for currency
    final currency = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    // Use a monospaced font
    final font = pw.Font.courier();

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(5),
        theme: pw.ThemeData.withFont(base: font, bold: font),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // --- HEADER ---
              if (ticket.storeLogoPath != null &&
                  ticket.storeLogoPath!.isNotEmpty)
                pw.Container(
                  height: 100,
                  margin: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Center(
                    child: (() {
                      final file = File(ticket.storeLogoPath!);
                      if (file.existsSync()) {
                        final bytes = file.readAsBytesSync();
                        final image = img.decodeImage(bytes);
                        if (image != null) {
                          final grayscale = img.grayscale(image);
                          final pngBytes = img.encodePng(grayscale);
                          return pw.Image(
                            pw.MemoryImage(pngBytes),
                            fit: pw.BoxFit.contain,
                          );
                        }
                      }
                      return pw.Container(); // Return empty if failed
                    })(),
                  ),
                ),

              pw.Center(
                child: pw.Text(
                  ticket.storeName.toUpperCase(),
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              if (ticket.storeBusinessName != null &&
                  ticket.storeBusinessName!.isNotEmpty)
                pw.Text(
                  ticket.storeBusinessName!,
                  style: const pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),
              pw.SizedBox(height: 4),

              if (ticket.storeAddress.isNotEmpty)
                pw.Text(
                  ticket.storeAddress,
                  style: const pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),

              if (ticket.storePhone.isNotEmpty)
                pw.Text(
                  'Tel: ${ticket.storePhone}',
                  style: const pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),

              if (ticket.storeTaxId != null && ticket.storeTaxId!.isNotEmpty)
                pw.Text(
                  'RFC: ${ticket.storeTaxId}',
                  style: const pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),

              if (ticket.storeEmail != null && ticket.storeEmail!.isNotEmpty)
                pw.Text(
                  ticket.storeEmail!,
                  style: const pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),

              if (ticket.storeWebsite != null &&
                  ticket.storeWebsite!.isNotEmpty)
                pw.Text(
                  ticket.storeWebsite!,
                  style: const pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),

              // Separator
              pw.SizedBox(height: 6),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 6),

              // --- METADATA ---
              // Attempt to put on same line if 80mm, stack if 58mm?
              // Standard receipts often do single line for date
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Fecha:', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(
                    dateFormat.format(ticket.sale.createdAt),
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Ticket:', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(
                    '#${ticket.sale.saleNumber}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Cashier Name
              if (ticket.cashierName != null && ticket.cashierName!.isNotEmpty)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Le atendió:',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      ticket.cashierName!,
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              pw.SizedBox(height: 6),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 4),

              // --- ITEMS HEADER ---
              pw.Row(
                children: [
                  pw.SizedBox(
                    width: 25,
                    child: pw.Text(
                      'CANT',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      'DESCRIPCION',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.SizedBox(
                    width: 45,
                    child: pw.Text(
                      'TOTAL',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 4),

              // --- ITEMS ---
              ...ticket.items.map((item) {
                final qty = item.quantity.toStringAsFixed(2); // e.g. 1.00
                // Use totalCents logic. Assuming totalCents is unitPrice * qty
                // We'll calculate unit price for display: (total / qty)
                // Or just use unitPrice if available (TicketData usually has it, let's verify TicketData model if we need changes).
                // Looking at previous file view, TicketData uses TicketItem which has totalCents.
                // We'll trust the math.

                final totalVal = item.totalCents / 100.0;
                final unitPrice =
                    totalVal /
                    item.quantity; // Heuristic if unit price not in item

                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Description on top line
                      pw.Text(
                        item.productName ?? 'Producto',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      // Qty x Price ..... Total
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            // Remove trailing zeros for display if integer? No, receipts usually explicit: 1.00
                            '${qty.replaceAll(RegExp(r'\.0+$'), '')} x \$${unitPrice.toStringAsFixed(2)}',
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                          pw.Text(
                            currency.format(totalVal),
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              pw.SizedBox(height: 6),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 6),

              // --- TOTALS ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Subtotal:', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(
                    currency.format(ticket.subtotal),
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
              if (ticket.discount > 0)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Descuento:',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      '-${currency.format(ticket.discount)}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),

              // Tax if applicable
              // if (ticket.tax > 0) ...
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL:',
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

              // Payment info (if available in ticket data, otherwise skipped)
              pw.SizedBox(height: 12),

              // --- FOOTER ---
              if (ticket.footerMessage != null)
                pw.Center(
                  child: pw.Text(
                    ticket.footerMessage!,
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontStyle: pw.FontStyle.italic,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                )
              else
                pw.Center(
                  child: pw.Text(
                    '¡Gracias por su compra!',
                    style: const pw.TextStyle(fontSize: 10),
                    textAlign: pw.TextAlign.center,
                  ),
                ),

              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text('.', style: const pw.TextStyle(fontSize: 6)),
              ), // Feed padding
            ],
          );
        },
      ),
    );

    return pdf;
  }
}
