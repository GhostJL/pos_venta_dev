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
      'Codigo (Requerido)',
      'Nombre (Requerido)',
      'Descripcion',
      'Costo (Requerido)',
      'Precio Venta (Requerido)',
      'Precio Mayorista',
      'Stock',
      'Stock Minimo',
      'Stock Maximo',
      'Se Vende Por Peso (1=Si, 0=No)',
      'Codigo Barras',
      'Nombre Variante',
      'Nombre Departamento',
      'Nombre Categoria',
      'Codigo Unidad (pz, kg, lt)',
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
      '0',
      '123456789',
      'Estándar',
      'General',
      'General',
      'pz',
    ]);

    return const ListToCsvConverter().convert(rows);
  }

  (List<Product>, List<String>) validateAndMap(
    List<List<dynamic>> rows,
    Map<String, int> departmentMap, // Key: Name (Lowercased)
    Map<String, int> categoryMap, // Key: Name (Lowercased)
    Map<String, int> unitMap, { // Key: Code
    required int defaultDepartmentId,
    required int defaultCategoryId,
    required int defaultUnitId,
    Set<String> existingCodes = const {},
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

        // Validar columnas mínimas (las primeras 5 son esenciales)
        if (mainRow.length < 5) {
          errors.add(
            "Fila $rowIndex (Producto '$code'): Faltan columnas requeridas.",
          );
          return;
        }

        if (existingCodes.contains(code.toLowerCase())) {
          errors.add(
            "Producto '$code': Ya existe en el catálogo. Usa un código diferente.",
          );
          return;
        }

        final name = mainRow[1].toString().trim();
        final description = mainRow[2].toString().trim();

        // Opcionales con índice seguro
        String getValue(int index) =>
            mainRow.length > index ? mainRow[index].toString().trim() : '';

        // Indices ajustados:
        // 0: Code, 1: Name, 2: Desc, 3: Cost, 4: Price
        // 5: WholesalePrice, 6: Stock, 7: StockMin, 8: StockMax, 9: IsSoldByWeight
        // 10: Barcode, 11: VariantName, 12: DeptName, 13: CatName, 14: UnitCode

        final isWeightStr = getValue(9);
        final deptName = getValue(12);
        final catName = getValue(13);
        final unitCode = getValue(14);

        // IDs
        // Map keys are expected to be lowercased for case-insensitive matching
        final departmentId =
            (deptName.isNotEmpty &&
                departmentMap.containsKey(deptName.toLowerCase()))
            ? departmentMap[deptName.toLowerCase()]!
            : defaultDepartmentId;

        final categoryId =
            (catName.isNotEmpty &&
                categoryMap.containsKey(catName.toLowerCase()))
            ? categoryMap[catName.toLowerCase()]!
            : defaultCategoryId;

        final unitId = (unitCode.isNotEmpty && unitMap.containsKey(unitCode))
            ? unitMap[unitCode]!
            : defaultUnitId;

        // Boolean 1/0
        final isSoldByWeight = isWeightStr == '1';

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
              // stock: stockVal, // Removed
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
