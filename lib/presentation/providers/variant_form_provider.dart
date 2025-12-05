import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/providers/providers.dart';

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
  });

  factory VariantFormState.initial(ProductVariant? variant) {
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
      isForSale: variant?.isForSale ?? true,
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
      barcodeError:
          barcodeError, // Allow setting to null, but here we treat null as "not changed" if we don't handle it carefully.
      // Actually, for barcodeError, we often want to clear it.
      // Let's use a specific logic: if passed, use it. But copyWith usually ignores nulls.
      // To allow clearing, we might need a specific flag or nullable wrapper.
      // For simplicity in this specific use case, I'll assume if I want to clear it, I pass null? No, that's the default.
      // I'll change the logic to: if barcodeError is passed (even null? no, Dart arguments don't work like that easily without a wrapper).
      // I'll just use a separate method or assume if I call copyWith I might want to keep it unless I explicitly change it.
      // Wait, in my notifier I did `state = state.copyWith(barcode: value, barcodeError: null);`.
      // So I need to support nullable update.
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
  ];
}

@riverpod
class VariantForm extends _$VariantForm {
  @override
  VariantFormState build(ProductVariant? variant) {
    return VariantFormState.initial(variant);
  }

  void updateName(String value) {
    state = state.copyWithNullable(name: value);
  }

  void updateQuantity(String value) {
    state = state.copyWithNullable(quantity: value);
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

  void updateBarcode(String value) {
    state = state.copyWithNullable(barcode: value, clearBarcodeError: true);
  }

  void updateIsForSale(bool value) {
    state = state.copyWithNullable(isForSale: value);
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
    final isUnique = await productRepo.isBarcodeUnique(
      state.barcode,
      excludeVariantId: variant?.id,
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
    List<String>? existingBarcodes,
  ) async {
    state = state.copyWithNullable(isSaving: true);

    final isValid = await validateBarcode(existingBarcodes);
    if (!isValid) {
      state = state.copyWithNullable(isSaving: false);
      return null;
    }

    try {
      final newVariant = ProductVariant(
        id: variant?.id,
        productId: productId,
        variantName: state.name,
        quantity: double.parse(state.quantity),
        priceCents: (double.parse(state.price) * 100).toInt(),
        costPriceCents: (double.parse(state.cost) * 100).toInt(),
        wholesalePriceCents: state.wholesalePrice.isNotEmpty
            ? (double.parse(state.wholesalePrice) * 100).toInt()
            : null,
        barcode: state.barcode.isNotEmpty ? state.barcode : null,
        isForSale: state.isForSale,
      );
      state = state.copyWithNullable(isSaving: false);
      return newVariant;
    } catch (e) {
      state = state.copyWithNullable(isSaving: false);
      return null;
    }
  }
}
