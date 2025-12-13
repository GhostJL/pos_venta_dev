import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/product_tax.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/providers/product_provider.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'product_form_provider.g.dart';

class ProductFormState {
  final Product? initialProduct;
  final int? departmentId;
  final int? categoryId;
  final int? brandId;
  final int? supplierId;
  final int? unitId;
  final bool isSoldByWeight;
  final bool isActive;
  final List<ProductTax> selectedTaxes;
  final List<ProductVariant> variants;
  final bool hasVariants;
  final bool usesTaxes;
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  ProductFormState({
    this.initialProduct,
    this.departmentId,
    this.categoryId,
    this.brandId,
    this.supplierId,
    this.unitId,
    this.isSoldByWeight = false,
    this.isActive = true,
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
    int? departmentId,
    int? categoryId,
    int? brandId,
    int? supplierId,
    int? unitId,
    bool? isSoldByWeight,
    bool? isActive,
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
      departmentId: departmentId ?? this.departmentId,
      categoryId: categoryId ?? this.categoryId,
      brandId: brandId ?? this.brandId,
      supplierId: supplierId ?? this.supplierId,
      unitId: unitId ?? this.unitId,
      isSoldByWeight: isSoldByWeight ?? this.isSoldByWeight,
      isActive: isActive ?? this.isActive,
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
        departmentId: product.departmentId,
        categoryId: product.categoryId,
        brandId: product.brandId,
        supplierId: product.supplierId,
        unitId: product.unitId,
        isSoldByWeight: product.isSoldByWeight,
        isActive: product.isActive,
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
    required String name,
    required String code,
    required String barcode,
    required String description,
    required double costPrice,
    required double salePrice,
    required double? wholesalePrice,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      final productRepo = ref.read(productRepositoryProvider);

      final isCodeUnique = await productRepo.isCodeUnique(
        code,
        excludeId: state.initialProduct?.id,
      );
      if (!isCodeUnique) {
        state = state.copyWith(
          isLoading: false,
          error: 'El Código/SKU ya existe. Debe ser único.',
        );
        return false;
      }

      List<ProductVariant> finalVariants = [];

      if (!state.hasVariants) {
        if (salePrice <= costPrice) {
          state = state.copyWith(
            isLoading: false,
            error: 'El precio de venta debe ser mayor que el precio de costo.',
          );
          return false;
        }

        if (barcode.isEmpty) {
          state = state.copyWith(
            isLoading: false,
            error: 'El Código de Barras es requerido.',
          );
          return false;
        }

        final isBarcodeUnique = await productRepo.isBarcodeUnique(
          barcode,
          excludeId: state.initialProduct?.id,
        );
        if (!isBarcodeUnique) {
          state = state.copyWith(
            isLoading: false,
            error: 'El Código de Barras ya existe. Debe ser único.',
          );
          return false;
        }

        int? variantId;
        if (state.variants.isNotEmpty) {
          variantId = state.variants.first.id;
        }

        final mainVariant = ProductVariant(
          id: variantId,
          productId: state.initialProduct?.id ?? 0,
          variantName: 'Estándar',
          quantity: 1.0,
          priceCents: (salePrice * 100).toInt(),
          costPriceCents: (costPrice * 100).toInt(),
          wholesalePriceCents: wholesalePrice != null
              ? (wholesalePrice * 100).toInt()
              : null,
          barcode: barcode,
          isForSale: true,
          isActive: true,
        );
        finalVariants.add(mainVariant);
      } else {
        if (state.variants.isEmpty) {
          state = state.copyWith(
            isLoading: false,
            error: 'Debe agregar al menos una variante.',
          );
          return false;
        }

        final variantBarcodes = <String>{};
        for (int i = 0; i < state.variants.length; i++) {
          final v = state.variants[i];
          final vBarcode = v.barcode;

          if (v.priceCents <= v.costPriceCents) {
            state = state.copyWith(
              isLoading: false,
              error:
                  'La variante "${v.variantName}" tiene un precio de venta menor o igual al costo.',
            );
            return false;
          }

          if (vBarcode != null && vBarcode.isNotEmpty) {
            if (variantBarcodes.contains(vBarcode)) {
              state = state.copyWith(
                isLoading: false,
                error: 'Código de barras duplicado en variantes: $vBarcode',
              );
              return false;
            }
            variantBarcodes.add(vBarcode);

            final isUnique = await productRepo.isBarcodeUnique(
              vBarcode,
              excludeVariantId: v.id,
            );
            if (!isUnique) {
              state = state.copyWith(
                isLoading: false,
                error:
                    'El código de barras $vBarcode (Variante: ${v.variantName}) ya existe en el sistema.',
              );
              return false;
            }
          }
        }
        finalVariants = List.from(state.variants);
      }

      final newProduct = Product(
        id: state.initialProduct?.id,
        name: name,
        code: code,
        description: description,
        departmentId: state.departmentId!,
        categoryId: state.categoryId!,
        brandId: state.brandId,
        supplierId: state.supplierId,
        unitId: state.unitId!,
        isSoldByWeight: state.isSoldByWeight,
        productTaxes: state.usesTaxes ? state.selectedTaxes : [],
        variants: finalVariants,
        isActive: state.isActive,
      );

      if (state.initialProduct == null) {
        await ref.read(productListProvider.notifier).addProduct(newProduct);
      } else {
        await ref.read(productListProvider.notifier).updateProduct(newProduct);
      }

      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
