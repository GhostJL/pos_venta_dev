import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/core/theme/theme.dart';
import 'package:posventa/domain/entities/sale_item.dart';
import 'package:posventa/domain/entities/return_reason.dart';
import 'package:posventa/presentation/providers/return_processing_provider.dart';

class ReturnItemsSelector extends ConsumerStatefulWidget {
  const ReturnItemsSelector({super.key});

  @override
  ConsumerState<ReturnItemsSelector> createState() =>
      _ReturnItemsSelectorState();
}

class _ReturnItemsSelectorState extends ConsumerState<ReturnItemsSelector> {
  final Map<int, TextEditingController> _quantityControllers = {};
  final Map<int, TextEditingController> _reasonControllers = {};

  @override
  void dispose() {
    for (var controller in _quantityControllers.values) {
      controller.dispose();
    }
    for (var controller in _reasonControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(returnProcessingProvider);
    final sale = state.selectedSale;

    if (sale == null || sale.items.isEmpty) {
      return const Center(child: Text('No hay productos en esta venta'));
    }

    return FutureBuilder<Map<int, double>>(
      future: ref
          .read(saleReturnRepositoryProvider)
          .getReturnedQuantities(sale.id!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final returnedQty = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sale.items.length,
          itemBuilder: (context, index) {
            final item = sale.items[index];
            final alreadyReturned = returnedQty[item.id] ?? 0.0;
            final maxQuantity = item.quantity - alreadyReturned;

            if (maxQuantity <= 0) {
              return _buildFullyReturnedItem(item);
            }

            return _buildReturnableItem(item, maxQuantity, state);
          },
        );
      },
    );
  }

  Widget _buildFullyReturnedItem(SaleItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.grey.shade400),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName ?? 'Producto #${item.productId}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  Text(
                    'Ya devuelto completamente',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReturnableItem(
    SaleItem item,
    double maxQuantity,
    ReturnProcessingState state,
  ) {
    final isSelected = state.selectedItems.containsKey(item.id);
    final itemData = state.selectedItems[item.id];

    // Initialize controllers if needed
    if (!_quantityControllers.containsKey(item.id!)) {
      _quantityControllers[item.id!] = TextEditingController(
        text: maxQuantity.toString(),
      );
    }
    if (!_reasonControllers.containsKey(item.id!)) {
      _reasonControllers[item.id!] = TextEditingController();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: Colors.orange.shade600, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    ref
                        .read(returnProcessingProvider.notifier)
                        .toggleItem(item, value ?? false, maxQuantity);
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName ?? 'Producto #${item.productId}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Vendido: ${item.quantity} • Disponible: $maxQuantity',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${item.unitPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            if (isSelected) ...[
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityControllers[item.id],
                      decoration: InputDecoration(
                        labelText: 'Cantidad',
                        border: const OutlineInputBorder(),
                        suffixText: item.unitOfMeasure,
                        errorMaxLines: 2,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requerido';
                        }
                        final qty = double.tryParse(value);
                        if (qty == null) {
                          return 'Inválido';
                        }
                        if (qty <= 0) {
                          return 'Debe ser > 0';
                        }
                        if (qty > maxQuantity) {
                          return 'Máx: $maxQuantity';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        final qty = double.tryParse(value);
                        if (qty != null) {
                          ref
                              .read(returnProcessingProvider.notifier)
                              .updateItemQuantity(item.id!, qty);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<ReturnReason>(
                      isExpanded: true,
                      initialValue:
                          _reasonControllers[item.id]?.text.isNotEmpty == true
                          ? ReturnReason.values.firstWhere(
                              (e) =>
                                  e.label == _reasonControllers[item.id]?.text,
                              orElse: () => ReturnReason.other,
                            )
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Motivo',
                        border: OutlineInputBorder(),
                      ),
                      items: ReturnReason.values.map((reason) {
                        return DropdownMenuItem(
                          value: reason,
                          child: Text(
                            reason.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _reasonControllers[item.id]?.text = value.label;
                          ref
                              .read(returnProcessingProvider.notifier)
                              .updateItemReason(item.id!, value.label);
                        }
                      },
                    ),
                  ),
                ],
              ),
              if (itemData != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal a devolver:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '\$${(itemData.totalCents / 100.0).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
