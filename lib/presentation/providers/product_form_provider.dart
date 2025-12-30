import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_tax.dart';
import 'package:posventa/domain/entities/product_variant.dart';

import 'package:posventa/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posventa/domain/entities/tax_rate.dart';
import 'package:posventa/presentation/providers/tax_rate_provider.dart';

part 'product_form_provider.g.dart';

class ProductFormState {
  final Product? initialProduct;
  final String? name;
  final String? code;
  final String? barcode;
  final String? description;
  final int? departmentId;
  final int? categoryId;
  final int? brandId;
  final int? supplierId;
  final int? unitId;
  final bool isSoldByWeight;
  final bool isActive;
  final bool hasExpiration;
  final List<ProductTax> selectedTaxes;
  final List<ProductVariant> variants;
  final bool hasVariants;
  final bool usesTaxes;
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  final File? imageFile;
  final String? photoUrl;

  final bool showValidationErrors;
  final bool isModified;

  ProductFormState({
    this.initialProduct,
    this.name,
    this.code,
    this.barcode,
    this.description,
    this.departmentId,
    this.categoryId,
    this.brandId,
    this.supplierId,
    this.unitId,
    this.isSoldByWeight = false,
    this.isActive = true,
    this.hasExpiration = false,
    this.selectedTaxes = const [],
    this.variants = const [],
    this.hasVariants = false,
    this.usesTaxes = false,
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
    this.imageFile,
    this.photoUrl,
    this.showValidationErrors = false,
    this.isModified = false,
  });

  ProductFormState copyWith({
    Product? initialProduct,
    String? name,
    String? code,
    String? barcode,
    String? description,
    int? departmentId,
    bool clearDepartmentId = false,
    int? categoryId,
    bool clearCategoryId = false,
    int? brandId,
    bool clearBrandId = false,
    int? supplierId,
    bool clearSupplierId = false,
    int? unitId,
    bool? isSoldByWeight,
    bool? isActive,
    bool? hasExpiration,
    List<ProductTax>? selectedTaxes,
    List<ProductVariant>? variants,
    bool? hasVariants,
    bool? usesTaxes,
    bool? isLoading,
    String? error,
    bool? isSuccess,
    File? imageFile,
    bool clearImageFile = false,
    String? photoUrl,
    bool clearPhotoUrl = false,
    bool? showValidationErrors,
    bool? isModified,
  }) {
    return ProductFormState(
      initialProduct: initialProduct ?? this.initialProduct,
      name: name ?? this.name,
      code: code ?? this.code,
      barcode: barcode ?? this.barcode,
      description: description ?? this.description,
      departmentId: clearDepartmentId
          ? null
          : (departmentId ?? this.departmentId),
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      brandId: clearBrandId ? null : (brandId ?? this.brandId),
      supplierId: clearSupplierId ? null : (supplierId ?? this.supplierId),
      unitId: unitId ?? this.unitId,
      isSoldByWeight: isSoldByWeight ?? this.isSoldByWeight,
      isActive: isActive ?? this.isActive,
      hasExpiration: hasExpiration ?? this.hasExpiration,
      selectedTaxes: selectedTaxes ?? this.selectedTaxes,
      variants: variants ?? this.variants,
      hasVariants: hasVariants ?? this.hasVariants,
      usesTaxes: usesTaxes ?? this.usesTaxes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
      imageFile: clearImageFile ? null : (imageFile ?? this.imageFile),
      photoUrl: clearPhotoUrl ? null : (photoUrl ?? this.photoUrl),
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
      isModified: isModified ?? this.isModified,
    );
  }
}

@riverpod
class ProductFormNotifier extends _$ProductFormNotifier {
  late ProductFormState _initialState;

