import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/pages/products/matrix_generator/views/matrix_generator_desktop.dart';
import 'package:posventa/presentation/pages/products/matrix_generator/views/matrix_generator_mobile.dart';

class MatrixGeneratorPage extends ConsumerStatefulWidget {
  final int productId;
  final VariantType targetType;
  final List<ProductVariant> existingVariants;

  const MatrixGeneratorPage({
    super.key,
    required this.productId,
    this.targetType = VariantType.sales,
    this.existingVariants = const [],
  });

  @override
  ConsumerState<MatrixGeneratorPage> createState() =>
      _MatrixGeneratorPageState();
}

class _MatrixGeneratorPageState extends ConsumerState<MatrixGeneratorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generador de Variantes'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            return MatrixGeneratorDesktop(
              productId: widget.productId,
              targetType: widget.targetType,
              existingVariants: widget.existingVariants,
              onCancel: () => context.pop(),
              onConfirm: (variants) => context.pop(variants),
            );
          } else {
            return MatrixGeneratorMobile(
              productId: widget.productId,
              targetType: widget.targetType,
              existingVariants: widget.existingVariants,
              onCancel: () => context.pop(),
              onConfirm: (variants) => context.pop(variants),
            );
          }
        },
      ),
    );
  }
}
