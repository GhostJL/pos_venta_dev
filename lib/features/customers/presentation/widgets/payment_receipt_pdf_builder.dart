import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:posventa/domain/entities/customer.dart';
import 'package:posventa/domain/entities/customer_payment.dart';
import 'package:posventa/domain/entities/store.dart';

class PaymentReceiptPdfBuilder {
  static Future<pw.Document> buildReceipt({
    required CustomerPayment payment,
    required Customer customer,
    required Store store,
    bool is58mm = false,
  }) async {
    final pdf = pw.Document();

    // Adjust margins for thermal printers
    final format = is58mm ? PdfPageFormat.roll57 : PdfPageFormat.roll80;

    // Formatter for currency
    final currency = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
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
              // --- LOGO ---
              if (store.logoPath != null && store.logoPath!.isNotEmpty)
                pw.Container(
                  height: 100,
                  margin: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Center(
                    child: (() {
                      final file = File(store.logoPath!);
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
                      return pw.Container();
                    })(),
                  ),
                ),

              // --- HEADER ---
              pw.Center(
                child: pw.Text(
                  store.name.toUpperCase(),
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),

              if (store.businessName != null && store.businessName!.isNotEmpty)
                pw.Text(
                  store.businessName!,
                  style: const pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),

              pw.SizedBox(height: 4),

              if (store.address != null && store.address!.isNotEmpty)
                pw.Text(
                  store.address!,
                  style: const pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),

              if (store.phone != null && store.phone!.isNotEmpty)
                pw.Text(
                  'Tel: ${store.phone}',
                  style: const pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),

              if (store.taxId != null && store.taxId!.isNotEmpty)
                pw.Text(
                  'RFC: ${store.taxId}',
                  style: const pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),

              if (store.email != null && store.email!.isNotEmpty)
                pw.Text(
                  store.email!,
                  style: const pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),

              if (store.website != null && store.website!.isNotEmpty)
                pw.Text(
                  store.website!,
                  style: const pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),

              // Separator
              pw.SizedBox(height: 6),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 6),

              // --- TITLE ---
              pw.Text(
                'COMPROBANTE DE PAGO',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: pw.TextAlign.center,
              ),

              pw.SizedBox(height: 6),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 6),

              // --- METADATA ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Fecha:', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(
                    payment.paymentDate.toString().substring(0, 16),
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Cliente:', style: const pw.TextStyle(fontSize: 10)),
                  pw.Expanded(
                    child: pw.Text(
                      customer.fullName,
                      style: const pw.TextStyle(fontSize: 10),
                      textAlign: pw.TextAlign.right,
                      maxLines: 1,
                      overflow: pw.TextOverflow.clip,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 6),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 6),

              // --- PAYMENT DETAILS ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'ABONO:',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  pw.Text(
                    currency.format(payment.amount),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 4),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Método:', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(
                    payment.paymentMethod,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),

              if (payment.reference != null && payment.reference!.isNotEmpty)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Referencia:',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        payment.reference!,
                        style: const pw.TextStyle(fontSize: 10),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),

              pw.SizedBox(height: 6),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 6),

              // --- FOOTER ---
              if (store.receiptFooter != null &&
                  store.receiptFooter!.isNotEmpty)
                pw.Center(
                  child: pw.Text(
                    store.receiptFooter!,
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
                    '¡Gracias por su pago!',
                    style: const pw.TextStyle(fontSize: 10),
                    textAlign: pw.TextAlign.center,
                  ),
                ),

              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text('.', style: const pw.TextStyle(fontSize: 6)),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }
}