  @override
  ProductFormState build(Product? product) {
    if (product != null) {
      final state = ProductFormState(
        initialProduct: product,
        name: product.name,
        code: product.code,
        barcode: product.barcode,
        description: product.description,
        departmentId: product.departmentId,
        categoryId: product.categoryId,
        brandId: product.brandId,
        supplierId: product.supplierId,
        unitId: product.unitId,
        isSoldByWeight: product.isSoldByWeight,
        isActive: product.isActive,
        hasExpiration: product.hasExpiration,
        selectedTaxes: List.from(product.productTaxes ?? []),
        variants: List.from(product.variants ?? []),
        hasVariants:
            (product.variants?.length ?? 0) > 1 ||
            ((product.variants?.isNotEmpty ?? false) &&
                product.variants!.first.variantName != 'Estándar'),
        usesTaxes: (product.productTaxes?.isNotEmpty ?? false),
        photoUrl: product.photoUrl,
      );

      _initialState = state;

      if (product.id != null) {
        Future.microtask(() => refreshFromDb());
      }

      return state;
    }
    _initialState = ProductFormState();
    return _initialState;
  }

  Future<void> refreshFromDb() async {
    final id = state.initialProduct?.id;
    if (id == null) return;

    final productRepo = ref.read(productRepositoryProvider);
    final result = await productRepo.getProductById(id);

    result.fold((failure) {}, (freshProduct) {
      if (freshProduct != null) {
        final newState = state.copyWith(
          initialProduct: freshProduct,
          variants: List.from(freshProduct.variants ?? []),
          photoUrl: freshProduct.photoUrl,
          // We update initial state mostly to reset dirty check baseline if needed
          // But usually we respect current edits if the user has changed things?
          // For now, let's just update fields that shouldn't conflict heavily or are readonly-ish like variants which are saved separately
        );
        state = newState;
        // Note: We might NOT want to override _initialState here if we want to track changes against what was loaded at START of session vs current DB.
        // But typically "dirty" means diff from DB. So let's update _initialState too.
        _initialState = newState.copyWith(isModified: false);
        _updateModified(state);
      }
    });
  }

  void _updateModified(ProductFormState newState) {
    final isModified = _checkModified(newState);
    state = newState.copyWith(isModified: isModified);
  }

  bool _checkModified(ProductFormState s) {
    final initial = _initialState;
    if (s.initialProduct == null) {
      // New Product
      return (s.name?.isNotEmpty ?? false) ||
          (s.code?.isNotEmpty ?? false) ||
          (s.description?.isNotEmpty ?? false) ||
          s.departmentId != null ||
          s.categoryId != null ||
          s.brandId != null ||
          s.supplierId != null ||
          s.unitId != null ||
          s.imageFile != null ||
          (s.variants.isNotEmpty &&
              (s.variants.length > 1 ||
                  s.variants.first.variantName != 'Estándar'));
    }

    // Existing Product - Compare with initial (loaded from DB)
    if (s.name != initial.name) return true;
    if (s.code != initial.code) return true;
    if (s.barcode != initial.barcode) return true;
    if (s.description != initial.description) return true;
    if (s.departmentId != initial.departmentId) return true;
    if (s.categoryId != initial.categoryId) return true;
    if (s.brandId != initial.brandId) return true;
    if (s.supplierId != initial.supplierId) return true;
    if (s.unitId != initial.unitId) return true;
    if (s.isSoldByWeight != initial.isSoldByWeight) return true;
    if (s.isActive != initial.isActive) return true;
    if (s.hasExpiration != initial.hasExpiration) return true;
    if (s.imageFile != null) return true; // New image selected
    if (s.usesTaxes != initial.usesTaxes) return true;

    // Deep compare taxes
    if (s.selectedTaxes.length != initial.selectedTaxes.length) return true;
    final initialTaxIds = initial.selectedTaxes.map((t) => t.taxRateId).toSet();
    final currentTaxIds = s.selectedTaxes.map((t) => t.taxRateId).toSet();
    if (!initialTaxIds.containsAll(currentTaxIds)) return true;

    // Compare lists roughly for variants (usually handled by explicit edit form)
    if (s.variants.length != initial.variants.length) return true;

    // Deep compare variants if needed, but usually length check + explicit save action on variant form covers it.
    // However, if we added a variant in "waiting list", length will differ.

    return false;
  }

