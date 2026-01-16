import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/widgets/customers/customer_payment_dialog.dart';
import 'package:posventa/presentation/providers/debtors_provider.dart';

class DebtorsTab extends ConsumerWidget {
  const DebtorsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtorsAsync = ref.watch(debtorsProvider);

    return debtorsAsync.when(
      data: (debtors) {
        if (debtors.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                SizedBox(height: 16),
                Text(
                  'No hay clientes con deuda pendiente.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: debtors.length,
          itemBuilder: (context, index) {
            final customer = debtors[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(child: Text(customer.firstName[0])),
                title: Text('${customer.firstName} ${customer.lastName}'),
                subtitle: Text(
                  'Límite: \$${customer.creditLimit?.toStringAsFixed(2) ?? "N/A"}',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Deuda', style: Theme.of(context).textTheme.bodySmall),
                    Text(
                      '\$${customer.creditUsed.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        CustomerPaymentDialog(customer: customer),
                  ).then((_) => ref.refresh(debtorsProvider));
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
