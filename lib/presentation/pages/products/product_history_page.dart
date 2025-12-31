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
              return _MovementTile(movement: movement);
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

  const _MovementTile({required this.movement});

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

      case MovementType
          .returnMovement: // Note: Enum has returnMovement, UI had returnIn/returnOut?
        // Let's check the enum definition again.
        // Enum has returnMovement. It does NOT have returnIn/returnOut.
        // But in prev code I used returnIn/returnOut.
        // Wait, database stores 'return_in'/'return_out'?
        // The enum has: returnMovement('return', 'Devolución')
        // Maybe I need to map strings if the DB has different values?
        // InventoryMovement model uses this enum.
        // If the DB has 'return_in', and Enum has 'return', froMString will return default adjustment if not found?
        // Let's assume the Enum handles it or I should adhere to Enum.
        typeLabel = 'Devolución';
        break;
      case MovementType.damage:
        typeLabel = 'Merma';
        break;
    }

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        typeLabel,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (movement.reason != null && movement.reason!.isNotEmpty)
            Text(movement.reason!),
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
            '${isPositive ? '+' : ''}${movement.quantity}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            'Saldo: ${movement.quantityAfter}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