  void setName(String value) => _updateModified(state.copyWith(name: value));
  void setCode(String value) => _updateModified(state.copyWith(code: value));
  void setBarcode(String value) =>
      _updateModified(state.copyWith(barcode: value));
  void setDescription(String value) =>
      _updateModified(state.copyWith(description: value));
  void setHasVariants(bool value) =>
      _updateModified(state.copyWith(hasVariants: value));
  void setUsesTaxes(bool value) =>
      _updateModified(state.copyWith(usesTaxes: value));

  void setDepartment(int? value) => _updateModified(
    state.copyWith(departmentId: value, clearDepartmentId: value == null),
  );
  void setCategory(int? value) => _updateModified(
    state.copyWith(categoryId: value, clearCategoryId: value == null),
  );
  void setBrand(int? value) => _updateModified(
    state.copyWith(brandId: value, clearBrandId: value == null),
  );
  void setSupplier(int? value) => _updateModified(
    state.copyWith(supplierId: value, clearSupplierId: value == null),
  );
  void setUnit(int? value) => _updateModified(state.copyWith(unitId: value));
  void setSoldByWeight(bool value) =>
      _updateModified(state.copyWith(isSoldByWeight: value));
  void setActive(bool value) =>
      _updateModified(state.copyWith(isActive: value));
  void setHasExpiration(bool value) =>
      _updateModified(state.copyWith(hasExpiration: value));

  void setTaxes(List<ProductTax> value) =>
      _updateModified(state.copyWith(selectedTaxes: value));

  void setVariants(List<ProductVariant> value) =>
      _updateModified(state.copyWith(variants: value));

  void pickImage(File file) {
    _updateModified(state.copyWith(imageFile: file, photoUrl: null));
  }

  void removeImage() {
    _updateModified(state.copyWith(clearImageFile: true, clearPhotoUrl: true));
  }

  void addVariant(ProductVariant variant) {
    _updateModified(state.copyWith(variants: [...state.variants, variant]));
  }

  void updateVariant(int index, ProductVariant variant) {
    final newVariants = [...state.variants];
    newVariants[index] = variant;
    _updateModified(state.copyWith(variants: newVariants));
  }

  void removeVariant(int index) {
    final newVariants = [...state.variants];
    newVariants.removeAt(index);
    _updateModified(state.copyWith(variants: newVariants));
  }

  Future<bool> validateAndSubmit({
    String? name,
    String? code,
    String? barcode,
    String? description,
    bool silent = false,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    // Use values from args or state fallback
    final finalName = name ?? state.name;
    final finalCode = code ?? state.code;
    final finalBarcode = barcode ?? state.barcode ?? '';
    final finalDescription = description ?? state.description;

    if (finalName == null || finalName.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        error: 'El nombre del producto es requerido.',
      );
      return false;
    }
    if (finalCode == null || finalCode.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        error: 'El código/SKU del producto es requerido.',
      );
      return false;
    }

    final productRepo = ref.read(productRepositoryProvider);

