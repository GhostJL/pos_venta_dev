import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'variant_form_provider.g.dart';

class VariantFormState extends Equatable {
  final String name;
  final String quantity;
  final String price;
  final String cost;
  final String wholesalePrice;
  final String barcode;
  final bool isForSale;
  final bool isSaving;
  final String? barcodeError;
  final VariantType type;

  final int? linkedVariantId;
  final String conversionFactor;
  final String stockMin;
  final String stockMax;
  final int? unitId;
  final bool isSoldByWeight;
  final File? imageFile;
  final String? photoUrl;

  const VariantFormState({
    required this.name,
    required this.quantity,
    required this.price,
    required this.cost,
    required this.wholesalePrice,
    required this.barcode,
    required this.isForSale,
    this.isSaving = false,
    this.barcodeError,
    this.type = VariantType.sales,
    this.linkedVariantId,
    this.conversionFactor = '1',
    this.stockMin = '',
    this.stockMax = '',
    this.unitId,
    this.isSoldByWeight = false,
    this.imageFile,
    this.photoUrl,
  });

  factory VariantFormState.initial(
    ProductVariant? variant, {
    VariantType? initialType,
  }) {
    return VariantFormState(
      name: variant?.variantName ?? '',
      quantity: variant?.quantity.toString() ?? '1',
      price: variant != null
          ? (variant.priceCents / 100).toStringAsFixed(2)
          : '',
      cost: variant != null
          ? (variant.costPriceCents / 100).toStringAsFixed(2)
          : '',
      wholesalePrice: variant?.wholesalePriceCents != null
          ? (variant!.wholesalePriceCents! / 100).toStringAsFixed(2)
          : '',
      barcode: variant?.barcode ?? '',
      isForSale:
          variant?.isForSale ??
          (initialType == VariantType.sales || initialType == null),
      type: variant?.type ?? initialType ?? VariantType.sales,
      linkedVariantId: variant?.linkedVariantId,
      conversionFactor: variant?.conversionFactor.toString() ?? '1',
      stockMin: variant?.stockMin?.toString() ?? '',
      stockMax: variant?.stockMax?.toString() ?? '',
      unitId: variant?.unitId,
      isSoldByWeight: variant?.isSoldByWeight ?? false,
      photoUrl: variant?.photoUrl,
    );
  }

