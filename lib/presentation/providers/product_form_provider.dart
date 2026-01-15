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
import 'package:posventa/presentation/providers/auth_provider.dart';

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
  final List<String> additionalBarcodes;

  final bool showValidationErrors;
  final bool isModified;

  final bool isVariableProduct;

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
    this.additionalBarcodes = const [],
    this.hasVariants = false,
    this.usesTaxes = false,
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
    this.imageFile,
    this.photoUrl,
    this.showValidationErrors = false,
    this.isModified = false,
    this.isVariableProduct = false,
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
    bool clearUnitId = false,
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
    List<String>? additionalBarcodes,
    bool? showValidationErrors,
    bool? isModified,
    bool? isVariableProduct,
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
      unitId: clearUnitId ? null : (unitId ?? this.unitId),
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
      additionalBarcodes: additionalBarcodes ?? this.additionalBarcodes,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
      isModified: isModified ?? this.isModified,
      isVariableProduct: isVariableProduct ?? this.isVariableProduct,
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
        unitId: (product.variants?.isNotEmpty ?? false)
            ? product.variants!.first.unitId
            : null,
        isSoldByWeight: product.isSoldByWeight,
        isActive: product.isActive,
        hasExpiration: product.hasExpiration,
        selectedTaxes: List.from(product.productTaxes ?? []),
        variants: List.from(product.variants ?? []),
        hasVariants:
            (product.variants?.length ?? 0) > 1 ||
            ((product.variants?.isNotEmpty ?? false) &&
                product.variants!.first.variantName != 'Estándar'),
        isVariableProduct:
            (product.variants?.length ?? 0) > 1 ||
            ((product.variants?.isNotEmpty ?? false) &&
                product.variants!.first.variantName != 'Estándar'),
        usesTaxes: (product.productTaxes?.isNotEmpty ?? false),
        photoUrl: product.photoUrl,
        additionalBarcodes: (product.variants?.isNotEmpty ?? false)
            ? (product.variants!.first.additionalBarcodes ?? [])
            : [],
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
          unitId: (freshProduct.variants?.isNotEmpty ?? false)
              ? freshProduct.variants!.first.unitId
              : null,
          variants: List.from(freshProduct.variants ?? []),
          photoUrl: freshProduct.photoUrl,
          additionalBarcodes: (freshProduct.variants?.isNotEmpty ?? false)
              ? (freshProduct.variants!.first.additionalBarcodes ?? [])
              : [],
        );
        state = newState;
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
          s.imageFile != null ||
          (s.variants.isNotEmpty &&
              (s.variants.length > 1 ||
                  s.variants.first.variantName != 'Estándar'));
    }

    // Existing Product
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
    if (s.imageFile != null) return true;
    if (s.usesTaxes != initial.usesTaxes) return true;

    if (s.selectedTaxes.length != initial.selectedTaxes.length) return true;
    final initialTaxIds = initial.selectedTaxes.map((t) => t.taxRateId).toSet();
    final currentTaxIds = s.selectedTaxes.map((t) => t.taxRateId).toSet();
    if (!initialTaxIds.containsAll(currentTaxIds)) return true;

    if (s.additionalBarcodes.length != initial.additionalBarcodes.length) {
      return true;
    }
    if (!s.additionalBarcodes.every(
      (element) => initial.additionalBarcodes.contains(element),
    )) {
      return true;
    }

    if (s.variants.length != initial.variants.length) return true;

    // Deep compare variants
    for (int i = 0; i < s.variants.length; i++) {
      final v1 = s.variants[i];
      final v2 = initial.variants[i];

      if (v1.id != v2.id) return true;
      if (v1.productId != v2.productId) return true;
      if (v1.variantName != v2.variantName) return true;
      if (v1.barcode != v2.barcode) return true;
      if (v1.quantity != v2.quantity) return true;
      if (v1.priceCents != v2.priceCents) return true;
      if (v1.costPriceCents != v2.costPriceCents) return true;
      if (v1.wholesalePriceCents != v2.wholesalePriceCents) return true;
      if (v1.isActive != v2.isActive) return true;
      if (v1.isForSale != v2.isForSale) return true;
      if (v1.type != v2.type) return true;
      if (v1.linkedVariantId != v2.linkedVariantId) return true;
      if (v1.stock != v2.stock) return true;
      if (v1.stockMin != v2.stockMin) return true;
      if (v1.stockMax != v2.stockMax) return true;
      if (v1.conversionFactor != v2.conversionFactor) return true;
      if (v1.unitId != v2.unitId) return true;
      if (v1.isSoldByWeight != v2.isSoldByWeight) return true;
      if (v1.photoUrl != v2.photoUrl) return true;

      // Handle List<String>? equality for additionalBarcodes
      final list1 = v1.additionalBarcodes ?? [];
      final list2 = v2.additionalBarcodes ?? [];
      if (list1.length != list2.length) return true;
      if (!list1.every((item) => list2.contains(item))) return true;
    }

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

  void setVariableProduct(bool value) =>
      _updateModified(state.copyWith(isVariableProduct: value));
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
  void setSoldByWeight(bool value) =>
      _updateModified(state.copyWith(isSoldByWeight: value));
  void setActive(bool value) =>
      _updateModified(state.copyWith(isActive: value));
  void setHasExpiration(bool value) =>
      _updateModified(state.copyWith(hasExpiration: value));

  void setUnitId(int? value) => _updateModified(
    state.copyWith(unitId: value, clearUnitId: value == null),
  );

  void setTaxes(List<ProductTax> value) =>
      _updateModified(state.copyWith(selectedTaxes: value));

  void setVariants(List<ProductVariant> value) {
    bool isVariable = state.isVariableProduct;
    if (value.length > 1 ||
        (value.isNotEmpty && value.first.variantName != 'Estándar')) {
      isVariable = true;
    }
    _updateModified(
      state.copyWith(variants: value, isVariableProduct: isVariable),
    );
  }

  void pickImage(File file) {
    _updateModified(state.copyWith(imageFile: file, photoUrl: null));
  }

  void addAdditionalBarcode(String value) {
    if (value.isEmpty) return;
    if (state.additionalBarcodes.contains(value)) return;
    if (state.barcode == value) return;

    final newList = List<String>.from(state.additionalBarcodes)..add(value);
    _updateModified(state.copyWith(additionalBarcodes: newList));
  }

  void removeAdditionalBarcode(String value) {
    final newList = List<String>.from(state.additionalBarcodes)..remove(value);
    _updateModified(state.copyWith(additionalBarcodes: newList));
  }

  void removeImage() {
    _updateModified(state.copyWith(clearImageFile: true, clearPhotoUrl: true));
  }

  void addVariant(ProductVariant variant) {
    final newVariants = [...state.variants, variant];
    bool isVariable = state.isVariableProduct;
    if (newVariants.length > 1 ||
        (newVariants.isNotEmpty &&
            newVariants.first.variantName != 'Estándar')) {
      isVariable = true;
    }
    _updateModified(
      state.copyWith(variants: newVariants, isVariableProduct: isVariable),
    );
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

  void updateAllPrices(double price) {
    final priceCents = (price * 100).round();
    final updated = state.variants
        .map((v) => v.copyWith(priceCents: priceCents))
        .toList();
    _updateModified(state.copyWith(variants: updated));
  }

  void updateAllCosts(double cost) {
    final costCents = (cost * 100).round();
    final updated = state.variants
        .map((v) => v.copyWith(costPriceCents: costCents))
        .toList();
    _updateModified(state.copyWith(variants: updated));
  }

  void updateAllWholesalePrices(double price) {
    final priceCents = (price * 100).round();
    final updated = state.variants
        .map((v) => v.copyWith(wholesalePriceCents: priceCents))
        .toList();
    _updateModified(state.copyWith(variants: updated));
  }

  void updateAllStocks(double stock) {
    final updated = state.variants
        .map((v) => v.copyWith(stock: stock))
        .toList();
    _updateModified(state.copyWith(variants: updated));
  }

  void updateAllMinStocks(double stock) {
    final updated = state.variants
        .map((v) => v.copyWith(stockMin: stock))
        .toList();
    _updateModified(state.copyWith(variants: updated));
  }

  void updateAllMaxStocks(double stock) {
    final updated = state.variants
        .map((v) => v.copyWith(stockMax: stock))
        .toList();
    _updateModified(state.copyWith(variants: updated));
  }

  Future<bool> validateAndSubmit({
    String? name,
    String? code,
    String? barcode,
    String? description,
    double? price,
    double? cost,
    double? wholesale,
    double? stock,
    double? minStock,
    double? maxStock,
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

    // --- Handle Simple vs Variable Logic ---
    List<ProductVariant> finalVariants = [];
    if (state.isVariableProduct) {
      // Use existing variants list
      finalVariants = state.variants;
      if (finalVariants.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'Debe agregar al menos una variante.',
        );
        return false;
      }
    } else {
      // Simple Product: Create/Update Default Variant
      if (price == null || cost == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'El precio y costo son requeridos para productos simples.',
        );
        return false;
      }

      ProductVariant? existingDefault;
      if (state.variants.isNotEmpty) {
        existingDefault = state.variants.first;
      }

      // Default Variant Construction
      final defaultVariant = ProductVariant(
        id: existingDefault?.id,
        productId: state.initialProduct?.id ?? 0,
        variantName: 'Estándar',
        barcode: finalBarcode.isNotEmpty ? finalBarcode : finalCode,
        priceCents: (price * 100).round(),
        costPriceCents: (cost * 100).round(),
        wholesalePriceCents: wholesale != null
            ? (wholesale * 100).round()
            : null,
        stock: stock,
        stockMin: minStock,
        stockMax: maxStock,
        isForSale: true,
        isActive: state.isActive,
        unitId: state.unitId,
        isSoldByWeight: state.isSoldByWeight,
        additionalBarcodes: state.additionalBarcodes,
      );

      finalVariants = [defaultVariant];
    }

    List<ProductTax> finalProductTaxes = [];
    if (state.usesTaxes) {
      finalProductTaxes = state.selectedTaxes;
    } else {
      try {
        final taxRates = await ref.read(taxRateListProvider.future);
        TaxRate? exemptTax;

        try {
          exemptTax = taxRates.firstWhere(
            (t) => t.rate == 0 && t.name.toLowerCase().contains('exento'),
          );
        } catch (_) {
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
        // Ignore error
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
      isSoldByWeight: state.isSoldByWeight,
      productTaxes: finalProductTaxes,
      variants: finalVariants,
      isActive: state.isActive,
      hasExpiration: state.hasExpiration,
      photoUrl: savedPhotoUrl,
    );

    Product savedProduct = newProduct;
    String? saveError;

    if (state.initialProduct == null || state.initialProduct?.id == null) {
      final userId = ref.read(authProvider).user?.id;
      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Usuario no autenticado',
        );
        return false;
      }

      final createResult = await productRepo.createProduct(
        newProduct,
        userId: userId,
      );
      createResult.fold(
        (failure) => saveError = failure.message,
        (newId) => savedProduct = newProduct.copyWith(id: newId),
      );
    } else {
      final userId = ref.read(authProvider).user?.id;
      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Usuario no autenticado',
        );
        return false;
      }
      final updateResult = await productRepo.updateProduct(
        newProduct,
        userId: userId,
      );
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

    state = state.copyWith(
      isLoading: false,
      isSuccess: !silent,
      error: null,
      initialProduct: savedProduct,
      name: savedProduct.name,
      code: savedProduct.code,
      barcode: savedProduct.barcode,
      description: savedProduct.description,
      variants: savedProduct.variants ?? [],
      photoUrl: savedProduct.photoUrl,
      additionalBarcodes: (savedProduct.variants?.isNotEmpty ?? false)
          ? (savedProduct.variants!.first.additionalBarcodes ?? [])
          : [],
      clearImageFile: true,
    );

    return true;
  }
}
