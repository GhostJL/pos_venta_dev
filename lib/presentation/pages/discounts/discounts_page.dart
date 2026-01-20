import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/discount.dart';
import 'package:posventa/presentation/providers/discount_provider.dart';
// Since I have not created the directory Structure for discounts widgets, I will put list logic here for now.

class DiscountsPage extends ConsumerWidget {
  const DiscountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discountsAsync = ref.watch(discountListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Descuentos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/discounts/form');
        },
        child: const Icon(Icons.add),
      ),
      body: discountsAsync.when(
        data: (discounts) {
          if (discounts.isEmpty) {
            return const Center(child: Text('No hay descuentos creados'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: discounts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final discount = discounts[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      discount.type == DiscountType.percentage
                          ? Icons.percent
                          : Icons.attach_money,
                    ),
                  ),
                  title: Text(discount.name),
                  subtitle: Text(
                    _formatDiscountValue(discount) +
                        (discount.startDate != null || discount.endDate != null
                            ? '\n${_formatDates(discount)}'
                            : ''),
                  ),
                  isThreeLine:
                      discount.startDate != null || discount.endDate != null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: discount.isActive,
                        onChanged: (val) {
                          // Quick toggle active
                          final updated = Discount(
                            id: discount.id,
                            name: discount.name,
                            type: discount.type,
                            value: discount.value,
                            isActive: val,
                            createdAt: discount.createdAt,
                            startDate: discount.startDate,
                            endDate: discount.endDate,
                          );
                          ref
                              .read(discountListProvider.notifier)
                              .updateDiscount(updated);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          context.push('/discounts/form', extra: discount);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              title: const Text('Eliminar Descuento'),
                              content: const Text(
                                '¿Estás seguro? Esta acción no se puede deshacer.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(c, false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(c, true),
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            ref
                                .read(discountListProvider.notifier)
                                .deleteDiscount(discount.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  String _formatDiscountValue(Discount discount) {
    if (discount.type == DiscountType.percentage) {
      return '${(discount.value / 100).toStringAsFixed(2)}%'; // stored as basis points (1000 = 10.00%)
    } else {
      return '\$${(discount.value / 100).toStringAsFixed(2)}';
    }
  }

  String _formatDates(Discount discount) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    String start = discount.startDate != null
        ? dateFormat.format(discount.startDate!)
        : 'Inicio';
    String end = discount.endDate != null
        ? dateFormat.format(discount.endDate!)
        : 'Fin';
    return '$start - $end';
  }
}