  VariantFormState copyWith({
    String? name,
    String? quantity,
    String? price,
    String? cost,
    String? wholesalePrice,
    String? barcode,
    bool? isForSale,
    bool? isSaving,
    String? barcodeError,
    VariantType? type,
    int? linkedVariantId,
    String? conversionFactor,
    String? stockMin,
    String? stockMax,
    int? unitId,
    bool? isSoldByWeight,
    File? imageFile,
    String? photoUrl,
  }) {
    return VariantFormState(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      barcode: barcode ?? this.barcode,
      isForSale: isForSale ?? this.isForSale,
      isSaving: isSaving ?? this.isSaving,
      barcodeError: barcodeError,
      type: type ?? this.type,
      linkedVariantId: linkedVariantId ?? this.linkedVariantId,
      conversionFactor: conversionFactor ?? this.conversionFactor,
      stockMin: stockMin ?? this.stockMin,
      stockMax: stockMax ?? this.stockMax,
      unitId: unitId ?? this.unitId,
      isSoldByWeight: isSoldByWeight ?? this.isSoldByWeight,
      imageFile: imageFile ?? this.imageFile,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  // Better copyWith for nullable fields
  VariantFormState copyWithNullable({
    String? name,
    String? quantity,
    String? price,
    String? cost,
    String? wholesalePrice,
    String? barcode,
    bool? isForSale,
    bool? isSaving,
    String? barcodeError,
    bool clearBarcodeError = false,
    VariantType? type,
    int? linkedVariantId,
    bool clearLinkedVariantId = false,
    String? conversionFactor,
    String? stockMin,
    String? stockMax,
    int? unitId,
    bool clearUnitId = false,
    bool? isSoldByWeight,
    File? imageFile,
    bool clearImageFile = false,
    String? photoUrl,
    bool clearPhotoUrl = false,
  }) {
    return VariantFormState(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      barcode: barcode ?? this.barcode,
      isForSale: isForSale ?? this.isForSale,
      isSaving: isSaving ?? this.isSaving,
      barcodeError: clearBarcodeError
          ? null
          : (barcodeError ?? this.barcodeError),
      type: type ?? this.type,
      linkedVariantId: clearLinkedVariantId
          ? null
          : (linkedVariantId ?? this.linkedVariantId),
      conversionFactor: conversionFactor ?? this.conversionFactor,
      stockMin: stockMin ?? this.stockMin,
      stockMax: stockMax ?? this.stockMax,
      unitId: clearUnitId ? null : (unitId ?? this.unitId),
      isSoldByWeight: isSoldByWeight ?? this.isSoldByWeight,
      imageFile: clearImageFile ? null : (imageFile ?? this.imageFile),
      photoUrl: clearPhotoUrl ? null : (photoUrl ?? this.photoUrl),
    );
  }

  @override
  List<Object?> get props => [
    name,
    quantity,
    price,
    cost,
    wholesalePrice,
    barcode,
    isForSale,
    isSaving,
    barcodeError,
    type,
    linkedVariantId,
    conversionFactor,
    stockMin,
    stockMax,
    unitId,
    isSoldByWeight,
    imageFile,
    photoUrl,
  ];
}

@riverpod
class VariantForm extends _$VariantForm {
  @override
  VariantFormState build(ProductVariant? variant, {VariantType? initialType}) {
    return VariantFormState.initial(variant, initialType: initialType);
  }

  void updateName(String value) {
    state = state.copyWithNullable(name: value);
  }

  void updateQuantity(String value) {
    state = state.copyWithNullable(quantity: value);
  }

  void updateConversionFactor(String value) {
    state = state.copyWithNullable(conversionFactor: value);
  }

  void updatePrice(String value) {
    state = state.copyWithNullable(price: value);
  }

  void updateCost(String value) {
    state = state.copyWithNullable(cost: value);
  }

  void updateWholesalePrice(String value) {
    state = state.copyWithNullable(wholesalePrice: value);
  }

  void updateStockMin(String value) {
    state = state.copyWithNullable(stockMin: value);
  }

  void updateStockMax(String value) {
    state = state.copyWithNullable(stockMax: value);
  }

  void updateBarcode(String value) {
    state = state.copyWithNullable(barcode: value, clearBarcodeError: true);
  }

  void updateIsForSale(bool value) {
    state = state.copyWithNullable(isForSale: value);
  }

  void updateType(VariantType value) {
    state = state.copyWithNullable(
      type: value,
      // If switching to Sales: always for sale.
      // If switching to Purchase: defaults to NOT for sale, but user can opt-in via switch.
      isForSale: value == VariantType.sales,
      // Reset linked variant if type changes to Sales (optional, but good practice)
      clearLinkedVariantId: value == VariantType.sales,
    );
  }

  void updateLinkedVariantId(int? value) {
    state = state.copyWithNullable(
      linkedVariantId: value,
      clearLinkedVariantId: value == null,
    );
  }

  void updateUnitId(int? value) {
    state = state.copyWithNullable(unitId: value, clearUnitId: value == null);
  }

  void updateIsSoldByWeight(bool value) {
    state = state.copyWithNullable(isSoldByWeight: value);
  }

  void pickImage(File file) {
    state = state.copyWithNullable(imageFile: file, clearPhotoUrl: true);
  }

  void removeImage() {
    state = state.copyWithNullable(clearImageFile: true, clearPhotoUrl: true);
  }

  Future<bool> validateBarcode(List<String>? existingBarcodes) async {
    if (state.barcode.isEmpty) {
      state = state.copyWithNullable(
        barcodeError: 'El código de barras es requerido',
      );
      return false;
    }

    // Check against existing barcodes in the product (client-side check)
    if (existingBarcodes != null) {
      final currentVariantBarcode = variant?.barcode;
      final barcodesToCheck = currentVariantBarcode != null
          ? existingBarcodes.where((b) => b != currentVariantBarcode).toList()
          : existingBarcodes;

      if (barcodesToCheck.contains(state.barcode)) {
        state = state.copyWithNullable(
          barcodeError:
              'Este código de barras ya está en uso por otra variante de este producto',
        );
        return false;
      }
    }

    // Check database (server-side check)
    final productRepo = ref.read(productRepositoryProvider);
    final isUniqueResult = await productRepo.isBarcodeUnique(
      state.barcode,
      excludeVariantId: variant?.id,
    );

    bool isUnique = true;
    isUniqueResult.fold(
      (failure) {
        // Treat DB error as failure to validate?
        isUnique = false;
      },
      (unique) {
        isUnique = unique;
      },
    );

    if (!isUnique) {
      state = state.copyWithNullable(
        barcodeError: 'Este código de barras ya existe en el sistema',
      );
      return false;
    }

    state = state.copyWithNullable(clearBarcodeError: true);
    return true;
  }

  Future<ProductVariant?> save(
    int productId,
    List<String>? existingBarcodes, {
    String? name,
    String? quantity,
    String? price,
    String? cost,
    String? wholesalePrice,
    String? conversionFactor,
    String? stockMin,
    String? stockMax,
    String? barcode,
  }) async {
    // Sync state with passed values if provided
    state = state.copyWithNullable(
      isSaving: true,
      name: name,
      quantity: quantity,
      price: price,
      cost: cost,
      wholesalePrice: wholesalePrice,
      conversionFactor: conversionFactor,
      stockMin: stockMin,
      stockMax: stockMax,
      barcode: barcode,
    );

    final isValid = await validateBarcode(existingBarcodes);
    if (!isValid) {
      state = state.copyWithNullable(isSaving: false);
      return null;
    }

    // Handle Image Saving
    String? savedPhotoUrl = state.photoUrl;
    if (state.imageFile != null) {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName =
            'variant_${DateTime.now().millisecondsSinceEpoch}_${path.basename(state.imageFile!.path)}';
        final savedImage = await state.imageFile!.copy(
          '${appDir.path}/$fileName',
        );
        savedPhotoUrl = savedImage.path;
      } catch (e) {
        // Log error but proceed
      }
    }

    try {
      final newVariant = ProductVariant(
        id: variant?.id,
        productId: productId,
        variantName: state.name,
        quantity: double.tryParse(state.quantity) ?? 1.0,
        priceCents: (state.type == VariantType.purchase && !state.isForSale)
            ? 0
            : (double.tryParse(state.price) != null
                  ? (double.parse(state.price) * 100).toInt()
                  : 0),
        costPriceCents: double.tryParse(state.cost) != null
            ? (double.parse(state.cost) * 100).toInt()
            : 0,
        wholesalePriceCents:
            state.type == VariantType.sales && state.wholesalePrice.isNotEmpty
            ? (double.tryParse(state.wholesalePrice) != null
                  ? (double.parse(state.wholesalePrice) * 100).toInt()
                  : null)
            : null,
        barcode: state.barcode.isNotEmpty ? state.barcode : null,
        isForSale: state.isForSale,
        type: state.type,
        linkedVariantId: state.linkedVariantId,
        conversionFactor: double.tryParse(state.conversionFactor) ?? 1.0,
        stockMin: double.tryParse(state.stockMin),
        stockMax: double.tryParse(state.stockMax),
        unitId: state.unitId,
        isSoldByWeight: state.isSoldByWeight,
        photoUrl: savedPhotoUrl,
      );

      // IMMEDIATE SAVING LOGIC
      // If productId > 0, it means we are editing an existing product.
      // We should save the variant immediately to the database.
      if (productId > 0) {
        final productRepo = ref.read(productRepositoryProvider);
        if (newVariant.id != null) {
          final result = await productRepo.updateVariant(newVariant);
          bool proceed = false;
          result.fold((l) => proceed = false, (r) => proceed = true);

          if (!proceed) {
            state = state.copyWithNullable(isSaving: false);
            return null;
          }

          state = state.copyWithNullable(isSaving: false);
          return newVariant;
        } else {
          final result = await productRepo.saveVariant(newVariant);
          ProductVariant? savedVariant;
          result.fold(
            (l) => savedVariant = null,
            (newId) => savedVariant = newVariant.copyWith(id: newId),
          );

          if (savedVariant == null) {
            state = state.copyWithNullable(isSaving: false);
            return null;
          }

          state = state.copyWithNullable(isSaving: false);
          return savedVariant;
        }
      }

      // Default behavior for new products (not yet saved to DB)
      state = state.copyWithNullable(isSaving: false);
      return newVariant;
    } catch (e) {
      state = state.copyWithNullable(isSaving: false);
      return null;
    }
  }
}
