import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/features/customers/presentation/widgets/customer_payment_dialog.dart';
import 'package:posventa/presentation/providers/debtors_provider.dart';

class CustomerDebtPage extends ConsumerWidget {
  const CustomerDebtPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the debtors provider directly
    final debtorsAsync = ref.watch(debtorsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuentas por Cobrar'),
        centerTitle: true,
      ),
      body: debtorsAsync.when(
        data: (debtors) {
          if (debtors.isEmpty) {
            return const Center(
              child: Text('No hay clientes con deuda pendiente.'),
            );
          }

          return ListView.builder(
            itemCount: debtors.length,
            itemBuilder: (context, index) {
              final customer = debtors[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      Text(
                        'Deuda',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '\$${customer.creditUsed.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
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
      ),
    );
  }
}
