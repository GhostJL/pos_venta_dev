import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/domain/entities/product.dart';

class ProductInventorySection extends ConsumerWidget {
  final Product? product;
  final TextEditingController stockController;
  final TextEditingController minStockController;
  final TextEditingController maxStockController;

  const ProductInventorySection({
    super.key,
    required this.product,
    required this.stockController,
    required this.minStockController,
    required this.maxStockController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stock field (Initial Stock for new products or Current Stock adjustment)
        TextFormField(
          controller: stockController,
          decoration: const InputDecoration(
            labelText: 'Stock Inicial / Actual',
            prefixIcon: Icon(Icons.inventory_2_rounded),
            helperText: 'Cantidad disponible actualmente',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: minStockController,
                decoration: const InputDecoration(
                  labelText: 'Stock Mínimo',
                  prefixIcon: Icon(Icons.warning_amber_rounded),
                  helperText: 'Nivel de alerta',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: maxStockController,
                decoration: const InputDecoration(
                  labelText: 'Stock Máximo',
                  prefixIcon: Icon(Icons.vertical_align_top_rounded),
                  helperText: 'Opcional (Límite ideal)',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
