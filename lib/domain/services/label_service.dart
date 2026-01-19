import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:posventa/core/utils/file_manager_service.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/domain/repositories/settings_repository.dart';
import 'package:posventa/domain/services/printer_service.dart';

class LabelPrintRequest {
  final Product product;
  final ProductVariant? variant;
  final int quantity;

  LabelPrintRequest({required this.product, this.variant, this.quantity = 1});
}

class LabelService {
  final SettingsRepository _settingsRepository;
  final PrinterService _printerService;

  LabelService(this._settingsRepository, this._printerService);

  /// Prints labels or saves them as PDF if no printer is configured.
  /// Returns the path of the saved PDF if saved, or null if printed.
  Future<String?> printLabels(List<LabelPrintRequest> requests) async {
    final doc = pw.Document();

    // Standard thermal label size (e.g., 50mm x 30mm)
    const labelWidth = 50.0 * PdfPageFormat.mm;
    const labelHeight = 30.0 * PdfPageFormat.mm;
    final format = PdfPageFormat(labelWidth, labelHeight);

    for (final request in requests) {
      final product = request.product;
      final variant = request.variant;

      final productName = product.name;
      final variantName = variant?.variantName ?? '';
      final price = variant != null ? variant.price : product.price;
      final barcodeData =
          variant != null &&
              variant.barcode != null &&
              variant.barcode!.isNotEmpty
          ? variant.barcode!
          : product.barcode;

      // Add a page for each quantity count
      for (int i = 0; i < request.quantity; i++) {
        doc.addPage(
          pw.Page(
            pageFormat: format,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      productName,
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      maxLines: 2,
                      textAlign: pw.TextAlign.center,
                      overflow: pw.TextOverflow.clip,
                    ),
                    if (variantName.isNotEmpty)
                      pw.Text(
                        variantName,
                        style: const pw.TextStyle(fontSize: 6),
                        textAlign: pw.TextAlign.center,
                      ),
                    pw.SizedBox(height: 2),
                    if (barcodeData != null && barcodeData.isNotEmpty)
                      pw.BarcodeWidget(
                        barcode: pw.Barcode.code128(),
                        data: barcodeData,
                        width: labelWidth * 0.8,
                        height: 20,
                        drawText: true,
                        textStyle: const pw.TextStyle(fontSize: 6),
                      ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }
    }

    // Printer logic
    final settings = await _settingsRepository.getSettings();
    final printerName = settings.printerName;
    Printer? targetPrinter;
    bool shouldPrint = false;

    if (printerName != null) {
      // Check for PDF pseudo-printers to avoid system dialog
      final lowerName = printerName.toLowerCase();
      final isPdfPrinter =
          lowerName.contains('pdf') ||
          lowerName.contains('microsoft print to pdf') ||
          lowerName.contains('adobe pdf') ||
          lowerName.contains('foxit') ||
          lowerName.contains('cutepdf') ||
          lowerName.contains('novapdf');

      if (!isPdfPrinter) {
        try {
          final printers = await _printerService.getPrinters();
          targetPrinter = printers
              .where((p) => p.name == printerName)
              .firstOrNull;
          if (targetPrinter != null) {
            shouldPrint = true;
          }
        } catch (e) {
          // Ignore error, fallback to saving PDF
        }
      }
    }

    if (shouldPrint && targetPrinter != null) {
      await Printing.directPrintPdf(
        printer: targetPrinter,
        onLayout: (PdfPageFormat format) async => doc.save(),
      );
      return null;
    } else {
      // Automatic PDF save
      final pdfPath =
          settings.pdfSavePath ??
          await FileManagerService.getDefaultPdfSavePath();

      final organizedPath = FileManagerService.getOrganizedPath(pdfPath);
      await FileManagerService.ensureDirectoryExists(organizedPath);

      final fileName = FileManagerService.generateFileName(
        'etiquetas', // Prefix
        'pdf',
        identifier: 'batch_${requests.length}_items',
      );

      final filePath = '$organizedPath${Platform.pathSeparator}$fileName';
      final file = File(filePath);
      await file.writeAsBytes(await doc.save());

      return filePath;
    }
  }

  // Deprecated/Legacy wrapper for single print
  Future<void> printProductLabel({
    required Product product,
    ProductVariant? variant,
    int quantity = 1,
  }) async {
    await printLabels([
      LabelPrintRequest(product: product, variant: variant, quantity: quantity),
    ]);
  }
}
