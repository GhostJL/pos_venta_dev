import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';
import 'package:posventa/domain/entities/inventory_audit.dart';
import 'package:posventa/domain/entities/store.dart';

class InventoryAuditPdfBuilder {
  static Future<void> generateAndOpen({
    required InventoryAuditEntity audit,
    required Store? store,
    String? warehouseName,
    String? userName,
    String? title,
  }) async {
    final pdf = pw.Document();

    // Custom Font handling could ideally go here if we had custom fonts assets

    // Header Data
    final storeName = store?.name ?? "Nombre de la Tienda";
    final storeAddress = store?.address ?? "Dirección de la Tienda";
    final effectiveWarehouseName =
        warehouseName ?? 'Almacén #${audit.warehouseId}';
    final auditorName = userName ?? 'ID: ${audit.performedBy}';

    // Status Translation
    String statusEs = 'DESCONOCIDO';
    switch (audit.status) {
      case InventoryAuditStatus.draft:
        statusEs = 'EN PROCESO';
        break;
      case InventoryAuditStatus.completed:
        statusEs = 'COMPLETADO';
        break;
      case InventoryAuditStatus.cancelled:
        statusEs = 'CANCELADO';
        break;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildCompanyHeader(storeName, storeAddress),
          pw.SizedBox(height: 20),
          _buildReportTitle(
            title ?? 'Reporte de Auditoría de Inventario',
            audit.id.toString(),
            statusEs,
          ),
          pw.SizedBox(height: 10),
          _buildAuditDetails(audit, effectiveWarehouseName, auditorName),
          pw.SizedBox(height: 20),
          _buildSummary(audit),
          pw.SizedBox(height: 20),
          _buildTable(audit),
          pw.SizedBox(height: 40),
          _buildFooter(auditorName),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/auditoria_${audit.id}.pdf');
    await file.writeAsBytes(await pdf.save());

    await OpenFilex.open(file.path);
  }

  static pw.Widget _buildCompanyHeader(String name, String address) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              name,
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.Text(
              address,
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ],
        ),
        // Logo could go here if available
      ],
    );
  }

  static pw.Widget _buildReportTitle(String title, String id, String status) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Folio: #$id',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              pw.Text(
                status,
                style: pw.TextStyle(
                  color: status == 'COMPLETADO'
                      ? PdfColors.green700
                      : PdfColors.orange700,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildAuditDetails(
    InventoryAuditEntity audit,
    String warehouse,
    String auditor,
  ) {
    final dateStr = DateFormat(
      'dd/MM/yyyy HH:mm',
      'es',
    ).format(audit.auditDate);

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _detailRow('Fecha de Inicio:', dateStr),
            _detailRow('Almacén:', warehouse),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            _detailRow('Auditor:', auditor),
            if (audit.notes != null) _detailRow('Notas:', audit.notes!),
          ],
        ),
      ],
    );
  }

  static pw.Widget _detailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: '$label ',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            ),
            pw.TextSpan(text: value, style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildSummary(InventoryAuditEntity audit) {
    int totalItems = audit.items.length;
    int itemsWithDifferences = audit.items
        .where((i) => i.difference.abs() > 0.001)
        .length;
    double totalSurplus = audit.items
        .where((i) => i.difference > 0)
        .fold(0.0, (sum, i) => sum + i.difference);
    double totalLoss = audit.items
        .where((i) => i.difference < 0)
        .fold(0.0, (sum, i) => sum + i.difference.abs());

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300),
          bottom: pw.BorderSide(color: PdfColors.grey300),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Total Productos', '$totalItems'),
          _buildSummaryItem(
            'Con Diferencias',
            '$itemsWithDifferences',
            color: itemsWithDifferences > 0
                ? PdfColors.orange700
                : PdfColors.black,
          ),
          _buildSummaryItem(
            'Total Sobrante',
            '+${totalSurplus.toStringAsFixed(2)}',
            color: PdfColors.green700,
          ),
          _buildSummaryItem(
            'Total Faltante',
            '-${totalLoss.toStringAsFixed(2)}',
            color: PdfColors.red700,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryItem(
    String label,
    String value, {
    PdfColor color = PdfColors.black,
  }) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 10,
            color: PdfColors.grey700,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTable(InventoryAuditEntity audit) {
    return pw.TableHelper.fromTextArray(
      headers: ['Producto', 'Variante', 'Esperado', 'Físico', 'Diferencia'],
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1),
      },
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
        fontSize: 10,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
      ),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignment: pw.Alignment.centerLeft,
      cellAlignments: {
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
      },
      data: audit.items.map((item) {
        final diff = item.difference;
        final diffStr = diff > 0
            ? '+${diff.toStringAsFixed(2)}'
            : diff.toStringAsFixed(2);

        // Highlight row logic could go here, but PDF table helper is simple

        return [
          item.productName ?? 'Desconocido',
          item.variantName ?? '-',
          item.expectedQuantity.toStringAsFixed(2),
          item.countedQuantity.toStringAsFixed(2),
          diffStr,
        ];
      }).toList(),
    );
  }

  static pw.Widget _buildFooter(String auditor) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'Generado automáticamente por el Sistema POS',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
        ),
        pw.SizedBox(height: 30),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
          children: [
            pw.Column(
              children: [
                pw.Container(width: 150, height: 1, color: PdfColors.black),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Firma del Auditor ($auditor)',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
            pw.Column(
              children: [
                pw.Container(width: 150, height: 1, color: PdfColors.black),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Firma del Supervisor',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
