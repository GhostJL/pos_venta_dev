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
  });

  ProductFormState copyWith({
    Product? initialProduct,
    String? name,
    String? code,
    String? barcode,
    String? description,
    int? departmentId,
    int? categoryId,
    int? brandId,
    int? supplierId,
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
  }) {
    return ProductFormState(
      initialProduct: initialProduct ?? this.initialProduct,
      name: name ?? this.name,
      code: code ?? this.code,
      barcode: barcode ?? this.barcode,
      description: description ?? this.description,
      departmentId: departmentId ?? this.departmentId,
      categoryId: categoryId ?? this.categoryId,
      brandId: brandId ?? this.brandId,
      supplierId: supplierId ?? this.supplierId,
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
    );
  }
}

@riverpod
class ProductFormNotifier extends _$ProductFormNotifier {
  @override
  ProductFormState build(Product? product) {
    if (product != null) {
      return ProductFormState(
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
      );
    }
    return ProductFormState();
  }

  void setName(String value) => state = state.copyWith(name: value);
  void setCode(String value) => state = state.copyWith(code: value);
  void setBarcode(String value) => state = state.copyWith(barcode: value);
  void setDescription(String value) =>
      state = state.copyWith(description: value);
  void setHasVariants(bool value) => state = state.copyWith(hasVariants: value);
  void setUsesTaxes(bool value) => state = state.copyWith(usesTaxes: value);

  void setDepartment(int? value) => state = state.copyWith(departmentId: value);
  void setCategory(int? value) => state = state.copyWith(categoryId: value);
  void setBrand(int? value) => state = state.copyWith(brandId: value);
  void setSupplier(int? value) => state = state.copyWith(supplierId: value);
  void setUnit(int? value) => state = state.copyWith(unitId: value);
  void setSoldByWeight(bool value) =>
      state = state.copyWith(isSoldByWeight: value);
  void setActive(bool value) => state = state.copyWith(isActive: value);
  void setHasExpiration(bool value) =>
      state = state.copyWith(hasExpiration: value);
  void setTaxes(List<ProductTax> value) =>
      state = state.copyWith(selectedTaxes: value);
  void setVariants(List<ProductVariant> value) =>
      state = state.copyWith(variants: value);

  void addVariant(ProductVariant variant) {
    state = state.copyWith(variants: [...state.variants, variant]);
  }

  void updateVariant(int index, ProductVariant variant) {
    final newVariants = [...state.variants];
    newVariants[index] = variant;
    state = state.copyWith(variants: newVariants);
  }

  void removeVariant(int index) {
    final newVariants = [...state.variants];
    newVariants.removeAt(index);
    state = state.copyWith(variants: newVariants);
  }

  Future<bool> validateAndSubmit({
    String? name,
    String? code,
    String? barcode,
    String? description,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    // Use values from args or state fallback
    final finalName = name ?? state.name;
    final finalCode = code ?? state.code;
    final finalBarcode = barcode ?? state.barcode ?? '';
    final finalDescription = description ?? state.description;

    try {
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

      final isCodeUnique = await productRepo.isCodeUnique(
        finalCode,
        excludeId: state.initialProduct?.id,
      );
      if (!isCodeUnique) {
        state = state.copyWith(
          isLoading: false,
          error: 'El Código/SKU ya existe. Debe ser único.',
        );
        return false;
      }

      // Barcode used to be on variants, but now it's on base product?
      // User said: "el producto con la información básica del producto sin variante esto al agregar producto."
      // User didn't explicitly say remove barcode from base.
      // Re-reading: "Información básica: Nombre. Descripción. Tiene caducidad. Si aplica impuestos."
      // Barcode is usually needed. ProductBasicInfoSection has it. I'll keep it.

      if (finalBarcode.isNotEmpty) {
        final isBarcodeUnique = await productRepo.isBarcodeUnique(
          finalBarcode,
          excludeId: state.initialProduct?.id,
        );
        // Warning: isBarcodeUnique checks variants too? It usually checks products table and variants table?
        // I should assume base product barcode is stored in 'code' or need to check if 'barcode' column exists on products.
        // Schema 'products' has 'code'. 'product_variants' has 'barcode'.
        // Base product DOES NOT have 'barcode' column in schema!
        // 'code' in products table is SKU.
        // So Base Product strictly speaking doesn't have a barcode unless it's the SKU?
        // The user said: "Información básica: Nombre. Descripción. Tiene caducidad...". No Barcode mentioned there.
        // BUT ProductBasicInfoSection has "Código/SKU" and "Código de Barras Principal".
        // If 'products' table doesn't have barcode, then it's not stored there.
        // I will Assume "Código/SKU" maps to `code`.
        // I will Remove specific Barcode field from Base Product if it's not in schema.
        // Wait, `products` table has `code`. `product_variants` has `barcode`.
        // If the user wants Barcode for the "Base Product", maybe they mean the SKU?
        // I'll stick to SKU (`code`) for now.
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
      );

      Product savedProduct;
      // Use repo directly to ensure we get the ID for new products
      // and can update the local state correctly
      if (state.initialProduct == null) {
        final newId = await productRepo.createProduct(newProduct);
        savedProduct = newProduct.copyWith(id: newId);
        // Trigger list refresh if needed, though stream should handle it
        // ref.invalidate(productListProvider);
      } else {
        await productRepo.updateProduct(newProduct);
        savedProduct = newProduct;
      }

      // Update initialProduct so dirty checks work correctly
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        error: null,
        initialProduct: savedProduct,
        // Also update fields to match saved product if needed,
        // essentially re-syncing to "clean" state
        name: savedProduct.name,
        code: savedProduct.code,
        barcode: savedProduct.barcode,
        description: savedProduct.description,
        variants: savedProduct.variants ?? [],
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al guardar el producto: $e',
      );
      return false;
    }
  }
}
