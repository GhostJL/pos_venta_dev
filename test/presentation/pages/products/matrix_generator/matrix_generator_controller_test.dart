import 'package:flutter_test/flutter_test.dart';
import 'package:posventa/presentation/pages/products/matrix_generator/matrix_generator_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  test('MatrixGeneratorNotifier initial state is empty', () {
    final state = container.read(matrixGeneratorProvider(1));
    expect(state.attributes, isEmpty);
    expect(state.generatedVariants, isEmpty);
    expect(state.isGenerated, false);
  });

  test('Adding attributes and values updates state', () {
    final notifier = container.read(matrixGeneratorProvider(1).notifier);

    notifier.addAttribute('Talla');
    var state = container.read(matrixGeneratorProvider(1));
    expect(state.attributes.length, 1);
    expect(state.attributes.first.name, 'Talla');

    notifier.addValueToAttribute(0, 'S');
    notifier.addValueToAttribute(0, 'M');
    state = container.read(matrixGeneratorProvider(1));
    expect(state.attributes.first.values, ['S', 'M']);
  });

  test('Generating variants creates Cartesian product', () {
    final notifier = container.read(matrixGeneratorProvider(1).notifier);

    // 2 Tallas
    notifier.addAttribute('Talla');
    notifier.addValueToAttribute(0, 'S');
    notifier.addValueToAttribute(0, 'M');

    // 2 Colores
    notifier.addAttribute('Color');
    notifier.addValueToAttribute(1, 'Rojo');
    notifier.addValueToAttribute(1, 'Azul');

    // Expected: 2 * 2 = 4 variants
    // S / Rojo, S / Azul, M / Rojo, M / Azul (order depends on algorithm)

    notifier.generateVariants();

    final state = container.read(matrixGeneratorProvider(1));
    expect(state.generatedVariants.length, 4);
    expect(state.isGenerated, true);

    final names = state.generatedVariants.map((v) => v.variantName).toList();
    expect(
      names,
      containsAll(['S / Rojo', 'S / Azul', 'M / Rojo', 'M / Azul']),
    );
  });

  test('Bulk update modifies all variants', () {
    final notifier = container.read(matrixGeneratorProvider(1).notifier);

    notifier.addAttribute('Talla');
    notifier.addValueToAttribute(0, 'S');
    notifier.addValueToAttribute(0, 'M');
    notifier.generateVariants();

    notifier.updateAllPrices(50.0);

    final state = container.read(matrixGeneratorProvider(1));
    for (var variant in state.generatedVariants) {
      expect(variant.priceCents, 5000);
    }
  });
}
