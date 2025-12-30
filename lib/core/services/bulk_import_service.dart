import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_variant.dart';

class BulkImportService {
  Future<File?> pickCsvFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  Future<List<List<dynamic>>> parseCsv(File file) async {
    final input = await file.readAsString();
    final fields = const CsvToListConverter().convert(input);
    return fields;
  }

  /// Validates and maps CSV rows to Product entities.
  /// Returns a tuple containing (`List<Product>` validProducts, `List<String>` errors)
  ///
  /// Expected CSV Format:
  /// Code, Name, Description, DepartmentCode, CategoryCode, UnitCode, CostPrice, SalePrice, Stock, Barcode, VariantName (Optional)
  /// Genera una plantilla CSV para importación de productos (Encabezados en Español)
  String getTemplateCsv() {
    final List<List<dynamic>> rows = [];
    // Encabezados
    rows.add([
      'Codigo',
      'Nombre',
      'Descripcion',
      'Costo',
      'Precio Venta',
      'Precio Mayorista (Opcional)',
      'Stock (Opcional)',
      'Stock Minimo (Opcional)',
      'Stock Maximo (Opcional)',
      'Se Vende Por Peso (Si/No)',
      'Codigo Barras (Opcional)',
      'Nombre Variante (Opcional)',
      'DeptCodigo (Opcional)',
      'CatCodigo (Opcional)',
      'UnidadCodigo (Opcional)',
    ]);

    // Fila de ejemplo
    rows.add([
      'PROD001',
      'Ejemplo Producto',
      'Descripción del producto',
      '50.00',
      '100.00',
      '90.00',
      '10',
      '5',
      '20',
      'No',
      '123456789',
      'Estándar',
      'GEN',
      'GEN',
      'pz',
    ]);

    return const ListToCsvConverter().convert(rows);
  }

  (List<Product>, List<String>) validateAndMap(
    List<List<dynamic>> rows,
    Map<String, int> departmentMap,
    Map<String, int> categoryMap,
    Map<String, int> unitMap, {
    required int defaultDepartmentId,
    required int defaultCategoryId,
    required int defaultUnitId,
  }) {
    final List<Product> validProducts = [];
    final List<String> errors = [];

    // Omitir encabezado si existe
    int startIndex = 0;
    if (rows.isNotEmpty && rows.length > 1) {
      // Asumimos siempre header por el template
      startIndex = 1;
    }

    final Map<String, List<List<dynamic>>> productRows = {};

    for (int i = startIndex; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty || row[0].toString().trim().isEmpty) {
        continue; // Saltar filas vacías
      }

      final productCode = row[0].toString().trim();
      productRows.putIfAbsent(productCode, () => []);
      productRows[productCode]!.add(row);
    }

    productRows.forEach((code, pRows) {
      try {
        final mainRow = pRows.first;
        final rowIndex = rows.indexOf(mainRow) + 1; // Para referencia visual

        // Validar columnas mínimas (las primeras 5 son esenciales: Codigo, Nombre, Desc, Costo, Precio)
        if (mainRow.length < 5) {
          errors.add(
            "Fila $rowIndex (Producto '$code'): Faltan columnas requeridas.",
          );
          return;
        }

        final name = mainRow[1].toString().trim();
        final description = mainRow[2].toString().trim();

        // Parsing de precios (columnas 3 y 4)
        final costStr = mainRow[3].toString().trim();
        final priceStr = mainRow[4].toString().trim();

        // Opcionales con índice seguro
        String getValue(int index) =>
            mainRow.length > index ? mainRow[index].toString().trim() : '';

        // Parsing de nuevos campos
        // Indices ajustados:
        // 0: Code, 1: Name, 2: Desc, 3: Cost, 4: Price
        // 5: WholesalePrice, 6: Stock, 7: StockMin, 8: StockMax, 9: IsSoldByWeight
        // 10: Barcode, 11: VariantName, 12: Dept, 13: Cat, 14: Unit

        final wholesalePriceStr = getValue(5);
        final stockStr = getValue(6);
        final stockMinStr = getValue(7);
        final stockMaxStr = getValue(8);
        final isWeightStr = getValue(9);
        final barcodeStr = getValue(10);
        final variantNameStr = getValue(11);
        final deptCode = getValue(12);
        final catCode = getValue(13);
        final unitCode = getValue(14);

        // IDs por defecto
        final departmentId =
            (deptCode.isNotEmpty && departmentMap.containsKey(deptCode))
            ? departmentMap[deptCode]!
            : defaultDepartmentId;
        final categoryId =
            (catCode.isNotEmpty && categoryMap.containsKey(catCode))
            ? categoryMap[catCode]!
            : defaultCategoryId;
        final unitId = (unitCode.isNotEmpty && unitMap.containsKey(unitCode))
            ? unitMap[unitCode]!
            : defaultUnitId;

        final isSoldByWeight =
            isWeightStr.toLowerCase() == 'si' ||
            isWeightStr.toLowerCase() == 'yes' ||
            isWeightStr.toLowerCase() == 'true' ||
            isWeightStr == '1';

        // Crear Variantes
        final List<ProductVariant> variants = [];

        for (final row in pRows) {
          // Re-map row values for variant specifics
          String getRowValue(int index) =>
              row.length > index ? row[index].toString().trim() : '';

          final costVal = double.tryParse(getRowValue(3)) ?? 0;
          final priceVal = double.tryParse(getRowValue(4)) ?? 0;
          final wholesaleVal = double.tryParse(getRowValue(5)) ?? 0;
          final stockVal = double.tryParse(getRowValue(6)) ?? 0;
          final stockMinVal = double.tryParse(getRowValue(7));
          final stockMaxVal = double.tryParse(getRowValue(8));
          final barcode = getRowValue(10);
          final varName = getRowValue(11).isEmpty
              ? 'Estándar'
              : getRowValue(11);

          variants.add(
            ProductVariant(
              id: null,
              productId: 0,
              variantName: varName,
              barcode: barcode.isEmpty ? null : barcode,
              costPriceCents: (costVal * 100).round(),
              priceCents: (priceVal * 100).round(),
              wholesalePriceCents: (wholesaleVal * 100).round(),
              stock: stockVal,
              stockMin: stockMinVal,
              stockMax: stockMaxVal,
              unitId: unitId,
              isSoldByWeight: isSoldByWeight,
              isForSale: true,
              isActive: true,
            ),
          );
        }

        final product = Product(
          id: null,
          code: code,
          name: name,
          description: description,
          departmentId: departmentId,
          categoryId: categoryId,
          brandId: null,
          supplierId: null,
          isSoldByWeight: isSoldByWeight,
          isActive: true,
          variants: variants,
        );

        validProducts.add(product);
      } catch (e) {
        errors.add("Producto '$code': Error inesperado - $e");
      }
    });

    return (validProducts, errors);
  }
}
