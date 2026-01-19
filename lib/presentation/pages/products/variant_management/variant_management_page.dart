import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/product.dart';
import 'views/desktop_variant_view.dart';
import 'views/mobile_variant_view.dart';

class VariantManagementPage extends ConsumerWidget {
  final Product product;

  const VariantManagementPage({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Using 900 as breakpoint for a comfortable dual-pane view
        if (constraints.maxWidth > 900) {
          return DesktopVariantView(product: product);
        } else {
          return MobileVariantView(product: product);
        }
      },
    );
  }
}
