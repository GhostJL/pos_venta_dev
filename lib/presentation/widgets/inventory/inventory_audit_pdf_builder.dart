import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';
import 'package:posventa/domain/entities/inventory_audit.dart';

class InventoryAuditPdfBuilder {
  static Future<void> generateAndOpen({
    required InventoryAuditEntity audit,
    String? title,
  }) async {
    final pdf = pw.Document();

    // Load font for better compatibility (optional, using standard for now)

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(audit, title),
          pw.SizedBox(height: 20),
          _buildSummary(audit),
          pw.SizedBox(height: 20),
          _buildTable(audit),
          pw.SizedBox(height: 20),
          _buildFooter(audit),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/auditoria_${audit.id}.pdf');
    await file.writeAsBytes(await pdf.save());

    await OpenFilex.open(file.path);
  }

  static pw.Widget _buildHeader(InventoryAuditEntity audit, String? title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title ?? 'Reporte de Auditoría de Inventario',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(audit.auditDate)}',
          style: const pw.TextStyle(fontSize: 14),
        ),
        pw.Text(
          'Almacén ID: ${audit.warehouseId}',
          style: const pw.TextStyle(fontSize: 14),
        ),
        pw.Text(
          'Auditoría ID: #${audit.id}',
          style: const pw.TextStyle(fontSize: 14),
        ),
        pw.Text(
          'Estado: ${audit.status.name.toUpperCase()}',
          style: const pw.TextStyle(fontSize: 14),
        ),
        if (audit.notes != null)
          pw.Text(
            'Notas: ${audit.notes}',
            style: pw.TextStyle(fontSize: 14, fontStyle: pw.FontStyle.italic),
          ),
        pw.Divider(),
      ],
    );
  }

  static pw.Widget _buildSummary(InventoryAuditEntity audit) {
    int totalItems = audit.items.length;
    int itemsWithDifferences = audit.items
        .where((i) => i.difference != 0)
        .length;
    double totalSurplus = audit.items
        .where((i) => i.difference > 0)
        .fold(0.0, (sum, i) => sum + i.difference);
    double totalLoss = audit.items
        .where((i) => i.difference < 0)
        .fold(0.0, (sum, i) => sum + i.difference.abs());

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _buildSummaryItem('Total Productos', '$totalItems'),
        _buildSummaryItem('Con Diferencias', '$itemsWithDifferences'),
        _buildSummaryItem(
          'Total Sobrante',
          '+${totalSurplus.toStringAsFixed(2)}',
        ),
        _buildSummaryItem('Total Faltante', '-${totalLoss.toStringAsFixed(2)}'),
      ],
    );
  }

  static pw.Widget _buildSummaryItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
        ),
        pw.Text(value, style: const pw.TextStyle(fontSize: 12)),
      ],
    );
  }

  static pw.Widget _buildTable(InventoryAuditEntity audit) {
    return pw.TableHelper.fromTextArray(
      headers: ['Producto', 'Variante', 'Esperado', 'Contado', 'Diferencia'],
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1),
      },
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
      ),
      cellAlignment: pw.Alignment.centerLeft,
      data: audit.items.map((item) {
        final diff = item.difference;
        final diffStr = diff > 0
            ? '+${diff.toStringAsFixed(2)}'
            : diff.toStringAsFixed(2);

        return [
          item.productName ?? 'Unknown',
          item.variantName ?? '-',
          item.expectedQuantity.toStringAsFixed(2),
          item.countedQuantity.toStringAsFixed(2),
          diffStr,
        ];
      }).toList(),
    );
  }

  static pw.Widget _buildFooter(InventoryAuditEntity audit) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Divider(),
        pw.SizedBox(height: 20),
        pw.Text('Firma del Auditor', style: const pw.TextStyle(fontSize: 12)),
        pw.SizedBox(height: 40),
        pw.Container(width: 200, height: 1, color: PdfColors.black),
      ],
    );
  }
}
