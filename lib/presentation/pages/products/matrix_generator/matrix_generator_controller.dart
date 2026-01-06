import 'package:equatable/equatable.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'matrix_generator_controller.g.dart';

// --- STATE ---

class MatrixAttribute extends Equatable {
  final String name;
  final List<String> values;

  const MatrixAttribute({required this.name, required this.values});

  MatrixAttribute copyWith({String? name, List<String>? values}) {
    return MatrixAttribute(
      name: name ?? this.name,
      values: values ?? this.values,
    );
  }

  @override
  List<Object?> get props => [name, values];
}

class MatrixGeneratorState extends Equatable {
  final List<MatrixAttribute> attributes;
  final List<ProductVariant> generatedVariants;
  final bool isGenerated;

  const MatrixGeneratorState({
    this.attributes = const [],
    this.generatedVariants = const [],
    this.isGenerated = false,
  });

  MatrixGeneratorState copyWith({
    List<MatrixAttribute>? attributes,
    List<ProductVariant>? generatedVariants,
    bool? isGenerated,
  }) {
    return MatrixGeneratorState(
      attributes: attributes ?? this.attributes,
      generatedVariants: generatedVariants ?? this.generatedVariants,
      isGenerated: isGenerated ?? this.isGenerated,
    );
  }

  @override
  List<Object?> get props => [attributes, generatedVariants, isGenerated];
}

// --- CONTROLLER ---

@riverpod
class MatrixGeneratorNotifier extends _$MatrixGeneratorNotifier {
  @override
  MatrixGeneratorState build(int productId) {
    return const MatrixGeneratorState();
  }

  // Attribute Management
  void addAttribute(String name) {
    if (state.attributes.length >= 3) {
      return; // Limit to 3 dimensions for sanity
    }
    if (state.attributes.any(
      (a) => a.name.toLowerCase() == name.toLowerCase(),
    )) {
      return; // Prevent duplicates
    }
    state = state.copyWith(
      attributes: [
        ...state.attributes,
        MatrixAttribute(name: name, values: []),
      ],
      isGenerated: false,
    );
  }

  void removeAttribute(int index) {
    if (index >= 0 && index < state.attributes.length) {
      final newAttributes = List<MatrixAttribute>.from(state.attributes);
      newAttributes.removeAt(index);
      state = state.copyWith(attributes: newAttributes, isGenerated: false);
    }
  }

  void addValueToAttribute(int attributeIndex, String value) {
    if (attributeIndex < 0 || attributeIndex >= state.attributes.length) return;

    final attribute = state.attributes[attributeIndex];
    if (attribute.values.contains(value)) return;

    final newValues = List<String>.from(attribute.values)..add(value);
    final newAttribute = attribute.copyWith(values: newValues);

    final newAttributes = List<MatrixAttribute>.from(state.attributes);
    newAttributes[attributeIndex] = newAttribute;

    state = state.copyWith(attributes: newAttributes, isGenerated: false);
  }

  void removeValueFromAttribute(int attributeIndex, String value) {
    if (attributeIndex < 0 || attributeIndex >= state.attributes.length) return;

    final attribute = state.attributes[attributeIndex];
    final newValues = List<String>.from(attribute.values)..remove(value);
    final newAttribute = attribute.copyWith(values: newValues);

    final newAttributes = List<MatrixAttribute>.from(state.attributes);
    newAttributes[attributeIndex] = newAttribute;

    state = state.copyWith(attributes: newAttributes, isGenerated: false);
  }

  // Generation Logic
  void generateVariants() {
    if (state.attributes.isEmpty) return;

    // Filter out attributes without values
    final validAttributes = state.attributes
        .where((a) => a.values.isNotEmpty)
        .toList();
    if (validAttributes.isEmpty) return;

    List<List<String>> combinations = [[]];

    // Cartesian Product
    for (var attribute in validAttributes) {
      List<List<String>> temp = [];
      for (var existingCombo in combinations) {
        for (var value in attribute.values) {
          temp.add([...existingCombo, value]);
        }
      }
      combinations = temp;
    }

    final newVariants = combinations.map((combo) {
      final name = combo.join(' / ');
      return ProductVariant(
        productId: productId,
        variantName: name,
        priceCents: 0,
        costPriceCents: 0,
        quantity: 1.0,
      );
    }).toList();

    state = state.copyWith(generatedVariants: newVariants, isGenerated: true);
  }

  // Bulk Edit Logic
  void updateAllPrices(double price) {
    final priceCents = (price * 100).round();
    final updated = state.generatedVariants
        .map((v) => v.copyWith(priceCents: priceCents))
        .toList();
    state = state.copyWith(generatedVariants: updated);
  }

  void updateAllCosts(double cost) {
    final costCents = (cost * 100).round();
    final updated = state.generatedVariants
        .map((v) => v.copyWith(costPriceCents: costCents))
        .toList();
    state = state.copyWith(generatedVariants: updated);
  }

  void updateAllStocks(double stock) {
    final updated = state.generatedVariants
        .map((v) => v.copyWith(stock: stock))
        .toList();
    state = state.copyWith(generatedVariants: updated);
  }

  void updateAllWholesalePrices(double price) {
    final priceCents = (price * 100).round();
    final updated = state.generatedVariants
        .map((v) => v.copyWith(wholesalePriceCents: priceCents))
        .toList();
    state = state.copyWith(generatedVariants: updated);
  }

  void updateAllMinStocks(double stock) {
    final updated = state.generatedVariants
        .map((v) => v.copyWith(stockMin: stock))
        .toList();
    state = state.copyWith(generatedVariants: updated);
  }

  void updateAllMaxStocks(double stock) {
    final updated = state.generatedVariants
        .map((v) => v.copyWith(stockMax: stock))
        .toList();
    state = state.copyWith(generatedVariants: updated);
  }

  void updateAllConversionFactors(double factor) {
    final updated = state.generatedVariants
        .map((v) => v.copyWith(conversionFactor: factor))
        .toList();
    state = state.copyWith(generatedVariants: updated);
  }

  // Individual Edit Logic
  void updateVariant(int index, ProductVariant variant) {
    if (index < 0 || index >= state.generatedVariants.length) return;

    final updatedList = List<ProductVariant>.from(state.generatedVariants);
    updatedList[index] = variant;
    state = state.copyWith(generatedVariants: updatedList);
  }

  // VALIDATION
  String? validate(VariantType type) {
    if (state.generatedVariants.isEmpty) {
      return 'No hay variantes generadas';
    }

    for (var variant in state.generatedVariants) {
      if (type == VariantType.sales) {
        if (variant.price <= 0) {
          return 'El precio de ${variant.variantName} debe ser mayor a 0';
        }
      } else {
        // Purchase Variants
        if (variant.costPrice <= 0) {
          return 'El costo de ${variant.variantName} debe ser mayor a 0';
        }
        if (variant.conversionFactor <= 0) {
          return 'El factor de conversión de ${variant.variantName} debe ser positivo';
        }
        if (variant.linkedVariantId == null) {
          return 'La variante ${variant.variantName} debe estar vinculada a un producto de venta';
        }
      }
    }
    return null;
  }
}
