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
  final VariantType type;
  final int? linkedVariantId;

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
      type: variant?.type ?? VariantType.sales,
      linkedVariantId: variant?.linkedVariantId,
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
        priceCents: (state.type == VariantType.purchase && !state.isForSale)
            ? 0
            : (double.parse(state.price) * 100).toInt(),
        costPriceCents: (double.parse(state.cost) * 100).toInt(),
        wholesalePriceCents:
            state.type == VariantType.sales && state.wholesalePrice.isNotEmpty
            ? (double.parse(state.wholesalePrice) * 100).toInt()
            : null,
        barcode: state.barcode.isNotEmpty ? state.barcode : null,
        // Now we respect state.isForSale even for purchase variants
        isForSale: state.isForSale,
        type: state.type,
        linkedVariantId: state.linkedVariantId,
      );
      state = state.copyWithNullable(isSaving: false);
      return newVariant;
    } catch (e) {
      state = state.copyWithNullable(isSaving: false);
      return null;
    }
  }
}