    // Validation: If taxes are enabled, at least one must be selected
    if (state.usesTaxes && state.selectedTaxes.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        error:
            'Debe seleccionar al menos un impuesto si los impuestos están habilitados.',
      );
      return false;
    }

    if (state.departmentId == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Debe seleccionar un Departamento.',
      );
      return false;
    }

    if (state.categoryId == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Debe seleccionar una Categoría.',
      );
      return false;
    }

    if (state.unitId == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Debe seleccionar una Unidad de medida.',
      );
      return false;
    }

    final isCodeUniqueResult = await productRepo.isCodeUnique(
      finalCode,
      excludeId: state.initialProduct?.id,
    );

    bool isCodeUnique = true;
    String? dbError;

    isCodeUniqueResult.fold(
      (failure) {
        isCodeUnique = false;
        dbError = failure.message;
      },
      (unique) {
        isCodeUnique = unique;
      },
    );

    if (dbError != null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error validando código: $dbError',
      );
      return false;
    }

    if (!isCodeUnique) {
      state = state.copyWith(
        isLoading: false,
        error: 'El Código/SKU ya existe. Debe ser único.',
      );
      return false;
    }

    if (finalBarcode.isNotEmpty) {
      final isBarcodeUniqueResult = await productRepo.isBarcodeUnique(
        finalBarcode,
        excludeId: state.initialProduct?.id,
      );

      bool isBarcodeUnique = true;

      isBarcodeUniqueResult.fold(
        (failure) {
          isBarcodeUnique = false;
          dbError = failure.message;
        },
        (unique) {
          isBarcodeUnique = unique;
        },
      );

      if (dbError != null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Error validando código de barras: $dbError',
        );
        return false;
      }
    }

    List<ProductTax> finalProductTaxes = [];
    if (state.usesTaxes) {
      finalProductTaxes = state.selectedTaxes;
    } else {
      // Search for Exempt tax (Rate 0)
      try {
        final taxRates = await ref.read(taxRateListProvider.future);
        TaxRate? exemptTax;

        // Try to find by name "exento" and rate 0
        try {
          exemptTax = taxRates.firstWhere(
            (t) => t.rate == 0 && t.name.toLowerCase().contains('exento'),
          );
        } catch (_) {
          // Fallback to any rate 0
          try {
            exemptTax = taxRates.firstWhere((t) => t.rate == 0);
          } catch (__) {
            // No exempt tax found
          }
        }

        if (exemptTax != null) {
          finalProductTaxes = [
            ProductTax(taxRateId: exemptTax.id!, applyOrder: 1),
          ];
        }
      } catch (e) {
        // Ignore error, just proceed without taxes
      }
    }

    // Handle Image Saving
    String? savedPhotoUrl = state.photoUrl;
    if (state.imageFile != null) {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${path.basename(state.imageFile!.path)}';
        final savedImage = await state.imageFile!.copy(
          '${appDir.path}/$fileName',
        );
        savedPhotoUrl = savedImage.path;
      } catch (e) {
        // Continue
      }
    }

    final newProduct = Product(
      id: state.initialProduct?.id,
      name: finalName,
      code: finalCode,
      description: finalDescription,
      departmentId: state.departmentId!,
      categoryId: state.categoryId!,
      brandId: state.brandId,
      supplierId: state.supplierId,
      unitId: state.unitId!,
      isSoldByWeight: state.isSoldByWeight,
      productTaxes: finalProductTaxes,
      variants: state.variants,
      isActive: state.isActive,
      hasExpiration: state.hasExpiration,
      photoUrl: savedPhotoUrl,
    );

    Product savedProduct = newProduct; // Placeholder init
    String? saveError;

    // Use repo directly to ensure we get the ID for new products
    // and can update the local state correctly
    if (state.initialProduct == null) {
      final createResult = await productRepo.createProduct(newProduct);
      createResult.fold(
        (failure) => saveError = failure.message,
        (newId) => savedProduct = newProduct.copyWith(id: newId),
      );
    } else {
      final updateResult = await productRepo.updateProduct(newProduct);
      updateResult.fold(
        (failure) => saveError = failure.message,
        (_) => savedProduct = newProduct,
      );
    }

    if (saveError != null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al guardar el producto: $saveError',
      );
      return false;
    }

    // Update initialProduct so dirty checks work correctly
    state = state.copyWith(
      isLoading: false,
      isSuccess: !silent,
      error: null,
      initialProduct: savedProduct,
      // Also update fields to match saved product if needed,
      // essentially re-syncing to "clean" state
      name: savedProduct.name,
      code: savedProduct.code,
      barcode: savedProduct.barcode,
      description: savedProduct.description,
      variants: savedProduct.variants ?? [],
      photoUrl: savedProduct.photoUrl,
      clearImageFile: true,
    );

    return true;
  }
}
