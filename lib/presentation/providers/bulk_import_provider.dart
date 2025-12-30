import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/core/services/bulk_import_service.dart';
import 'package:posventa/domain/entities/category.dart';
import 'package:posventa/domain/entities/department.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/presentation/providers/category_providers.dart';
import 'package:posventa/domain/entities/warehouse.dart';
import 'package:posventa/presentation/providers/providers.dart';

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

      // Fetch dependencies
      var departments = await ref
          .read(departmentRepositoryProvider)
          .getAllDepartments();
      var categories = await ref
          .read(categoryRepositoryProvider)
          .getAllCategories();
      final units = await ref
          .read(unitOfMeasureRepositoryProvider)
          .getAllUnits();

      // Ensure at least one Department exists (General)
      int defaultDeptId;
      if (departments.isEmpty) {
        // Create default
        final newDept = Department(name: 'General', code: 'GEN');
        defaultDeptId = await ref
            .read(departmentRepositoryProvider)
            .createDepartment(newDept);
        // Refresh list
        departments = await ref
            .read(departmentRepositoryProvider)
            .getAllDepartments();
      } else {
        // Try finding one with ID 1, else use first
        final found = departments.where((d) => d.id == 1);
        if (found.isNotEmpty) {
          defaultDeptId = 1;
        } else {
          defaultDeptId = departments.first.id!;
        }
      }

      // Ensure at least one Category exists (General)
      int defaultCatId;
      if (categories.isEmpty) {
        // Create default
        final newCat = Category(
          name: 'General',
          code: 'GEN',
          departmentId: defaultDeptId,
        );
        defaultCatId = await ref
            .read(categoryRepositoryProvider)
            .createCategory(newCat);
        // Refresh list
        categories = await ref
            .read(categoryRepositoryProvider)
            .getAllCategories();
      } else {
        final found = categories.where((c) => c.id == 1);
        if (found.isNotEmpty) {
          defaultCatId = 1;
        } else {
          defaultCatId = categories.first.id!;
        }
      }

      // Ensure at least one Unit exists
      if (units.isEmpty) {
        throw "No units of measure found in database. Please initialize the database with seeds.";
      }
      int defaultUnitId;
      final foundUnit = units.where((u) => u.id == 1);
      if (foundUnit.isNotEmpty) {
        defaultUnitId = 1;
      } else {
        defaultUnitId = units.first.id!;
      }

      final departmentMap = {for (var d in departments) d.code: d.id!};
      final categoryMap = {for (var c in categories) c.code: c.id!};
      final unitMap = {for (var u in units) u.code: u.id!};

      final (validProducts, errors) = service.validateAndMap(
        rawData,
        departmentMap,
        categoryMap,
        unitMap,
        defaultDepartmentId: defaultDeptId,
        defaultCategoryId: defaultCatId,
        defaultUnitId: defaultUnitId,
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
