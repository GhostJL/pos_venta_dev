import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:posventa/domain/entities/purchase.dart';
import 'package:posventa/presentation/providers/purchase_providers.dart';

class PurchasesPage extends ConsumerStatefulWidget {
  const PurchasesPage({super.key});

  @override
  ConsumerState<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends ConsumerState<PurchasesPage> {
  @override
  Widget build(BuildContext context) {
    final purchasesAsync = ref.watch(purchaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compras'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/purchases/new');
            },
            tooltip: 'Nueva Compra',
          ),
        ],
      ),
      body: purchasesAsync.when(
        data: (purchases) {
          if (purchases.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay compras registradas',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: purchases.length,
            itemBuilder: (context, index) {
              final purchase = purchases[index];
              return _PurchaseCard(purchase: purchase);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _PurchaseCard extends StatelessWidget {
  final Purchase purchase;

  const _PurchaseCard({required this.purchase});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final isPending = purchase.status == PurchaseStatus.pending;
    final isCancelled = purchase.status == PurchaseStatus.cancelled;

    Color statusColor;
    String statusText;
    if (isPending) {
      statusColor = Colors.orange;
      statusText = 'PENDIENTE';
    } else if (isCancelled) {
      statusColor = Colors.red;
      statusText = 'CANCELADA';
    } else {
      statusColor = Colors.green;
      statusText = 'COMPLETADA';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          context.push('/purchases/${purchase.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    purchase.purchaseNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(100),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                purchase.supplierName ?? 'Proveedor Desconocido',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              // Date
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateFormat.format(purchase.purchaseDate),
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Items count
              Row(
                children: [
                  Icon(Icons.list, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    '${purchase.items.length} producto(s)',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              const Divider(),
              const SizedBox(height: 8),

              // Totals
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TOTAL:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$${(purchase.totalCents / 100).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
