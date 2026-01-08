import 'dart:io';
import 'dart:math';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/core/services/bulk_import_service.dart';
import 'package:posventa/domain/entities/category.dart';
import 'package:posventa/domain/entities/department.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/presentation/providers/category_providers.dart';
import 'package:posventa/domain/entities/warehouse.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:posventa/presentation/providers/product_provider.dart';

part 'bulk_import_provider.g.dart';

class BulkImportState {
  final File? selectedFile;
  final List<Product> validProducts;
  final List<String> errors;
  final bool isLoading;
  final bool isUploading;
  final bool isSuccess;
  final String? errorMessage;

  BulkImportState({
    this.selectedFile,
    this.validProducts = const [],
    this.errors = const [],
    this.isLoading = false,
    this.isUploading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  BulkImportState copyWith({
    File? selectedFile,
    List<Product>? validProducts,
    List<String>? errors,
    bool? isLoading,
    bool? isUploading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return BulkImportState(
      selectedFile: selectedFile ?? this.selectedFile,
      validProducts: validProducts ?? this.validProducts,
      errors: errors ?? this.errors,
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
    );
  }
}

final bulkImportServiceProvider = Provider((ref) => BulkImportService());

@riverpod
class BulkImport extends _$BulkImport {
  @override
  BulkImportState build() {
    return BulkImportState();
  }

  Future<void> pickFile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final service = ref.read(bulkImportServiceProvider);
      final file = await service.pickCsvFile();

      if (file != null) {
        state = state.copyWith(selectedFile: file, isLoading: true);
        await validateFile(file);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Error picking file: $e",
      );
    }
  }

  Future<void> validateFile(File file) async {
    try {
      final service = ref.read(bulkImportServiceProvider);
      final rawData = await service.parseCsv(file);

      // Omit header if exists
      int startIndex = 0;
      if (rawData.isNotEmpty && rawData.length > 1) {
        startIndex = 1;
      }

      // 1. Extract Unique Names from CSV
      final Set<String> deptNames = {};
      final Set<String> catNames = {};

      for (int i = startIndex; i < rawData.length; i++) {
        final row = rawData[i];
        if (row.isEmpty || row[0].toString().trim().isEmpty) continue;

        // Assuming fixed indices based on new template:
        // 12: DeptName, 13: CatName
        if (row.length > 12) {
          final dName = row[12].toString().trim();
          if (dName.isNotEmpty) deptNames.add(dName);
        }
        if (row.length > 13) {
          final cName = row[13].toString().trim();
          if (cName.isNotEmpty) catNames.add(cName);
        }
      }

      // 2. Fetch existing Catalog
      var departments = await ref
          .read(departmentRepositoryProvider)
          .getAllDepartments();
      var categories = await ref
          .read(categoryRepositoryProvider)
          .getAllCategories();

      // 3. Auto-Create Missing Departments
      bool deptChanged = false;
      for (final name in deptNames) {
        // Case-insensitive check
        final exists = departments.any(
          (d) => d.name.toLowerCase() == name.toLowerCase(),
        );
        if (!exists) {
          // Create new
          // Generate a simple code: DEPT-{RANDOM/TIMESTAMP} or just prefix
          final code =
              'DEP-${DateTime.now().millisecondsSinceEpoch % 10000}-${name.substring(0, min(3, name.length)).toUpperCase()}';
          final newDept = Department(name: name, code: code);
          await ref
              .read(departmentRepositoryProvider)
              .createDepartment(newDept);
          deptChanged = true;
        }
      }
      // Refresh if changed
      if (deptChanged) {
        departments = await ref
            .read(departmentRepositoryProvider)
            .getAllDepartments();
      }

      // Ensure default department (General)
      int defaultDeptId;
      if (departments.isEmpty) {
        final newDept = Department(name: 'General', code: 'GEN');
        defaultDeptId = await ref
            .read(departmentRepositoryProvider)
            .createDepartment(newDept);
        departments = await ref
            .read(departmentRepositoryProvider)
            .getAllDepartments();
      } else {
        // Try finding "General" or use first
        final found = departments.where(
          (d) => d.name.toLowerCase() == 'general',
        );
        if (found.isNotEmpty) {
          defaultDeptId = found.first.id!;
        } else {
          defaultDeptId = departments.first.id!;
        }
      }

      // 4. Auto-Create Missing Categories
      // Note: Categories need a parent Dept ID. For simplicity in bulk import generic creation,
      // we assign them to the Default Dept unless we want complex logic.
      // Let's assign new categories to the Default Dept ID to be safe and simple.
      bool catChanged = false;
      for (final name in catNames) {
        final exists = categories.any(
          (c) => c.name.toLowerCase() == name.toLowerCase(),
        );
        if (!exists) {
          final code =
              'CAT-${DateTime.now().millisecondsSinceEpoch % 10000}-${name.substring(0, min(3, name.length)).toUpperCase()}';
          final newCat = Category(
            name: name,
            code: code,
            departmentId: defaultDeptId, // Link to default dept
          );
          await ref.read(categoryRepositoryProvider).createCategory(newCat);
          catChanged = true;
        }
      }
      if (catChanged) {
        categories = await ref
            .read(categoryRepositoryProvider)
            .getAllCategories();
      }

      // Ensure default category
      int defaultCatId;
      if (categories.isEmpty) {
        final newCat = Category(
          name: 'General',
          code: 'GEN',
          departmentId: defaultDeptId,
        );
        defaultCatId = await ref
            .read(categoryRepositoryProvider)
            .createCategory(newCat);
        categories = await ref
            .read(categoryRepositoryProvider)
            .getAllCategories();
      } else {
        final found = categories.where(
          (c) => c.name.toLowerCase() == 'general',
        );
        if (found.isNotEmpty) {
          defaultCatId = found.first.id!;
        } else {
          defaultCatId = categories.first.id!;
        }
      }

      // 5. Units
      final units = await ref
          .read(unitOfMeasureRepositoryProvider)
          .getAllUnits();
      if (units.isEmpty) {
        throw "No units of measure found in database.";
      }
      int defaultUnitId = units.first.id!; // Fallback

      // 6. Check for Duplicate Codes
      final existingProducts = await ref
          .read(productRepositoryProvider)
          .getProducts();
      final Set<String> existingCodes = {};

      existingProducts.fold((failure) {}, (products) {
        for (var p in products) {
          existingCodes.add(p.code.toLowerCase());
        }
      });

      // 7. Build Maps (Key = Lowercase Name for Dept/Cat, Code for Unit)
      final departmentMap = {
        for (var d in departments) d.name.toLowerCase(): d.id!,
      };
      final categoryMap = {
        for (var c in categories) c.name.toLowerCase(): c.id!,
      };
      final unitMap = {for (var u in units) u.code: u.id!};

      final (validProducts, errors) = service.validateAndMap(
        rawData,
        departmentMap,
        categoryMap,
        unitMap,
        defaultDepartmentId: defaultDeptId,
        defaultCategoryId: defaultCatId,
        defaultUnitId: defaultUnitId,
        existingCodes: existingCodes,
      );

      state = state.copyWith(
        validProducts: validProducts,
        errors: errors,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Error validating file: $e",
      );
      print(e);
    }
  }

  Future<void> uploadProducts() async {
    if (state.validProducts.isEmpty) return;

    state = state.copyWith(isUploading: true, errorMessage: null);

    try {
      final repository = ref.read(productRepositoryProvider);

      // Fetch warehouse to use as default
      final warehouses = await ref
          .read(warehouseRepositoryProvider)
          .getAllWarehouses();

      int defaultWarehouseId;
      if (warehouses.isEmpty) {
        // Create default if none exists
        final newWarehouse = Warehouse(
          name: 'Almacén Principal',
          code: 'MAIN',
          isMain: true,
          isActive: true,
        );
        defaultWarehouseId = await ref
            .read(warehouseRepositoryProvider)
            .createWarehouse(newWarehouse);
      } else {
        // Use main warehouse or first available
        final mainWarehouse = warehouses.where((w) => w.isMain);
        if (mainWarehouse.isNotEmpty) {
          defaultWarehouseId = mainWarehouse.first.id!;
        } else {
          defaultWarehouseId = warehouses.first.id!;
        }
      }

      final result = await repository.batchCreateProducts(
        state.validProducts,
        defaultWarehouseId: defaultWarehouseId,
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            isUploading: false,
            errorMessage: failure.message,
          );
        },
        (_) {
          state = state.copyWith(
            isUploading: false,
            isSuccess: true,
            validProducts: [], // Clear
            selectedFile: null,
            errors: [],
          );
          // Invalidate product list to refresh UI
          ref.invalidate(productListProvider);
        },
      );
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: "Unexpected error: $e",
      );
    }
  }

  void clear() {
    state = BulkImportState();
  }
}
