import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/product.dart';
import 'package:posventa/domain/entities/inventory_movement.dart';
import 'package:posventa/domain/entities/product_variant.dart';
import 'package:posventa/presentation/providers/inventory_movement_providers.dart';

class ProductHistoryPage extends ConsumerWidget {
  final Product product;
  final ProductVariant? variant;

  const ProductHistoryPage({super.key, required this.product, this.variant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(
      movementsByProductProvider(
        productId: product.id!,
        variantId: variant?.id,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          variant != null
              ? 'Historial: ${variant!.variantName}'
              : 'Historial: ${product.name}',
        ),
      ),
      body: historyAsync.when(
        data: (movements) {
          if (movements.isEmpty) {
            return const Center(
              child: Text(
                'No hay movimientos registrados.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            itemCount: movements.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final movement = movements[index];
              return _MovementTile(
                movement: movement,
                variants: product.variants,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _MovementTile extends StatelessWidget {
  final InventoryMovement movement;
  final List<ProductVariant>? variants;

  const _MovementTile({required this.movement, this.variants});

  String? _getVariantName() {
    if (movement.variantId == null || variants == null) return null;
    try {
      final variant = variants!.firstWhere((v) => v.id == movement.variantId);
      return variant.variantName;
    } catch (_) {
      return null;
    }
  }

  String _cleanReason(String? reason) {
    if (reason == null) return '';
    // Remove (Variant ID: X) pattern
    final cleaned = reason
        .replaceAll(RegExp(r'\(Variant ID: \d+\)'), '')
        .trim();
    // Use regex to optionally format "Lot: X" if needed, or just leave it.
    // Let's just return the cleaned string for now.
    return cleaned;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final isPositive = movement.quantity > 0;
    final color = isPositive ? Colors.green : Colors.red;
    final icon = isPositive ? Icons.arrow_circle_down : Icons.arrow_circle_up;

    // Map types to user friendly names
    String typeLabel = movement.movementType.value;
    switch (movement.movementType) {
      case MovementType.adjustment:
        typeLabel = 'Ajuste';
        break;
      case MovementType.sale:
        typeLabel = 'Venta';
        break;
      case MovementType.purchase:
        typeLabel = 'Compra';
        break;
      case MovementType.transferIn:
        typeLabel = 'Transferencia (Entrada)';
        break;
      case MovementType.transferOut:
        typeLabel = 'Transferencia (Salida)';
        break;
      case MovementType.returnMovement:
        typeLabel = 'Devolución';
        break;
      case MovementType.damage:
        typeLabel = 'Merma';
        break;
    }

    final variantName = _getVariantName();
    final cleanedReason = _cleanReason(movement.reason);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        typeLabel,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (variantName != null)
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                variantName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontSize: 13,
                ),
              ),
            ),
          if (cleanedReason.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(cleanedReason),
            ),
          const SizedBox(height: 4),
          Text(
            dateFormat.format(movement.movementDate),
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${isPositive ? '+' : ''}${movement.quantity.toStringAsFixed(movement.quantity.truncateToDouble() == movement.quantity ? 0 : 2)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            'Saldo: ${movement.quantityAfter.toStringAsFixed(movement.quantityAfter.truncateToDouble() == movement.quantityAfter ? 0 : 2)}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
